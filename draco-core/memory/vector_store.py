"""
Draco Vector Memory (Chroma)
Read: query similar past interactions
Write: only via learning flow (enforced by engine)
"""

import os
from pathlib import Path
from typing import Any, Dict, List, Optional

import sys
_sys_path = str(Path(__file__).resolve().parent.parent)
if _sys_path not in sys.path:
    sys.path.insert(0, _sys_path)

from config import CHROMA_PERSIST_DIR, CHROMA_COLLECTION_NAME

_chroma_client = None
_chroma_collection = None


def _get_client():
    global _chroma_client
    if _chroma_client is None:
        import chromadb
        persist_dir = CHROMA_PERSIST_DIR
        os.makedirs(persist_dir, exist_ok=True)
        _chroma_client = chromadb.PersistentClient(path=persist_dir)
    return _chroma_client


def _get_collection():
    global _chroma_collection
    if _chroma_collection is None:
        client = _get_client()
        _chroma_collection = client.get_or_create_collection(
            name=CHROMA_COLLECTION_NAME,
            metadata={"description": "Draco agent memory"},
        )
    return _chroma_collection


def memory_read(query: str, context: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Query similar content from vector store. Read-only from any flow."""
    try:
        coll = _get_collection()
        results = coll.query(
            query_texts=[query] if query else [""],
            n_results=min(int(context.get("memory_limit", 5)), 20),
            include=["documents", "metadatas"],
        )
        out = []
        docs = results.get("documents", [[]])[0] or []
        metadatas = results.get("metadatas", [[]])[0] or []
        for i, doc in enumerate(docs):
            meta = metadatas[i] if i < len(metadatas) else {}
            out.append({"content": doc, "metadata": meta})
        return out
    except Exception as e:
        return [{"error": str(e), "content": ""}]


def memory_write(execution_id: str, flow_id: str, content: str, context: Dict[str, Any]) -> None:
    """Store content in vector DB. Only callable from learning flow."""
    try:
        coll = _get_collection()
        # Generate a simple embedding from content (Chroma can use default embedding)
        coll.add(
            documents=[content],
            metadatas=[{"execution_id": execution_id, "flow_id": flow_id}],
            ids=[f"{execution_id}_{flow_id}"],
        )
    except Exception:
        pass  # Log but don't fail flow
