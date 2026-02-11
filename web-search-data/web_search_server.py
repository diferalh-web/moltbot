"""
Servidor Flask para búsqueda web
Soporta DuckDuckGo (sin API key) y Tavily (con API key opcional)
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import requests
from concurrent.futures import ThreadPoolExecutor, TimeoutError as FuturesTimeoutError
from typing import Dict, Any, List, Optional

# Timeout para Open WebUI (evitar que cancele la petición); más tiempo si DuckDuckGo va lento desde Docker
OPENWEBUI_SEARCH_TIMEOUT = int(os.getenv("OPENWEBUI_SEARCH_TIMEOUT", "22"))
_executor = ThreadPoolExecutor(max_workers=2)

app = Flask(__name__)
CORS(app)

# API Key de Tavily (opcional)
TAVILY_API_KEY = os.getenv("TAVILY_API_KEY", "")


def _duckduckgo_instant_api(query: str, max_results: int) -> List[Dict[str, Any]]:
    """Fallback: API oficial DuckDuckGo Instant Answer."""
    formatted = []
    try:
        url = "https://api.duckduckgo.com/"
        params = {"q": query, "format": "json", "no_redirect": 1}
        resp = requests.get(url, params=params, timeout=10, headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0"
        })
        if resp.status_code != 200:
            print(f"[DuckDuckGo Instant] respuesta {resp.status_code}", flush=True)
            return formatted
        resp.raise_for_status()
        data = resp.json()
        if data.get("Abstract"):
            formatted.append({
                "title": data.get("Heading", data.get("AbstractSource", "Result")),
                "url": data.get("AbstractURL", ""),
                "snippet": data.get("Abstract", ""),
                "provider": "duckduckgo"
            })
        for topic in data.get("RelatedTopics", [])[: max_results - len(formatted)]:
            if isinstance(topic, dict) and topic.get("FirstURL"):
                formatted.append({
                    "title": topic.get("Text", topic.get("FirstURL", ""))[:80],
                    "url": topic.get("FirstURL", ""),
                    "snippet": topic.get("Text", ""),
                    "provider": "duckduckgo"
                })
            elif isinstance(topic, dict) and "Topics" in topic:
                for sub in topic["Topics"][:2]:
                    if sub.get("FirstURL"):
                        formatted.append({
                            "title": sub.get("Text", "")[:80],
                            "url": sub.get("FirstURL", ""),
                            "snippet": sub.get("Text", ""),
                            "provider": "duckduckgo"
                        })
        return formatted[:max_results]
    except Exception as e:
        print(f"[DuckDuckGo Instant API] Error: {e}", flush=True)
        return formatted


def _duckduckgo_html_search(query: str, max_results: int) -> List[Dict[str, Any]]:
    """Fallback: búsqueda HTML DuckDuckGo (funciona desde contenedores)."""
    import urllib.parse
    formatted = []
    try:
        from bs4 import BeautifulSoup
        url = "https://html.duckduckgo.com/html/"
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml",
            "Accept-Language": "en-US,en;q=0.9",
        }
        resp = requests.post(url, data={"q": query}, headers=headers, timeout=12)
        if resp.status_code != 200:
            print(f"[DuckDuckGo HTML] respuesta {resp.status_code} (duckduckgo puede bloquear desde algunos IPs)", flush=True)
            return formatted
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "html.parser")
        seen_urls = set()
        for block in soup.select("div.result__body"):
            a_url = block.select_one("a.result__url")
            a_title = block.select_one("a.result__a")
            a_snippet = block.select_one("a.result__snippet")
            if not a_url:
                continue
            href = (a_url.get("href") or "").strip()
            if not href:
                continue
            real_url = href
            if "uddg=" in href:
                try:
                    parsed = urllib.parse.urlparse(href)
                    qs = urllib.parse.parse_qs(parsed.query)
                    real_url = qs.get("uddg", [""])[0]
                except Exception:
                    continue
            if real_url and real_url.startswith("http") and real_url not in seen_urls:
                seen_urls.add(real_url)
                title = (a_title.get_text(strip=True) if a_title else a_url.get_text(strip=True) or real_url)[:120]
                snippet = (a_snippet.get_text(strip=True) if a_snippet else title)[:300]
                formatted.append({
                    "title": title,
                    "url": real_url,
                    "snippet": snippet,
                    "provider": "duckduckgo"
                })
                if len(formatted) >= max_results:
                    break
        if not formatted:
            for a in soup.select("a.result__url"):
                href = (a.get("href") or "").strip()
                if not href or href in seen_urls or not href.startswith("http"):
                    continue
                seen_urls.add(href)
                formatted.append({
                    "title": (a.get_text(strip=True) or href)[:120],
                    "url": href,
                    "snippet": "",
                    "provider": "duckduckgo"
                })
                if len(formatted) >= max_results:
                    break
        # Fallback: DuckDuckGo a veces cambia clases; buscar enlaces a sitios externos
        if not formatted:
            for a in soup.select("a[href^='http']"):
                href = (a.get("href") or "").strip()
                if "duckduckgo.com" in href or "duck.com" in href or href in seen_urls:
                    continue
                seen_urls.add(href)
                title = a.get_text(strip=True) or href
                if len(title) > 5:
                    formatted.append({
                        "title": title[:120],
                        "url": href,
                        "snippet": "",
                        "provider": "duckduckgo"
                    })
                    if len(formatted) >= max_results:
                        break
        return formatted[:max_results]
    except ImportError:
        return formatted
    except Exception as e:
        print(f"[DuckDuckGo HTML] Error: {e}", flush=True)
        return formatted


def search_duckduckgo(query: str, max_results: int = 10, try_instant_first: bool = False, try_html_first: bool = False) -> Dict[str, Any]:
    """
    Busca en DuckDuckGo (sin API key).
    - try_instant_first: probar API Instant antes que DDGS.
    - try_html_first: probar HTML primero (suele funcionar mejor desde contenedores Docker).
    Luego DDGS; si no hay resultados, fallbacks según el orden que haya dado mejor resultado.
    """
    formatted_results = []
    if try_html_first:
        print("[DuckDuckGo] intentando HTML primero...", flush=True)
        formatted_results = _duckduckgo_html_search(query, max_results)
        if formatted_results:
            print(f"[DuckDuckGo] HTML devolvió {len(formatted_results)} resultados", flush=True)
            return {"success": True, "query": query, "provider": "duckduckgo", "results": formatted_results, "count": len(formatted_results)}
        print("[DuckDuckGo] HTML sin resultados", flush=True)
    if try_instant_first:
        print("[DuckDuckGo] intentando Instant API...", flush=True)
        formatted_results = _duckduckgo_instant_api(query, max_results)
        if formatted_results:
            print(f"[DuckDuckGo] Instant devolvió {len(formatted_results)} resultados", flush=True)
            return {"success": True, "query": query, "provider": "duckduckgo", "results": formatted_results, "count": len(formatted_results)}
    print("[DuckDuckGo] intentando DDGS...", flush=True)
    try:
        from duckduckgo_search import DDGS
        with DDGS() as ddgs:
            try:
                results = list(ddgs.text(query, max_results=max_results, backend="lite"))
            except Exception:
                try:
                    results = list(ddgs.text(query, max_results=max_results))
                except Exception as e2:
                    print(f"[DuckDuckGo DDGS] fallback error: {e2}", flush=True)
                    results = []
            for result in results:
                formatted_results.append({
                    "title": result.get("title", ""),
                    "url": result.get("href", ""),
                    "snippet": result.get("body", ""),
                    "provider": "duckduckgo"
                })
    except Exception as e:
        print(f"[DuckDuckGo DDGS] Error: {e}", flush=True)
    if not formatted_results:
        print("[DuckDuckGo] fallback Instant API...", flush=True)
        formatted_results = _duckduckgo_instant_api(query, max_results)
    if not formatted_results:
        print("[DuckDuckGo] fallback HTML...", flush=True)
        formatted_results = _duckduckgo_html_search(query, max_results)

    if formatted_results:
        print(f"[DuckDuckGo] total {len(formatted_results)} resultados", flush=True)
        return {
            "success": True,
            "query": query,
            "provider": "duckduckgo",
            "results": formatted_results,
            "count": len(formatted_results)
        }
    return {
        "success": False,
        "error": "No se obtuvieron resultados de búsqueda"
    }


def search_tavily(query: str, max_results: int = 10) -> Dict[str, Any]:
    """
    Busca en Tavily (requiere API key opcional).
    
    Args:
        query: Término de búsqueda
        max_results: Número máximo de resultados
    
    Returns:
        Dict con resultados estructurados
    """
    if not TAVILY_API_KEY:
        return {
            "success": False,
            "error": "TAVILY_API_KEY no configurada. Configura la variable de entorno o usa DuckDuckGo."
        }
    
    try:
        url = "https://api.tavily.com/search"
        payload = {
            "api_key": TAVILY_API_KEY,
            "query": query,
            "max_results": max_results,
            "search_depth": "basic"
        }
        
        response = requests.post(url, json=payload, timeout=30)
        response.raise_for_status()
        
        data = response.json()
        
        formatted_results = []
        for result in data.get("results", []):
            formatted_results.append({
                "title": result.get("title", ""),
                "url": result.get("url", ""),
                "snippet": result.get("content", ""),
                "provider": "tavily"
            })
        
        return {
            "success": True,
            "query": query,
            "provider": "tavily",
            "results": formatted_results,
            "count": len(formatted_results)
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error en búsqueda Tavily: {str(e)}"
        }


@app.route('/health', methods=['GET'])
def health():
    """Endpoint de salud del servicio"""
    return jsonify({
        "status": "ok",
        "service": "web-search",
        "providers": {
            "duckduckgo": "available",
            "tavily": "available" if TAVILY_API_KEY else "api_key_required"
        }
    })


@app.route('/api/search', methods=['POST'])
def search():
    """
    Endpoint principal de búsqueda.
    
    Body JSON:
    {
        "query": "término de búsqueda",
        "provider": "duckduckgo" | "tavily" (default: "duckduckgo"),
        "max_results": 10 (opcional)
    }
    """
    try:
        data = request.json
        query = data.get('query', '')
        provider = data.get('provider', 'duckduckgo').lower()
        max_results = data.get('max_results', 10)
        
        if not query:
            return jsonify({
                "success": False,
                "error": "El parámetro 'query' es requerido"
            }), 400
        
        if provider == "tavily":
            result = search_tavily(query, max_results)
        else:
            result = search_duckduckgo(query, max_results)
        
        if result.get("success"):
            return jsonify(result), 200
        else:
            return jsonify(result), 500
            
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error en el servidor: {str(e)}"
        }), 500


@app.route('/search', methods=['POST', 'GET'])
def search_openwebui():
    """
    Endpoint compatible con Open WebUI External Web Search.
    Request: {"query": "término", "count": 5}
    Response: [{"link": url, "title": título, "snippet": descripción}, ...]
    Opcional: Header Authorization: Bearer <token> (EXTERNAL_SEARCH_API_KEY).
    Ejecuta la búsqueda con timeout para responder antes de que Open WebUI cancele.
    """
    import time as _t
    _ts = _t.strftime("%Y-%m-%d %H:%M:%S", _t.localtime())
    print(f"[Open WebUI /search] {_ts} {request.method} desde {request.remote_addr}", flush=True)
    if request.method == "GET":
        return jsonify({"error": "Use POST with JSON body: {\"query\": \"...\", \"count\": 5}"}), 405
    expected_key = (os.getenv("EXTERNAL_SEARCH_API_KEY") or "").strip()
    if expected_key and expected_key.lower() != "opcional":
        auth = (request.headers.get("Authorization") or "").strip()
        if auth != f"Bearer {expected_key}":
            return jsonify([]), 401
    try:
        # Evitar BadRequest si Open WebUI envía body mal formado (p. ej. Content-Type JSON pero body inválido)
        data = request.get_json(silent=True, force=True) or {}
        query = (data.get("query") or "").strip()
        count = data.get("count", 5)
        if not query:
            if request.get_data(as_text=True).strip() and not data:
                print("[Open WebUI /search] body no es JSON válido, ignorando", flush=True)
            return jsonify([]), 200
        count = max(1, min(int(count), 20))
        print(f"[Open WebUI /search] recibido query='{query[:60]}' count={count}", flush=True)

        def _do_search():
            # HTML primero (suele funcionar desde Docker); luego Instant y DDGS
            result = search_duckduckgo(query, max_results=count, try_instant_first=False, try_html_first=True)
            if not result.get("success") and not result.get("results"):
                import time
                time.sleep(1)
                result = search_duckduckgo(query, max_results=count, try_instant_first=True, try_html_first=True)
            return result

        future = _executor.submit(_do_search)
        try:
            result = future.result(timeout=OPENWEBUI_SEARCH_TIMEOUT)
        except FuturesTimeoutError:
            print(f"[Open WebUI /search] query='{query[:50]}' -> timeout ({OPENWEBUI_SEARCH_TIMEOUT}s)", flush=True)
            return jsonify([]), 200

        if not result.get("success"):
            print(f"[Open WebUI /search] query='{query[:50]}' -> sin resultados ({result.get('error', 'error')})", flush=True)
            return jsonify([]), 200
        out = [
            {
                "link": r.get("url", ""),
                "title": r.get("title", ""),
                "snippet": r.get("snippet", ""),
            }
            for r in result.get("results", [])
        ]
        print(f"[Open WebUI /search] query='{query[:50]}' -> {len(out)} resultados", flush=True)
        return jsonify(out), 200
    except Exception as e:
        print(f"[Open WebUI /search] excepción: {e}", flush=True)
        return jsonify([]), 200


@app.route('/api/providers', methods=['GET'])
def list_providers():
    """Lista los proveedores de búsqueda disponibles"""
    providers = [
        {
            "id": "duckduckgo",
            "name": "DuckDuckGo",
            "requires_api_key": False,
            "available": True
        },
        {
            "id": "tavily",
            "name": "Tavily",
            "requires_api_key": True,
            "available": bool(TAVILY_API_KEY),
            "api_key_configured": bool(TAVILY_API_KEY)
        }
    ]
    
    return jsonify({
        "success": True,
        "providers": providers
    })


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5003))
    app.run(host='0.0.0.0', port=port, debug=False)









