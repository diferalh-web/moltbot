# 🚀 Configurar Contenedores Independientes: Mistral y Qwen

## 📋 Resumen

Esta guía te ayudará a crear contenedores Docker independientes para:
- **Ollama-Mistral** (puerto 11436)
- **Ollama-Qwen** (puerto 11437)

Cada contenedor tiene su propia instancia de Ollama y modelo, permitiendo probar ambos de forma independiente.

## 🔧 Paso 1: Crear Contenedor Ollama-Mistral

**En PowerShell de Windows (como Administrador):**

```powershell
.\scripts\setup-ollama-mistral.ps1
```

Este script:
- Crea el contenedor `ollama-mistral` en el puerto **11436**
- Descarga el modelo **Mistral** (~4GB)
- Configura el volumen de datos en `%USERPROFILE%\ollama-mistral-data`

## 🔧 Paso 2: Crear Contenedor Ollama-Qwen

**En PowerShell de Windows (como Administrador):**

```powershell
.\scripts\setup-ollama-qwen.ps1
```

Este script:
- Crea el contenedor `ollama-qwen` en el puerto **11437**
- Descarga el modelo **Qwen2.5:7b** (~4.5GB)
- Configura el volumen de datos en `%USERPROFILE%\ollama-qwen-data`

## 🔥 Paso 3: Configurar Firewall

**En PowerShell de Windows (como Administrador):**

```powershell
.\scripts\configurar-firewall-modelos.ps1
```

Esto abre los puertos 11436 y 11437 en el firewall de Windows.

## ✅ Paso 4: Verificar Contenedores

```powershell
# Ver contenedores corriendo
docker ps | findstr ollama

# Verificar modelos en Mistral
docker exec ollama-mistral ollama list

# Verificar modelos en Qwen
docker exec ollama-qwen ollama list
```

## 🧪 Paso 5: Probar Conexión desde la VM

**En la terminal SSH de la VM:**

```bash
# Obtener IP del host (reemplaza con tu IP)
HOST_IP="192.168.100.42"

# Probar Mistral
curl http://$HOST_IP:11436/api/tags
curl http://$HOST_IP:11436/v1/models

# Probar Qwen
curl http://$HOST_IP:11437/api/tags
curl http://$HOST_IP:11437/v1/models
```

## 🔧 Paso 6: Configurar Moltbot para Usar Mistral

**En la VM, edita la configuración:**

```bash
# Editar config.json
nano ~/.openclaw/agents/main/agent/config.json
```

Cambia a:
```json
{
  "model": {
    "provider": "ollama",
    "name": "mistral",
    "baseURL": "http://192.168.100.42:11436/v1"
  }
}
```

**Actualizar models.json:**
```bash
nano ~/.openclaw/agents/main/agent/models.json
```

En la sección `"ollama"`, cambia:
```json
"ollama": {
  "baseUrl": "http://192.168.100.42:11436/v1",
  "api": "openai-completions",
  "models": [
    {
      "id": "mistral",
      "name": "mistral"
    }
  ],
  "apiKey": "ollama"
}
```

**Actualizar openclaw.json:**
```bash
nano ~/.openclaw/openclaw.json
```

Cambia la línea del modelo del agente:
```json
"model": "ollama/mistral"
```

## 🔧 Paso 7: Configurar Moltbot para Usar Qwen

Similar al paso anterior, pero usa:
- Puerto: **11437**
- Modelo: **qwen2.5:7b**
- URL: `http://192.168.100.42:11437/v1`

## 📊 Resumen de Puertos y URLs

| Contenedor | Puerto | URL Base | Modelo |
|------------|--------|----------|--------|
| ollama (original) | 11435 | `http://IP:11435/v1` | llama2 |
| ollama-mistral | 11436 | `http://IP:11436/v1` | mistral |
| ollama-qwen | 11437 | `http://IP:11437/v1` | qwen2.5:7b |

## 🛠️ Comandos Útiles

### Ver estado de contenedores
```powershell
docker ps -a | findstr ollama
```

### Iniciar/Detener contenedores
```powershell
# Iniciar
docker start ollama-mistral
docker start ollama-qwen

# Detener
docker stop ollama-mistral
docker stop ollama-qwen
```

### Ver logs
```powershell
docker logs ollama-mistral
docker logs ollama-qwen
```

### Eliminar contenedores (si necesitas empezar de nuevo)
```powershell
docker stop ollama-mistral ollama-qwen
docker rm ollama-mistral ollama-qwen
```

## 🧪 Probar con Moltbot

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

Deberías ver que usa Mistral o Qwen sin el error "does not support tools".

---

**Nota:** Cada contenedor consume recursos independientes. Asegúrate de tener suficiente RAM y espacio en disco para ambos modelos.












