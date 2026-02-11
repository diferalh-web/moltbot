"""
Draco Flow Registry
Loads flows from JSON files and registers tool authorizations
"""

import json
import os
from pathlib import Path
from typing import Any, Dict, List, Optional

_FLOWS: Dict[str, Dict[str, Any]] = {}
_FLOWS_DIR: Optional[str] = None


def _get_flows_dir() -> str:
    global _FLOWS_DIR
    if _FLOWS_DIR is None:
        base = Path(__file__).resolve().parent
        _FLOWS_DIR = os.getenv("FLOWS_DIR", str(base / "flows"))
    return _FLOWS_DIR


_REGISTRY: Optional["FlowRegistry"] = None


def get_flow_registry() -> "FlowRegistry":
    """Return singleton registry instance."""
    global _REGISTRY
    if _REGISTRY is None:
        _REGISTRY = FlowRegistry()
    return _REGISTRY


class FlowRegistry:
    """Registry of available flows with versioning."""

    def __init__(self):
        self._flows: Dict[str, Dict[str, Any]] = {}

    def load_flows(self) -> None:
        """Load all flows from the flows directory."""
        flows_dir = Path(_get_flows_dir())
        base_dir = Path(__file__).resolve().parent
        if not flows_dir.exists():
            flows_dir = base_dir
        # Load from flows dir and from this package's directory (skip duplicates)
        loaded_ids = set()
        for search_dir in [flows_dir, base_dir]:
            if not search_dir.exists():
                continue
            for f in search_dir.glob("*.json"):
                try:
                    with open(f, "r", encoding="utf-8") as fp:
                        data = json.load(fp)
                    flow_id = data.get("id", f.stem)
                    if flow_id in loaded_ids:
                        continue
                    loaded_ids.add(flow_id)
                    self._flows[flow_id] = data
                    tools = data.get("authorized_tools", [])
                    from tools.registry import register_flow_tools
                    register_flow_tools(flow_id, tools)
                except Exception:
                    pass
        # Load built-in flows from same dir as this file
        _load_builtin_flows(self)

    def get_flow(self, flow_id: str) -> Optional[Dict[str, Any]]:
        return self._flows.get(flow_id)

    def list_flows(self) -> List[Dict[str, Any]]:
        return [
            {"id": k, "name": v.get("name", k), "version": v.get("version", "0.1.0")}
            for k, v in self._flows.items()
        ]


def _load_builtin_flows(registry: FlowRegistry) -> None:
    """Load built-in flows (e.g. image_generation, web_search, learning)."""
    base = Path(__file__).resolve().parent
    builtin = base / "learning_flow.json"
    if builtin.exists():
        try:
            with open(builtin, "r", encoding="utf-8") as f:
                data = json.load(f)
            fid = data.get("id", "learning")
            from tools.registry import register_flow_tools
            if fid not in registry._flows:
                registry._flows[fid] = data
                register_flow_tools(fid, data.get("authorized_tools", []))
        except Exception:
            pass
