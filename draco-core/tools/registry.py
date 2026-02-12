"""
Draco Tool Registry
Maps tool names to HTTP calls to ComfyUI, web-search, etc.
Tools execute only when invoked from an authorized flow.
"""

import base64
import json
import httpx
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Set

import os
import sys

# Add parent for config
_sys_path = str(Path(__file__).resolve().parent.parent)
if _sys_path not in sys.path:
    sys.path.insert(0, _sys_path)

from config import (
    COMFYUI_URL,
    OLLAMA_URL,
    OLLAMA_CHAT_MODEL,
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
    elif tool_name == "evaluate_search_relevance":
        return _evaluate_search_relevance(params, context)
    elif tool_name == "consolidate_search_results":
        return _consolidate_search_results(params, context)
    elif tool_name == "refine_search_query":
        return _refine_search_query(params, context)
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


# Valores por defecto si no existe el archivo de configuración
_DEFAULT_PREFERRED_SOURCES: Dict[str, List[tuple]] = {
    "crypto": [("site:coinmarketcap.com", 5), ("site:coingecko.com", 5)],
    "stocks": [("site:finance.yahoo.com", 6), ("site:investing.com", 6)],
    "tech_news": [("site:techcrunch.com", 4), ("site:theverge.com", 4), ("site:arstechnica.com", 4)],
    "health": [("site:who.int", 4), ("site:mayoclinic.org", 4), ("site:webmd.com", 4)],
    "science": [("site:nature.com", 4), ("site:sciencedaily.com", 4)],
    "general_news": [("site:reuters.com", 4), ("site:bbc.com", 4)],
}
_DEFAULT_TOPIC_KEYWORDS: Dict[str, List[str]] = {
    "crypto": ["bitcoin", "btc", "ethereum", "eth", "cripto", "crypto", "coinmarketcap", "coingecko", "cryptocurrency", "altcoin", "defi"],
    "stocks": ["precio", "price", "valor", "value", "stock", "acción", "acciones", "share", "shares", "cotización", "nvda", "tsla", "aapl", "amzn", "meta", "googl", "msft", "bolsa", "nasdaq"],
    "tech_news": ["tech", "tecnología", "startup", "apple", "google", "microsoft", "intel", "amd", "nvidia", "noticia tech", "tech news"],
    "health": ["salud", "health", "enfermedad", "síntomas", "tratamiento", "medicina", "mayo clinic", "oms", "who", "virus", "vacuna", "vaccine"],
    "science": ["ciencia", "science", "estudio", "investigación", "nature", "paper", "investigadores"],
    "general_news": ["noticia", "news", "última hora", "breaking", "reuters", "bbc"],
}


def _preferred_sources_config_path() -> Optional[Path]:
    """Ruta del archivo de configuración de fuentes preferidas (JSON)."""
    env_path = os.getenv("PREFERRED_SOURCES_CONFIG", "").strip()
    if env_path:
        p = Path(env_path)
        if p.is_file():
            return p
    # Por defecto: draco-core/config/preferred_sources.json
    base = Path(__file__).resolve().parent.parent
    for candidate in [base / "config" / "preferred_sources.json", base.parent / "draco-core" / "config" / "preferred_sources.json"]:
        if candidate.is_file():
            return candidate
    return None


def _load_preferred_config() -> Dict[str, Any]:
    """
    Carga preferred_sources y topic_keywords desde JSON.
    Si el archivo no existe o es inválido, devuelve los valores por defecto.
    Se lee en cada uso para que los cambios en el archivo apliquen sin reiniciar.
    """
    path = _preferred_sources_config_path()
    if not path:
        return {
            "preferred_sources": _DEFAULT_PREFERRED_SOURCES,
            "topic_keywords": _DEFAULT_TOPIC_KEYWORDS,
        }
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        return {"preferred_sources": _DEFAULT_PREFERRED_SOURCES, "topic_keywords": _DEFAULT_TOPIC_KEYWORDS}
    # preferred_sources en JSON es { "tema": [ [ "site:...", n ], ... ] } -> convertir a tuplas
    raw_ps = data.get("preferred_sources") or {}
    preferred_sources: Dict[str, List[tuple]] = {}
    for topic, items in raw_ps.items():
        if isinstance(items, list):
            preferred_sources[topic] = []
            for x in items:
                if isinstance(x, (list, tuple)) and len(x) >= 2:
                    preferred_sources[topic].append((str(x[0]), int(x[1]) if isinstance(x[1], (int, float)) else 5))
    if not preferred_sources:
        preferred_sources = _DEFAULT_PREFERRED_SOURCES
    topic_keywords = data.get("topic_keywords")
    if not isinstance(topic_keywords, dict):
        topic_keywords = _DEFAULT_TOPIC_KEYWORDS
    else:
        topic_keywords = {k: [str(w) for w in v] if isinstance(v, list) else [] for k, v in topic_keywords.items()}
    return {"preferred_sources": preferred_sources, "topic_keywords": topic_keywords}


def _detect_topic(query: str, topic_keywords: Optional[Dict[str, List[str]]] = None) -> Optional[str]:
    """Devuelve el tema detectado por palabras clave (primera coincidencia) o None. topic_keywords puede venir del config dinámico."""
    q = query.lower().strip()
    if not q:
        return None
    keywords = topic_keywords if topic_keywords is not None else _DEFAULT_TOPIC_KEYWORDS
    for topic, kws in keywords.items():
        if kws and any(kw in q for kw in kws):
            return topic
    return None


def _web_search_single(query: str, provider: str, max_results: int, base: str, client: httpx.Client) -> Dict[str, Any]:
    """Una sola llamada al servicio de búsqueda."""
    try:
        resp = client.post(f"{base}/api/search", json={
            "query": query,
            "provider": provider,
            "max_results": max_results,
        })
        resp.raise_for_status()
        return resp.json()
    except httpx.HTTPError as e:
        return {"success": False, "error": str(e), "results": []}


def _web_search(params: Dict[str, Any]) -> Dict[str, Any]:
    """Call web-search service. En ronda 0 detecta el tema y prioriza dominios del config (preferred_sources.json o env PREFERRED_SOURCES_CONFIG)."""
    query = (params.get("query") or "").strip()
    provider = params.get("provider", "duckduckgo")
    max_results = int(params.get("max_results", 10))
    search_round = params.get("search_round")
    if search_round is not None and isinstance(search_round, str):
        try:
            search_round = int(search_round)
        except ValueError:
            search_round = 0
    elif search_round is None:
        search_round = 0

    if not query:
        return {"success": False, "error": "query is required"}

    # Si la consulta pide rango temporal (últimos 12 meses, análisis reciente, etc.), añadir año actual a la búsqueda
    q_lower = query.lower()
    time_range_keywords = ("últimos", "last", "meses", "months", "análisis", "analysis", "reciente", "recent", "histórico", "historical", "evolución", "trend")
    search_query = query
    if any(kw in q_lower for kw in time_range_keywords):
        try:
            year = datetime.now(timezone.utc).year
            search_query = f"{query} {year}"
            if year > 2023:
                search_query = f"{query} {year-1} {year}"
        except Exception:
            pass

    base = get_web_search_url()
    config = _load_preferred_config()
    topic = _detect_topic(query, config.get("topic_keywords"))
    preferred = config.get("preferred_sources", {}).get(topic) if topic else None

    # Primera ronda (search_round == 0) y tema con fuentes preferidas: buscar primero en dominios conocidos
    if search_round == 0 and preferred:
        seen_urls: Set[str] = set()
        merged: List[Dict[str, Any]] = []
        with httpx.Client(timeout=30) as client:
            for site_suffix, n in preferred:
                preferred_query = f"{search_query} {site_suffix}"
                r = _web_search_single(preferred_query, provider, n, base, client)
                if r.get("success") and r.get("results"):
                    for item in r["results"]:
                        url = (item.get("url") or item.get("link") or "").strip()
                        if url and url not in seen_urls:
                            seen_urls.add(url)
                            merged.append(item)
            # Búsqueda general para completar (con refuerzo de fecha si aplica)
            r = _web_search_single(search_query, provider, max(max_results, 18), base, client)
            if r.get("success") and r.get("results"):
                for item in r["results"]:
                    url = (item.get("url") or item.get("link") or "").strip()
                    if url and url not in seen_urls:
                        seen_urls.add(url)
                        merged.append(item)
        return {"success": True, "results": merged[: max_results + 12], "provider": provider}

    # Ronda 2 o consulta no de acciones: una sola búsqueda (search_query ya incluye años si es rango temporal)
    try:
        with httpx.Client(timeout=30) as client:
            resp = client.post(f"{base}/api/search", json={
                "query": search_query,
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


def _refine_search_query(params: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
    """
    Interpreta y refina la consulta del usuario antes de buscar. Genérico: sirve para acciones,
    noticias, ciencia, etc. El LLM aclara ambigüedades (ej. nombres de empresas vs tickers),
    sin listas fijas en código.
    """
    raw = (params.get("query") or params.get("user_query") or context.get("current_input") or context.get("input") or "").strip()
    if not raw:
        return {"refined_query": "", "error": "query vacía"}
    prompt = (
        "Tu tarea es reescribir la siguiente pregunta del usuario como UNA sola consulta de búsqueda web "
        "óptima, sin cambiar la intención. Reglas:\n"
        "- Si habla de una empresa o acción: usa el nombre correcto y, si conoces el ticker bursátil correcto, añádelo entre paréntesis (ej. Meta Platforms = META, Microsoft = MSFT, Tesla = TSLA). No inventes tickers.\n"
        "- Si pide 'precio actual', 'al cierre de hoy', 'últimos 12 meses', mantén o refuerza ese contexto temporal.\n"
        "- Si la consulta es ambigua, elige la interpretación más probable y escribe una búsqueda concreta.\n"
        "- Responde SOLO con un JSON válido: {\"refined_query\": \"tu consulta refinada aquí\"}. Sin explicaciones.\n\n"
        f"Pregunta del usuario: {raw}"
    )
    out = _ollama_chat(prompt, json_mode=True)
    if out.get("error"):
        return {"refined_query": raw, "error": out["error"]}
    content = (out.get("content") or "").strip()
    try:
        if content.strip().startswith("```"):
            content = content.strip()
            for marker in ("```json", "```"):
                if marker in content:
                    content = content.split(marker, 1)[-1]
            content = content.rsplit("```", 1)[0].strip()
        data = json.loads(content)
        refined = (data.get("refined_query") or raw).strip()[:500]
        return {"refined_query": refined if refined else raw}
    except Exception:
        return {"refined_query": raw}


def _ollama_chat(prompt: str, json_mode: bool = False) -> Dict[str, Any]:
    """Call Ollama /api/chat. Returns dict with 'content' or 'error'."""
    url = f"{OLLAMA_URL.rstrip('/')}/api/chat"
    body = {
        "model": OLLAMA_CHAT_MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "stream": False,
    }
    if json_mode:
        body["format"] = "json"
    try:
        with httpx.Client(timeout=120) as client:
            resp = client.post(url, json=body)
            resp.raise_for_status()
            data = resp.json()
            msg = data.get("message", {})
            content = (msg.get("content") or "").strip()
            return {"content": content, "error": None}
    except httpx.HTTPError as e:
        return {"content": "", "error": str(e)}


def _search_results_to_text(search_results: Any) -> str:
    """Turn web_search result(s) into a single text block for prompts."""
    if not search_results:
        return "(no results)"
    if isinstance(search_results, dict) and "results" in search_results:
        items = search_results["results"]
    elif isinstance(search_results, list):
        items = []
        for x in search_results:
            if isinstance(x, dict) and "results" in x:
                items.extend(x["results"])
            elif isinstance(x, dict):
                items.append(x)
    else:
        return str(search_results)[:2000]
    lines = []
    for i, r in enumerate(items[:40], 1):
        title = r.get("title", "")
        snippet = r.get("snippet", r.get("body", ""))
        url = r.get("url", r.get("link", ""))
        lines.append(f"{i}. {title}\n   {snippet[:400]}\n   {url}")
    return "\n\n".join(lines) if lines else "(no results)"


def _evaluate_search_relevance(params: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
    """Evaluate if search results sufficiently answer the query. Uses Ollama. Siempre segunda ronda: en ronda 1 devolvemos relevant=false."""
    if context.get("search_round", 0) >= 2:
        return {"relevant": True, "suggested_refined_query": ""}
    # Forzar segunda ronda: en la primera ronda siempre pedir más resultados
    if context.get("search_round", 0) == 1:
        return {"relevant": False, "suggested_refined_query": params.get("query", "") or context.get("current_input", "")}
    query = params.get("query", "") or context.get("current_input", "")
    raw = params.get("search_results") or context.get("last_tool_result")
    text = _search_results_to_text(raw)
    if not query or not text or text == "(no results)":
        return {"relevant": False, "suggested_refined_query": query or ""}
    q_lower = query.lower()
    hint = ""
    if any(kw in q_lower for kw in ("precio", "price", "valor", "value", "cotización", "stock", "actual", "hoy", "today")):
        hint = " Si la pregunta pide precio/valor/cotización actual: marca relevant=false para obtener más fuentes. "
    prompt = (
        f'Pregunta del usuario: "{query}"\n\n'
        "Resultados de búsqueda:\n" + text[:6000] + "\n\n"
        f"¿Estos resultados responden suficientemente la pregunta?{hint} "
        'Responde SOLO un JSON válido: {"relevant": true o false, "suggested_refined_query": "búsqueda alternativa si relevant es false"}'
    )
    out = _ollama_chat(prompt, json_mode=True)
    if out.get("error"):
        return {"relevant": False, "suggested_refined_query": query}
    content = out.get("content", "")
    try:
        import json
        if content.strip().startswith("```"):
            content = content.strip()
            for marker in ("```json", "```"):
                if marker in content:
                    content = content.split(marker, 1)[-1]
            content = content.rsplit("```", 1)[0].strip()
        data = json.loads(content)
        return {
            "relevant": bool(data.get("relevant", False)),
            "suggested_refined_query": str(data.get("suggested_refined_query", ""))[:500],
        }
    except Exception:
        return {"relevant": "true" in content.lower() or "yes" in content.lower(), "suggested_refined_query": ""}


# Meses en español para la fecha de referencia en consolidación
_MONTHS = {1: "enero", 2: "febrero", 3: "marzo", 4: "abril", 5: "mayo", 6: "junio",
           7: "julio", 8: "agosto", 9: "septiembre", 10: "octubre", 11: "noviembre", 12: "diciembre"}


def _get_reference_date_str() -> str:
    """Return current date for context in time-sensitive answers (e.g. 'last 12 months', 'today')."""
    try:
        now = datetime.now(timezone.utc)
        d, m, y = now.day, now.month, now.year
        return f"{y}-{m:02d}-{d:02d} (día {d} de {_MONTHS.get(m, str(m))} de {y})"
    except Exception:
        return datetime.now().strftime("%Y-%m-%d")


def _consolidate_search_results(params: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
    """Consolidate accumulated search results into one answer with references. Uses Ollama."""
    query = params.get("query", "") or context.get("current_input", "")
    raw = params.get("accumulated_results") or context.get("search_results", [])
    text = _search_results_to_text(raw)
    if not query:
        return {"success": False, "error": "query is required", "answer": ""}
    q_lower = query.lower()
    ref_date = _get_reference_date_str()
    date_context = (
        f"FECHA DE REFERENCIA (hoy): {ref_date}. "
        "Interpreta 'últimos 12 meses', 'análisis reciente', 'hoy', 'actual', 'last 12 months' respecto a esta fecha. "
        "Si la pregunta pide un rango temporal, indica el período concreto (ej. 'feb 2024 - feb 2025').\n\n"
    )
    # Instrucción base: usar varias fuentes y cotejar
    base_instruction = (
        "Los 'Resultados' siguientes son de VARIAS páginas/fuentes. Tu tarea es:\n"
        "1) Considerar TODAS las fuentes (cada número 1., 2., ... es un resultado distinto).\n"
        "2) Si varias fuentes dan una cifra o dato (ej. precio): compáralas, indica si coinciden o el rango (ej. 'Según X: $A, según Y: $B; la mayoría indica ~$Z').\n"
        "3) Propón UNA respuesta final basada en ese cotejo (ej. 'El precio más citado es...' o 'Las fuentes coinciden en...') y menciona al menos 2 fuentes cuando sea posible.\n"
        "4) Responde en el mismo idioma que la pregunta. No inventes datos que no aparezcan en los resultados.\n\n"
    )
    extra_instruction = ""
    if any(kw in q_lower for kw in ("precio", "price", "valor", "value", "cotización", "cuánto", "how much", "actual", "hoy", "today", "now", "stock", "meses", "months", "análisis", "analysis")):
        extra_instruction = (
            " Para precios/valores: usa ÚNICAMENTE cifras que aparezcan en los resultados. "
            "Si varias fuentes dan precios, compáralos y da un resumen (ej. 'Investing.com: $X, Yahoo Finance: $Y; consenso ~$Z'). "
            "Incluye moneda (USD, EUR) y nombre de la fuente. No uses conocimiento interno.\n\n"
        )
    if any(kw in q_lower for kw in ("lista", "list", "listado", "análisis", "analysis", "evolución", "histórico", "variado", "variación")):
        extra_instruction += (
            " Si piden lista de precios o análisis: estructura la respuesta con viñetas o numeración cuando los resultados traigan varias cifras/fechas; indica fuente y fecha para cada dato cuando esté disponible. "
            "Al final añade una línea breve: 'Datos de búsqueda; para cifras en otra fecha, realiza una nueva consulta.'\n\n"
        )
    # Análisis de variación en últimos 12 meses: pedir estructura clara (rango min-max, datos por mes/trimestre si aparecen, tendencia)
    if any(kw in q_lower for kw in ("12 meses", "12 months", "últimos 12", "last 12 months", "variación", "variado", "evolución")):
        extra_instruction += (
            " Si piden análisis de variación en los últimos 12 meses: incluye (1) rango mínimo y máximo del período con fuente, "
            "(2) si en los resultados hay precios por mes o por trimestre, listarlos con fecha y fuente, "
            "(3) tendencia general (subida/bajada) si se desprende de los datos. No te quedes en un resumen vago; extrae y lista las cifras concretas que aparezcan en los resultados.\n\n"
        )
    prompt = (
        f'{date_context}'
        f'{base_instruction}'
        f'{extra_instruction}'
        f'Pregunta: {query}\n\n'
        f'Resultados (múltiples fuentes):\n{text[:8000]}'
    )
    out = _ollama_chat(prompt, json_mode=False)
    if out.get("error"):
        return {"success": False, "error": out["error"], "answer": ""}
    answer = out.get("content", "")
    # Prefijo con fecha para que el chat no mezcle "precio actual" con rangos históricos de otras consultas
    answer = f"[Fecha de referencia: {ref_date}]\n\n{answer}".strip()
    return {"success": True, "answer": answer, "sources": raw if isinstance(raw, list) else []}


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
