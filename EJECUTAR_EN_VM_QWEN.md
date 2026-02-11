# 🚀 Configurar Moltbot con Qwen (Ejecutar en la VM)

## ✅ Verificación Inicial

Ya verificaste que la conectividad funciona:
```bash
curl http://192.168.100.42:11437/api/tags  # ✓ Funciona
```

## 🔧 Configuración Rápida

**Ejecuta estos comandos en la terminal SSH de la VM:**

### Paso 1: Respaldar configuración actual

```bash
mkdir -p ~/.openclaw/backup
cp ~/.openclaw/agents/main/agent/models.json ~/.openclaw/backup/models.json.$(date +%Y%m%d_%H%M%S)
cp ~/.openclaw/agents/main/agent/config.json ~/.openclaw/backup/config.json.$(date +%Y%m%d_%H%M%S)
```

### Paso 2: Actualizar models.json

```bash
python3 << 'EOF'
import json
import os

agent_dir = os.path.expanduser("~/.openclaw/agents/main/agent")
models_file = os.path.join(agent_dir, "models.json")

# Leer el archivo actual
with open(models_file, 'r') as f:
    data = json.load(f)

# Actualizar la sección de Ollama
if "providers" not in data:
    data["providers"] = {}

data["providers"]["ollama"] = {
    "baseUrl": "http://192.168.100.42:11437/v1",
    "api": "openai-completions",
    "models": [
        {
            "id": "qwen2.5:7b",
            "name": "qwen2.5:7b",
            "reasoning": False,
            "input": ["text"],
            "cost": {
                "input": 0,
                "output": 0,
                "cacheRead": 0,
                "cacheWrite": 0
            },
            "contextWindow": 32000,
            "maxTokens": 8192
        }
    ],
    "apiKey": "ollama"
}

# Escribir el archivo actualizado
with open(models_file, 'w') as f:
    json.dump(data, f, indent=2)

print("[OK] models.json actualizado")
EOF
```

### Paso 3: Actualizar config.json

```bash
python3 << 'EOF'
import json
import os

agent_dir = os.path.expanduser("~/.openclaw/agents/main/agent")
config_file = os.path.join(agent_dir, "config.json")

config = {
    "model": {
        "provider": "ollama",
        "name": "qwen2.5:7b",
        "baseURL": "http://192.168.100.42:11437/v1"
    }
}

with open(config_file, 'w') as f:
    json.dump(config, f, indent=4)

print("[OK] config.json actualizado")
EOF
```

### Paso 4: Validar JSON

```bash
echo "=== Validando models.json ==="
python3 -m json.tool ~/.openclaw/agents/main/agent/models.json > /dev/null && echo "✓ models.json válido" || echo "✗ Error en models.json"

echo "=== Validando config.json ==="
python3 -m json.tool ~/.openclaw/agents/main/agent/config.json > /dev/null && echo "✓ config.json válido" || echo "✗ Error en config.json"
```

### Paso 5: Actualizar openclaw.json (opcional pero recomendado)

```bash
python3 << 'EOF'
import json
import os

openclaw_file = os.path.expanduser("~/.openclaw/openclaw.json")

# Leer el archivo actual
with open(openclaw_file, 'r') as f:
    data = json.load(f)

# Actualizar el modelo del agente main
if "agents" in data and "main" in data["agents"]:
    data["agents"]["main"]["model"] = "ollama/qwen2.5:7b"

# Actualizar la configuración de Ollama en models.providers
if "models" in data and "providers" in data["models"]:
    if "ollama" not in data["models"]["providers"]:
        data["models"]["providers"]["ollama"] = {}
    
    data["models"]["providers"]["ollama"]["baseUrl"] = "http://192.168.100.42:11437/v1"
    data["models"]["providers"]["ollama"]["api"] = "openai-completions"

# Escribir el archivo actualizado
with open(openclaw_file, 'w') as f:
    json.dump(data, f, indent=2)

print("[OK] openclaw.json actualizado")
EOF

# Validar
python3 -m json.tool ~/.openclaw/openclaw.json > /dev/null && echo "✓ openclaw.json válido" || echo "✗ Error en openclaw.json"
```

### Paso 6: Probar Moltbot

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola, como estas?" --local
```

## ✅ Resultado Esperado

Si todo está bien configurado, deberías ver:
- ✅ Sin errores de "Failed to discover Ollama models"
- ✅ Sin errores de "does not support tools"
- ✅ Una respuesta del modelo Qwen












