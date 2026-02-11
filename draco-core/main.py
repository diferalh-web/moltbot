"""
Draco Core - Flow-based agent orchestration
FastAPI service with flow engine, memory, and audit
"""

import sys
from pathlib import Path

# Ensure draco-core root is on path when run as script
_root = Path(__file__).resolve().parent
if str(_root) not in sys.path:
    sys.path.insert(0, str(_root))

import uvicorn
from fastapi import FastAPI, HTTPException, Header, Depends
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from config import DRACO_REQUIRE_AUTH, DRACO_API_TOKEN
from flows.registry import get_flow_registry
from routers import flows, memory, health


async def verify_token(authorization: str | None = Header(default=None)) -> bool:
    """Verify API token if auth is required."""
    if not DRACO_REQUIRE_AUTH:
        return True
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid Authorization header")
    token = authorization.split(" ", 1)[1]
    if token != DRACO_API_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid token")
    return True


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup: load flows; shutdown: cleanup."""
    from flows.registry import get_flow_registry
    registry = get_flow_registry()
    registry.load_flows()
    yield


app = FastAPI(
    title="Draco Core",
    description="Flow-based agent orchestration with ComfyUI and WebUI integration",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Optional auth - when DRACO_REQUIRE_AUTH=true, flows and memory require Bearer token
app.include_router(health.router, tags=["health"])
app.include_router(flows.router, prefix="/flows", tags=["flows"], dependencies=[Depends(verify_token)])
app.include_router(memory.router, prefix="/memory", tags=["memory"], dependencies=[Depends(verify_token)])


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=False,
    )
