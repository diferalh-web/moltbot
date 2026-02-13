"""
title: Multimedia (Moltbot)
author: Moltbot
description: Búsqueda web, búsqueda profunda (deep search), generación de imágenes y flujos Draco. Incluye web_search, deep_search, generate_image y execute_draco_flow.
required_open_webui_version: 0.4.0
version: 1.0.0
"""

import asyncio
import json
import os
import sys
from typing import Optional

# Cuando Open WebUI ejecuta este toolkit, puede cargar desde la extensión montada
call_tool = None
try:
    from .tools import call_tool
except ImportError:
    try:
        from tools import call_tool
    except ImportError:
        pass
if call_tool is None:
    # Fallback: si se ejecuta como Workspace toolkit (archivo pegado), la extensión suele estar en /app/extensions/multimedia
    for _path in ("/app/extensions/multimedia", "/app/extensions"):
        if _path not in sys.path:
            sys.path.insert(0, _path)
    try:
        from tools import call_tool  # noqa: F811
    except ImportError:
        call_tool = None


def _deep_search_via_http(query: str, max_rounds: int = 2) -> dict:
    """Llama a Draco por HTTP cuando call_tool no está disponible (toolkit pegado en Workspace)."""
    base_url = os.getenv("DRACO_CORE_URL", "http://draco-core:8000").rstrip("/")
    url = f"{base_url}/flows/execute"
    token = os.getenv("DRACO_API_TOKEN", "")
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    payload = {
        "flow_id": "deep_search",
        "input": {"input": query},
        "is_learning_flow": False,
    }
    try:
        import urllib.request
        req = urllib.request.Request(
            url,
            data=json.dumps(payload).encode("utf-8"),
            headers=headers,
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read().decode())
            if data.get("success"):
                return {"success": True, "result": data.get("result")}
            return {"success": False, "error": data.get("error", "Unknown error")}
    except Exception as e:
        return {"success": False, "error": f"Draco no disponible: {str(e)}"}


class Tools:
    """Toolkit Multimedia: búsqueda web, deep search, imágenes, flujos Draco."""

    async def web_search(self, query: str, provider: str = "duckduckgo", max_results: int = 10) -> str:
        """Busca rápida (listado). Para precio de hoy, cotización o acciones (TSLA, NVDA) usa deep_search, no web_search."""
        if call_tool is None:
            return "Error: extensión multimedia no disponible."
        r = await asyncio.to_thread(call_tool, "web_search", {"query": query, "provider": provider, "max_results": max_results})
        if not r.get("success"):
            return r.get("error", "Error en búsqueda")
        return str(r.get("results", r))[:8000]

    async def deep_search(self, query: str, max_rounds: Optional[int] = 2) -> str:
        """Búsqueda profunda: el flujo interpreta la consulta (genérico, cualquier tema) y luego busca y consolida. Pasa en query la pregunta del usuario tal cual."""
        print("[WEBUI-DRACO] toolkit deep_search entered", {"query_preview": (query or "")[:80]}, flush=True)
        if call_tool is not None:
            r = await asyncio.to_thread(call_tool, "deep_search", {"query": query, "max_rounds": max_rounds or 2})
        else:
            # Toolkit ejecutado como Workspace (archivo pegado): llamar a Draco por HTTP
            r = await asyncio.to_thread(_deep_search_via_http, query or "", max_rounds or 2)
        if not r.get("success"):
            return r.get("error", "Error en deep search")
        result = r.get("result") or {}
        answer = result.get("answer", "")
        sources = result.get("sources", [])
        # Diagnóstico: qué devuelve Draco (para ver si el dato erróneo viene del flujo o del modelo)
        _preview = (answer or "")[:500].replace("\n", " ")
        print("[WEBUI-DRACO] deep_search answer_from_draco (preview):", _preview, flush=True)
        if sources:
            answer += "\n\nFuentes: " + str(len(sources)) + " ronda(s) de búsqueda."
        return answer or str(r)[:8000]

    async def generate_image(self, prompt: str, width: int = 1024, height: int = 1024) -> str:
        """Genera una imagen a partir de un texto (prompt). Úsala cuando pidan crear o generar una imagen."""
        if call_tool is None:
            return "Error: extensión multimedia no disponible."
        r = await asyncio.to_thread(call_tool, "generate_image", {"prompt": prompt, "width": width, "height": height})
        if not r.get("success"):
            return r.get("error", "Error generando imagen")
        return "Imagen generada correctamente. " + (r.get("image_url", "")[:200] or "")

    async def execute_draco_flow(
        self, flow_id: str, input_text: str
    ) -> str:
        """Ejecuta un flujo Draco. flow_id puede ser: image_generation, web_search, deep_search, learning."""
        if call_tool is None:
            return "Error: extensión multimedia no disponible."
        is_learning = flow_id == "learning"
        r = await asyncio.to_thread(
            call_tool,
            "execute_draco_flow",
            {"flow_id": flow_id, "input": input_text, "is_learning_flow": is_learning},
        )
        if not r.get("success"):
            return r.get("error", "Error en flujo Draco")
        result = r.get("result") or {}
        if isinstance(result, dict) and "answer" in result:
            return result.get("answer", "") or str(result)[:8000]
        return str(result)[:8000]
