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
