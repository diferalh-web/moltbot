"""
Draco Flow Execution Engine
Orchestrates flow nodes and enforces tool authorization
"""

import json
import os
from pathlib import Path
from typing import Any, Dict, List, Optional

from .nodes import (
    AccionNode,
    BaseNode,
    DecisionNode,
    EntradaNode,
    MemoriaNode,
    NodeType,
    SalidaNode,
)
from .registry import get_flow_registry


def _resolve_params(params: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
    """Resolve {{key}} placeholders in params from context."""
    resolved = {}
    for k, v in params.items():
        if isinstance(v, str) and v.startswith("{{") and v.endswith("}}"):
            key = v[2:-2].strip()
            resolved[k] = context.get(key, context.get("current_input", ""))
        elif isinstance(v, dict):
            resolved[k] = _resolve_params(v, context)
        else:
            resolved[k] = v
    return resolved


# Import audit and tools
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from audit import log_execution, log_flow_start, new_execution_id
from tools.registry import execute_tool, is_tool_authorized


def _create_node(node_def: Dict[str, Any]) -> BaseNode:
    """Create a node instance from flow definition."""
    node_id = node_def.get("id", "unknown")
    node_type_str = node_def.get("type", "")
    config = node_def.get("config", {})

    try:
        nt = NodeType(node_type_str)
    except ValueError:
        nt = NodeType.ENTRADA

    if nt == NodeType.ENTRADA:
        return EntradaNode(node_id, config)
    elif nt == NodeType.SALIDA:
        return SalidaNode(node_id, config)
    elif nt == NodeType.DECISION:
        return DecisionNode(node_id, config)
    elif nt == NodeType.ACCION:
        return AccionNode(node_id, config)
    elif nt == NodeType.MEMORIA:
        return MemoriaNode(node_id, config)
    else:
        return EntradaNode(node_id, config)


class FlowEngine:
    """Executes flows with authorization and audit."""

    def __init__(self):
        self._flow_registry = get_flow_registry()

    def execute(
        self,
        flow_id: str,
        input_data: Dict[str, Any],
        execution_id: Optional[str] = None,
        is_learning_flow: bool = False,
    ) -> Dict[str, Any]:
        """
        Execute a flow by ID.
        Tools run only when authorized by the flow.
        Memory write only when is_learning_flow=True.
        """
        exec_id = execution_id or new_execution_id()
        flow = self._flow_registry.get_flow(flow_id)
        if not flow:
            log_execution(exec_id, flow_id, "engine", "flow_not_found")
            return {"success": False, "error": f"Flow '{flow_id}' not found", "execution_id": exec_id}

        input_preview = str(input_data.get("input", input_data) or "")[:200]
        log_flow_start(flow_id, exec_id, input_preview, max_preview_len=80)

        nodes_def = flow.get("nodes", [])
        start_node = flow.get("start", nodes_def[0]["id"] if nodes_def else "")

        # Build node map
        nodes: Dict[str, BaseNode] = {}
        for nd in nodes_def:
            n = _create_node(nd)
            nodes[n.node_id] = n

        context: Dict[str, Any] = {
            "input": input_data.get("input", input_data),
            **input_data,
            "execution_id": exec_id,
            "flow_id": flow_id,
            "is_learning_flow": is_learning_flow,
        }
        if flow_id == "deep_search":
            context.setdefault("search_results", [])
            context.setdefault("search_round", 0)

        current_node_id = start_node
        max_steps = 100
        step = 0

        while current_node_id and step < max_steps:
            step += 1
            node = nodes.get(current_node_id)
            if not node:
                log_execution(exec_id, flow_id, current_node_id, "node_not_found")
                return {
                    "success": False,
                    "error": f"Node '{current_node_id}' not found",
                    "execution_id": exec_id,
                }

            log_execution(exec_id, flow_id, current_node_id, "node_start")

            try:
                result = node.execute(context)
                context = result.get("context", context)

                # Action node: execute tool (with authorization)
                if node.node_type == NodeType.ACCION and "pending_action" in context:
                    action = context.pop("pending_action", {})
                    tool_name = action.get("tool", "")
                    tool_params = _resolve_params(action.get("params", {}), context)

                    if not is_tool_authorized(flow_id, tool_name):
                        log_execution(exec_id, flow_id, current_node_id, "tool_not_authorized", tool=tool_name)
                        return {
                            "success": False,
                            "error": f"Tool '{tool_name}' is not authorized in this flow",
                            "execution_id": exec_id,
                        }

                    try:
                        tool_result = execute_tool(tool_name, tool_params, context)
                        context["result"] = tool_result
                        context["last_tool_result"] = tool_result
                        if flow_id == "deep_search" and tool_name == "refine_search_query":
                            refined = (tool_result.get("refined_query") or "").strip()
                            if refined:
                                context["current_input"] = refined
                        if flow_id == "deep_search" and tool_name == "web_search":
                            context.setdefault("search_results", []).append(tool_result)
                            context["search_round"] = context.get("search_round", 0) + 1
                        if flow_id == "deep_search" and tool_name == "evaluate_search_relevance":
                            context["search_relevant"] = bool(tool_result.get("relevant", False))
                            max_rounds = 2
                            if context.get("search_round", 0) >= max_rounds:
                                context["search_relevant"] = True
                        log_execution(exec_id, flow_id, current_node_id, "tool_executed", tool=tool_name)
                    except Exception as e:
                        log_execution(exec_id, flow_id, current_node_id, "tool_error", tool=tool_name, error=str(e))
                        return {
                            "success": False,
                            "error": str(e),
                            "execution_id": exec_id,
                        }

                # Memory node: delegate to vector store (handled in engine with memory module)
                if node.node_type == NodeType.MEMORIA:
                    from memory.vector_store import memory_read, memory_write
                    op = context.get("memoria_operation", "read")
                    query = context.get("memoria_query", "")
                    if isinstance(query, str) and "{{" in query:
                        key = query.replace("{{", "").replace("}}", "").strip()
                        query = context.get(key, context.get("current_input", ""))

                    if op == "write":
                        if not is_learning_flow:
                            log_execution(exec_id, flow_id, current_node_id, "memory_write_denied")
                            return {
                                "success": False,
                                "error": "Memory write only allowed via learning flow",
                                "execution_id": exec_id,
                            }
                        memory_write(exec_id, flow_id, query, context)
                    else:
                        context["memory_result"] = memory_read(query, context)
                    log_execution(exec_id, flow_id, current_node_id, "memory_processed", operation=op)

                # Output node: return result
                if node.node_type == NodeType.SALIDA:
                    log_execution(exec_id, flow_id, current_node_id, "flow_complete")
                    return {
                        "success": True,
                        "result": result.get("result", context.get("result")),
                        "execution_id": exec_id,
                    }

                # Decision node: follow next_node
                if node.node_type == NodeType.DECISION:
                    current_node_id = result.get("next_node", "")
                    continue

                # Default: follow edges or next
                edges = flow.get("edges", [])
                next_edge = next((e for e in edges if e.get("source") == current_node_id), None)
                current_node_id = next_edge.get("target", "") if next_edge else ""

            except Exception as e:
                log_execution(exec_id, flow_id, current_node_id, "node_error", error=str(e))
                return {"success": False, "error": str(e), "execution_id": exec_id}

        log_execution(exec_id, flow_id, "engine", "flow_incomplete", steps=step)
        return {
            "success": False,
            "error": "Flow did not reach output node",
            "execution_id": exec_id,
            "context": context,
        }
