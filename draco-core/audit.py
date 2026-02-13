"""
Draco Audit - Structured logging with execution IDs
"""

import json
import logging
import uuid
from datetime import datetime
from typing import Any, Dict, Optional

# Structured audit logger
_audit_logger: Optional[logging.Logger] = None


def get_audit_logger() -> logging.Logger:
    global _audit_logger
    if _audit_logger is None:
        _audit_logger = logging.getLogger("draco.audit")
        if not _audit_logger.handlers:
            h = logging.StreamHandler()
            h.setFormatter(logging.Formatter("%(message)s"))
            _audit_logger.addHandler(h)
            _audit_logger.setLevel(logging.INFO)
    return _audit_logger


def log_execution(
    execution_id: str,
    flow_id: str,
    node: str,
    event: str,
    **kwargs: Any,
) -> None:
    """Emit a structured audit log entry."""
    entry = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "execution_id": execution_id,
        "flow_id": flow_id,
        "node": node,
        "event": event,
        **kwargs,
    }
    get_audit_logger().info(json.dumps(entry))


def new_execution_id() -> str:
    return str(uuid.uuid4())


def log_flow_start(flow_id: str, execution_id: str, input_preview: str = "", max_preview_len: int = 80) -> None:
    """Log when a flow execution starts (easy to grep: deep_search, web_search, etc.)."""
    preview = (input_preview or "").strip()[:max_preview_len]
    if len((input_preview or "").strip()) > max_preview_len:
        preview += "..."
    get_audit_logger().info(
        "[Draco] flow=%s execution_id=%s event=started input_preview=%s",
        flow_id,
        execution_id,
        repr(preview),
    )


def log_flow_end(
    flow_id: str,
    execution_id: str,
    success: bool,
    error: Optional[str] = None,
) -> None:
    """Log when a flow execution ends (success or failure)."""
    msg = "[Draco] flow=%s execution_id=%s event=completed success=%s" % (flow_id, execution_id, success)
    if error and not success:
        err_preview = (error or "")[:120] + ("..." if len(error or "") > 120 else "")
        msg += " error=%s" % repr(err_preview)
    get_audit_logger().info(msg)
