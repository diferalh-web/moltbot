# Draco Core

Flow-based agent orchestration for Moltbot. Integrates with ComfyUI and Open WebUI.

## Features

- **Flow engine**: entrada, acción, decisión, memoria, salida nodes
- **Tool authorization**: Tools execute only within authorized flows
- **Vector memory**: Chroma for RAG (write only via learning flow)
- **Audit**: Structured logs with execution IDs

## API

- `GET /health` - Health check
- `GET /flows` - List available flows
- `POST /flows/execute` - Execute a flow (`{ "flow_id": "...", "input": { "input": "..." } }`)
- `GET /memory/search?query=...` - Search memory (read-only)

## Flows

- `image_generation` - Generate images via ComfyUI
- `web_search` - Search the web
- `learning` - Store in memory (only flow that can write to memory)

## Configuration

| Env | Default | Description |
|-----|---------|-------------|
| COMFYUI_URL | http://comfyui:8188 | ComfyUI API |
| WEB_SEARCH_URL | http://web-search:5003 | Web search service |
| CHROMA_PERSIST_DIR | /app/data/chroma | Chroma storage |
| DRACO_API_TOKEN | | Token when DRACO_REQUIRE_AUTH=true |

## Run with Docker

```bash
docker compose -f docker-compose-unified.yml up -d draco-core
```

Then: http://localhost:8001/health
