"""Memory API router - read-only search from external"""

from fastapi import APIRouter

from memory.vector_store import memory_read

router = APIRouter()


@router.get("/search")
async def search_memory(query: str = "", limit: int = 5):
    """Search memory (read-only). Returns similar past interactions."""
    results = memory_read(query, {"memory_limit": limit})
    return {"results": results}
