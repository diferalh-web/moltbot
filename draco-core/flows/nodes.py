"""
Draco Flow Node Types
From flujos.md: entrada, acción, decisión, memoria, salida
"""

from enum import Enum
from typing import Any, Dict, Optional


class NodeType(str, Enum):
    ENTRADA = "entrada"  # Accept user input / context
    ACCION = "accion"  # Execute tools (only when authorized by flow)
    DECISION = "decision"  # Branch based on LLM or rules
    MEMORIA = "memoria"  # Read/write vector DB (only via learning flow)
    SALIDA = "salida"  # Return result


class BaseNode:
    """Base class for flow nodes."""

    def __init__(self, node_id: str, node_type: NodeType, config: Optional[Dict[str, Any]] = None):
        self.node_id = node_id
        self.node_type = node_type
        self.config = config or {}

    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """Execute the node. Override in subclasses."""
        raise NotImplementedError


class EntradaNode(BaseNode):
    """Input node: accepts user input and populates context."""

    def __init__(self, node_id: str, config: Optional[Dict[str, Any]] = None):
        super().__init__(node_id, NodeType.ENTRADA, config)

    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        input_key = self.config.get("input_key", "input")
        context["current_input"] = context.get(input_key, context.get("input", ""))
        return {"success": True, "context": context}


class SalidaNode(BaseNode):
    """Output node: returns the result."""

    def __init__(self, node_id: str, config: Optional[Dict[str, Any]] = None):
        super().__init__(node_id, NodeType.SALIDA, config)

    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        output_key = self.config.get("output_key", "result")
        result = context.get(output_key, context.get("result", context))
        return {"success": True, "result": result, "context": context}


class DecisionNode(BaseNode):
    """Decision node: branches based on rules or LLM."""

    def __init__(self, node_id: str, config: Optional[Dict[str, Any]] = None):
        super().__init__(node_id, NodeType.DECISION, config)

    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        branches = self.config.get("branches", {})
        condition_key = self.config.get("condition_key")
        if condition_key is not None:
            raw = context.get(condition_key)
            condition = str(raw).lower() if raw is not None else "default"
            if condition in ("true", "yes", "1"):
                condition = "true"
            elif condition in ("false", "no", "0"):
                condition = "false"
        else:
            condition = self.config.get("condition", "default")
        next_node = branches.get(condition, branches.get("default", ""))
        context["next_node"] = next_node
        return {"success": True, "next_node": next_node, "context": context}


class AccionNode(BaseNode):
    """Action node: executes authorized tools."""

    def __init__(self, node_id: str, config: Optional[Dict[str, Any]] = None):
        super().__init__(node_id, NodeType.ACCION, config)

    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        # Actual tool execution is delegated to the engine (with authorization check)
        tool_name = self.config.get("tool", "")
        tool_params = self.config.get("params", {})
        context["pending_action"] = {"tool": tool_name, "params": tool_params}
        return {"success": True, "tool": tool_name, "params": tool_params, "context": context}


class MemoriaNode(BaseNode):
    """Memory node: read/write vector DB. Write only via learning flow."""

    def __init__(self, node_id: str, config: Optional[Dict[str, Any]] = None):
        super().__init__(node_id, NodeType.MEMORIA, config)

    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        operation = self.config.get("operation", "read")  # read | write
        context["memoria_operation"] = operation
        context["memoria_query"] = self.config.get("query", context.get("current_input", ""))
        return {"success": True, "operation": operation, "context": context}
