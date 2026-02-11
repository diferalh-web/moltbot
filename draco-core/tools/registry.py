"""
Draco Tool Registry
Maps tool names to HTTP calls to ComfyUI, web-search, etc.
Tools execute only when invoked from an authorized flow.
"""

import base64
import httpx
from typing import Any, Dict, List, Set

import os
import sys
from pathlib import Path

# Add parent for config
_sys_path = str(Path(__file__).resolve().parent.parent)
if _sys_path not in sys.path:
    sys.path.insert(0, _sys_path)

from config import (
    COMFYUI_URL,
    WEB_SEARCH_URL,
    TTS_URL,
    COMFYUI_CHECKPOINT,
    get_comfyui_url,
    get_web_search_url,
)

# Flows that authorize each tool (flow_id -> set of tool names)
_AUTHORIZED_TOOLS: Dict[str, Set[str]] = {}


def register_flow_tools(flow_id: str, tools: List[str]) -> None:
    """Register which tools a flow is allowed to execute."""
    _AUTHORIZED_TOOLS[flow_id] = set(tools)


def is_tool_authorized(flow_id: str, tool_name: str) -> bool:
    """Check if a flow is authorized to execute a tool."""
    allowed = _AUTHORIZED_TOOLS.get(flow_id, set())
    # Also allow if flow has "*" (all tools)
    return tool_name in allowed or "*" in allowed


def execute_tool(tool_name: str, params: Dict[str, Any], context: Dict[str, Any]) -> Any:
    """
    Execute a tool by name. Called from engine only after authorization check.
    """
    if tool_name == "generate_image":
        return _generate_image(params)
    elif tool_name == "web_search":
        return _web_search(params)
    elif tool_name == "search_and_summarize":
        return _search_and_summarize(params)
    elif tool_name == "tts":
        return _tts(params)
    else:
        raise ValueError(f"Unknown tool: {tool_name}")


def _generate_image(params: Dict[str, Any]) -> Dict[str, Any]:
    """Call ComfyUI via its API (prompt endpoint)."""
    prompt = params.get("prompt", "")
    width = int(params.get("width", 1024))
    height = int(params.get("height", 1024))
    steps = int(params.get("steps", 28))
    checkpoint = params.get("checkpoint_name") or COMFYUI_CHECKPOINT

    if not prompt:
        return {"success": False, "error": "prompt is required"}

    # Build ComfyUI workflow (same structure as comfyui_workflow.py)
    import random
    seed = params.get("seed") or random.randint(0, 2**32 - 1)
    workflow = {
        "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": checkpoint}},
        "2": {"class_type": "CLIPTextEncode", "inputs": {"text": prompt, "clip": ["1", 1]}},
        "3": {"class_type": "CLIPTextEncode", "inputs": {"text": params.get("negative_prompt", ""), "clip": ["1", 1]}},
        "4": {"class_type": "EmptyLatentImage", "inputs": {"width": width, "height": height, "batch_size": 1}},
        "5": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["1", 0],
                "positive": ["2", 0],
                "negative": ["3", 0],
                "latent_image": ["4", 0],
                "seed": seed,
                "steps": steps,
                "cfg": 3.5,
                "sampler_name": "euler",
                "scheduler": "simple",
                "denoise": 1.0,
            },
        },
        "6": {"class_type": "VAEDecode", "inputs": {"samples": ["5", 0], "vae": ["1", 2]}},
        "7": {"class_type": "SaveImage", "inputs": {"images": ["6", 0]}},
    }

    base = get_comfyui_url()
    try:
        with httpx.Client(timeout=30) as client:
            resp = client.post(f"{base}/prompt", json={"prompt": workflow})
            resp.raise_for_status()
            data = resp.json()
            if "error" in data:
                return {"success": False, "error": data.get("node_errors") or data["error"]}
            prompt_id = data["prompt_id"]

        # Poll for result
        import time
        started = time.monotonic()
        while time.monotonic() - started < 600:
            time.sleep(0.5)
            with httpx.Client(timeout=10) as client:
                hist = client.get(f"{base}/history/{prompt_id}")
                hist.raise_for_status()
                hist_data = hist.json()
                if prompt_id not in hist_data:
                    continue
                entry = hist_data[prompt_id]
                if "outputs" in entry:
                    for node_id, out in entry["outputs"].items():
                        if "images" in out and out["images"]:
                            img_info = out["images"][0]
                            filename = img_info.get("filename")
                            subfolder = img_info.get("subfolder", "")
                            img_type = img_info.get("type", "output")
                            if filename:
                                view = client.get(f"{base}/view", params={"filename": filename, "subfolder": subfolder, "type": img_type})
                                view.raise_for_status()
                                b64 = base64.b64encode(view.content).decode("ascii")
                                ct = view.headers.get("Content-Type", "image/png")
                                return {
                                    "success": True,
                                    "image_url": f"data:{ct};base64,{b64}",
                                    "content_type": ct,
                                    "prompt": prompt,
                                }
                if entry.get("status", {}).get("status_str") == "error":
                    return {"success": False, "error": str(entry.get("status", {}).get("messages", ["ComfyUI error"]))}

        return {"success": False, "error": "ComfyUI timeout"}
    except httpx.HTTPError as e:
        return {"success": False, "error": f"ComfyUI connection error: {e}"}


def _web_search(params: Dict[str, Any]) -> Dict[str, Any]:
    """Call web-search service."""
    query = params.get("query", "")
    provider = params.get("provider", "duckduckgo")
    max_results = int(params.get("max_results", 10))

    if not query:
        return {"success": False, "error": "query is required"}

    base = get_web_search_url()
    try:
        with httpx.Client(timeout=30) as client:
            resp = client.post(f"{base}/api/search", json={
                "query": query,
                "provider": provider,
                "max_results": max_results,
            })
            resp.raise_for_status()
            return resp.json()
    except httpx.HTTPError as e:
        return {"success": False, "error": f"Web search error: {e}"}


def _search_and_summarize(params: Dict[str, Any]) -> Dict[str, Any]:
    """Web search and return summarized results."""
    result = _web_search({**params, "max_results": params.get("max_results", 5)})
    if not result.get("success"):
        return result
    results = result.get("results", [])
    summary_parts = []
    for i, r in enumerate(results[:5], 1):
        summary_parts.append(f"{i}. {r.get('title', '')}: {r.get('snippet', '')[:200]}...")
    result["summary"] = "\n".join(summary_parts)
    return result


def _tts(params: Dict[str, Any]) -> Dict[str, Any]:
    """Call Coqui TTS service."""
    text = params.get("text", "")
    language = params.get("language", "es")
    voice = params.get("voice", "default")

    if not text or not text.strip():
        return {"success": False, "error": "text is required"}

    try:
        with httpx.Client(timeout=120) as client:
            resp = client.post(
                f"{TTS_URL.rstrip('/')}/api/tts",
                json={"text": text, "language": language, "voice": voice},
            )
            resp.raise_for_status()
            if resp.headers.get("content-type", "").startswith("audio/"):
                b64 = base64.b64encode(resp.content).decode("ascii")
                return {"success": True, "audio_base64": b64, "content_type": resp.headers.get("content-type", "audio/wav")}
            data = resp.json()
            return {"success": False, "error": data.get("error", "TTS error")}
    except httpx.HTTPError as e:
        return {"success": False, "error": f"TTS error: {e}"}
