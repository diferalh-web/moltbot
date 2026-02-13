# Modelos recomendados para OpenClaw (tool use / function calling)

Modelos que funcionan bien con OpenClaw para **web_search**, herramientas y agentes que invocan funciones.

## Contenedores Ollama actuales (docker-compose-unified.yml)

| Contenedor     | Puerto | Uso típico              |
|----------------|--------|--------------------------|
| ollama-mistral | 11436  | Mistral, modelos chat    |
| ollama-qwen    | 11437  | Qwen                     |
| ollama-code    | 11438  | Modelos de código        |
| ollama-flux    | 11439  | Generación de imágenes   |

---

## Modelos con buen tool use (Ollama oficial y comunidad)

### 1. **Qwen 2.5 (recomendado para tool use)**

- **qwen2.5:7b** – Bueno con 7B, menos VRAM
- **qwen2.5:14b** – Mejor tool use, ~10 GB VRAM
- **qwen2.5-coder:7b** – Enfocado en código
- **qwen2.5-coder:14b-instruct** – Muy fiable en function calling (14B)

Contenedor actual: **ollama-qwen** (puerto 11437)

```bash
# En el host (Windows) con Docker
docker exec ollama-qwen ollama pull qwen2.5:14b
# O para menos VRAM:
docker exec ollama-qwen ollama pull qwen2.5:7b
```

URL para OpenClaw: `http://10.0.2.2:11437/v1`  
Modelo: `qwen2.5:14b` o `qwen2.5:7b`

---

### 2. **Llama 3.1 (buen soporte de tools)**

- **llama3.1:8b** – Buen equilibrio rendimiento/VRAM
- **llama3.1:70b** – Mucha VRAM (~40 GB)

Contenedor: **ollama-mistral** o **ollama-code**

```bash
docker exec ollama-mistral ollama pull llama3.1:8b
```

URL: `http://10.0.2.2:11436/v1`  
Modelo: `llama3.1:8b`

---

### 3. **Command-R+ (pensado para tools)**

Modelo específico para agentes y tool use.

```bash
docker exec ollama-mistral ollama pull command-r-plus
```

---

### 4. **Mistral Nemo (alternativa a Mistral)**

Ollama recomienda **mistral-nemo** para tool use, no el `mistral` base.

```bash
docker exec ollama-mistral ollama pull mistral-nemo
```

Modelo: `mistral-nemo`

---

### 5. **Firefunction v2 (enfocado en function calling)**

```bash
docker exec ollama-mistral ollama pull firefunction-v2
```

---

## Resumen de recomendaciones

| Prioridad | Modelo        | Contenedor      | Puerto | VRAM aprox. |
|-----------|---------------|-----------------|--------|-------------|
| 1         | qwen2.5:14b   | ollama-qwen     | 11437  | ~10 GB      |
| 2         | llama3.1:8b   | ollama-mistral  | 11436  | ~6 GB       |
| 3         | qwen2.5:7b    | ollama-qwen     | 11437  | ~4 GB       |
| 4         | mistral-nemo  | ollama-mistral  | 11436  | ~4 GB       |
| 5         | command-r-plus| ollama-mistral  | 11436  | ~12 GB      |

---

## Configurar OpenClaw con Qwen 2.5 (recomendado)

### Opción rápida: script automatizado

Desde **Windows** (con la VM corriendo y SSH accesible):

```powershell
cd c:\code\moltbot
.\scripts\configurar-openclaw-qwen.ps1 -VMUser clawbot -VMIP 127.0.0.1 -Port 2222
```

Para VirtualBox con NAT, `HostIP` es `10.0.2.2` por defecto (ya incluido). Para red bridged usa `-HostIP 192.168.x.x`.

Desde **la VM** (vía SSH):

```bash
cd ~/shareFolder
bash configurar-openclaw-qwen.sh           # usa 10.0.2.2 por defecto
# o con IP explícita:
bash configurar-openclaw-qwen.sh 192.168.1.100
```

Luego reinicia el gateway: `openclaw gateway`.

---

### Opción manual

Tras descargar el modelo en el contenedor:

1. Abrir `~/.openclaw/openclaw.json`
2. Añadir en `models.providers` (o crear un nuevo provider para Qwen):

```json
"ollama": {
  "baseUrl": "http://10.0.2.2:11437/v1",
  "apiKey": "ollama-local",
  "api": "openai-completions",
  "models": [
    {
      "id": "qwen2.5:7b",
      "name": "Qwen 2.5 7B",
      "contextWindow": 32768,
      "maxTokens": 8192,
      "input": ["text"],
      "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
      "reasoning": false
    }
  ]
}
```

**Importante:** Usa el provider `ollama` (no `custom-*`). Los providers custom no pasan tools a Ollama y web_search no se invocará.

3. Cambiar `agents.defaults.model.primary` a:
   ```json
   "ollama/qwen2.5:7b"
   ```
4. Crear o actualizar `auth-profiles.json` con la entrada del provider.
5. Reiniciar el gateway.

---

## Verificar modelos disponibles

```bash
# Desde la VM
curl http://10.0.2.2:11436/api/tags   # ollama-mistral
curl http://10.0.2.2:11437/api/tags   # ollama-qwen
curl http://10.0.2.2:11438/api/tags   # ollama-code
```

O desde el host con Docker:

```bash
docker exec ollama-qwen ollama list
docker exec ollama-mistral ollama list
```

---

## Referencias

- [Ollama - Tool support](https://ollama.com/blog/tool-support)
- [Ollama models - Tools category](https://ollama.com/search?c=tools)
- [Ollama Tool Calling API](https://docs.ollama.com/capabilities/tool-calling)
