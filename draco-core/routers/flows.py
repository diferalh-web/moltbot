"""Flows API router"""

from typing import Any, Dict, Optional

from fastapi import APIRouter
from pydantic import BaseModel

from audit import log_flow_end
from flows.engine import FlowEngine
from flows.registry import get_flow_registry

router = APIRouter()


class ExecuteFlowRequest(BaseModel):
    flow_id: str
    input: Dict[str, Any] = {}
    is_learning_flow: bool = False


@router.get("")
async def list_flows():
    """List available flows."""
    registry = get_flow_registry()
    return {"flows": registry.list_flows()}


@router.post("/execute")
async def execute_flow(req: ExecuteFlowRequest):
    """
    Execute a flow by ID.
    """
    # #region agent log
    inp = req.input.get("input", "")
    print(f"[DRACO] execute_flow flow_id={req.flow_id} input={repr(inp)[:200]}", flush=True)
    # #endregion
    if "input" not in req.input:
        req.input["input"] = req.input.get("message", "")
    engine = FlowEngine()
    result = engine.execute(
        flow_id=req.flow_id,
        input_data=req.input,
        is_learning_flow=req.is_learning_flow,
    )
    log_flow_end(
        req.flow_id,
        result.get("execution_id", ""),
        result.get("success", False),
        result.get("error"),
    )
    return result
