"""Health check router"""

from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
@router.get("/")
async def health():
    """Health check endpoint."""
    return {
        "status": "ok",
        "service": "draco-core",
        "version": "0.1.0",
    }
