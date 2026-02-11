"""
title: Búsqueda web (Web Search)
author: Moltbot
description: Busca información actualizada en internet usando el servicio web-search. Úsala para precios de acciones, noticias recientes o cualquier dato que requiera información actual.
required_open_webui_version: 0.2.0
version: 1.0.0
"""

import os
from typing import Optional

try:
    import requests
except Exception:
    requests = None


class Tools:
    """Herramienta de búsqueda web que llama al servicio web-search del proyecto."""

    def __init__(self):
        self._base_url = os.getenv("WEB_SEARCH_API_URL", "http://web-search:5003")

    def web_search(
        self,
        query: str,
        max_results: int = 10,
    ) -> str:
        """
        Busca información actualizada en internet. Usa esta herramienta cuando necesites precios de acciones, noticias recientes o datos actuales.
        :param query: Término de búsqueda o pregunta (ej. "precio acciones NVIDIA hoy", "noticias IA 2025")
        :param max_results: Número máximo de resultados (por defecto 10)
        """
        if not query or not str(query).strip():
            return "Error: La consulta de búsqueda no puede estar vacía."
        if requests is None:
            return "Error: El módulo requests no está disponible."
        url = f"{self._base_url.rstrip('/')}/api/search"
        try:
            resp = requests.post(
                url,
                json={
                    "query": query.strip(),
                    "provider": "duckduckgo",
                    "max_results": min(max(1, int(max_results)), 20),
                },
                timeout=30,
            )
            resp.raise_for_status()
            data = resp.json()
        except Exception as e:
            return f"Error al conectar con el servicio de búsqueda: {e}"
        if not data.get("success"):
            return data.get("error", "La búsqueda no devolvió resultados.")
        results = data.get("results", [])
        if not results:
            return "No se encontraron resultados para esa consulta."
        lines = [
            f"**Resultados para: {data.get('query', query)}**\n"
        ]
        for i, r in enumerate(results[:max_results], 1):
            title = (r.get("title") or "").strip() or "(sin título)"
            snippet = (r.get("snippet") or "").strip() or "(sin descripción)"
            link = (r.get("link") or "").strip()
            lines.append(f"{i}. **{title}**\n   {snippet[:300]}{'...' if len(snippet) > 300 else ''}\n   Fuente: {link}")
        return "\n\n".join(lines)
