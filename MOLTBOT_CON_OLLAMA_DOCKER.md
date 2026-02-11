# 🐳 Conectar Moltbot a Ollama en Docker

## 📋 Resumen

Esta guía te mostrará cómo:
1. Ejecutar Ollama en un contenedor Docker
2. Configurar Moltbot para usar Ollama como proveedor de modelos
3. Conectar ambos servicios

## 🚀 Paso 1: Instalar Docker en la VM

**En tu terminal SSH**, ejecuta:

```bash
# Actualizar sistema
sudo apt update

# Instalar Docker
sudo apt install -y docker.io docker-compose

# Agregar usuario al grupo docker (para usar sin sudo)
sudo usermod -aG docker $USER

# Reiniciar sesión o ejecutar:
newgrp docker

# Verificar instalación
docker --version
docker-compose --version
```

## 🦙 Paso 2: Ejecutar Ollama en Docker

### Opción A: Docker Run (Simple)

```bash
# Crear directorio para datos de Ollama
mkdir -p ~/ollama-data

# Ejecutar Ollama en Docker
docker run -d \
  --name ollama \
  -p 11434:11434 \
  -v ~/ollama-data:/root/.ollama \
  --restart unless-stopped \
  ollama/ollama:latest
```

### Opción B: Docker Compose (Recomendado)

Crea el archivo `~/docker-compose-ollama.yml`:

```yaml
version: '3.8'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ~/ollama-data:/root/.ollama
    restart: unless-stopped
    # Opcional: limitar recursos
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
```

Luego ejecuta:

```bash
docker-compose -f ~/docker-compose-ollama.yml up -d
```

## ✅ Paso 3: Verificar que Ollama Está Corriendo

```bash
# Ver estado del contenedor
docker ps | grep ollama

# Ver logs
docker logs ollama

# Probar conexión
curl http://localhost:11434/api/tags
```

## 📥 Paso 4: Descargar Modelos en Ollama

```bash
# Entrar al contenedor
docker exec -it ollama ollama pull llama2
# O
docker exec -it ollama ollama pull mistral
# O
docker exec -it ollama ollama pull codellama
# O cualquier otro modelo que prefieras

# Ver modelos instalados
docker exec -it ollama ollama list
```

## 🔧 Paso 5: Configurar Moltbot para Usar Ollama

### Opción A: Configurar mediante CLI

**En tu terminal SSH**, ejecuta:

```bash
cd ~/moltbot

# Configurar modelo de Ollama
pnpm start config set models.default.provider ollama
pnpm start config set models.default.model llama2
pnpm start config set models.default.baseURL http://localhost:11434
```

### Opción B: Editar Configuración Manualmente

```bash
# Editar archivo de configuración
nano ~/.openclaw/openclaw.json
```

Agrega o modifica la sección de modelos:

```json
{
  "models": {
    "default": {
      "provider": "ollama",
      "model": "llama2",
      "baseURL": "http://localhost:11434",
      "apiKey": "ollama"  // Ollama no requiere API key real, pero algunos clientes la piden
    }
  }
}
```

### Opción C: Usar Variables de Entorno

```bash
# Configurar variables de entorno
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://localhost:11434

# Ejecutar Moltbot
pnpm start gateway
```

## 🧪 Paso 6: Probar la Conexión

```bash
# Probar que Ollama responde
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Hello, how are you?",
  "stream": false
}'

# Probar con Moltbot
cd ~/moltbot
pnpm start agent --message "Hola, ¿cómo estás?" --local
```

## 🔗 Paso 7: Configurar Red Docker (Si es Necesario)

Si Moltbot está en la VM y Ollama en Docker, ambos deberían poder comunicarse en `localhost:11434`.

Si necesitas acceso desde fuera de la VM:

```bash
# Modificar docker-compose para exponer en todas las interfaces
# Cambiar en docker-compose-ollama.yml:
#   - "11434:11434"
#   a:
#   - "0.0.0.0:11434:11434"
```

## 📝 Configuración Avanzada

### Múltiples Modelos

Puedes configurar múltiples modelos en Moltbot:

```bash
pnpm start config set models.llama2.provider ollama
pnpm start config set models.llama2.model llama2
pnpm start config set models.llama2.baseURL http://localhost:11434

pnpm start config set models.mistral.provider ollama
pnpm start config set models.mistral.model mistral
pnpm start config set models.mistral.baseURL http://localhost:11434
```

### Usar Modelo Específico

```bash
# Especificar modelo al ejecutar
pnpm start agent --model llama2 --message "Hola"
```

## 🆘 Solución de Problemas

### Ollama no responde
```bash
# Verificar que está corriendo
docker ps | grep ollama

# Ver logs
docker logs ollama

# Reiniciar
docker restart ollama
```

### Moltbot no puede conectar a Ollama
```bash
# Verificar que Ollama está accesible
curl http://localhost:11434/api/tags

# Verificar configuración de Moltbot
pnpm start config get models
```

### Modelo no encontrado
```bash
# Ver modelos disponibles en Ollama
docker exec -it ollama ollama list

# Descargar el modelo que necesitas
docker exec -it ollama ollama pull <nombre-del-modelo>
```

## 📚 Modelos Recomendados para Ollama

- **llama2** - Modelo general bueno
- **mistral** - Rápido y eficiente
- **codellama** - Especializado en código
- **llama3** - Última versión (si está disponible)
- **phi** - Modelo pequeño y rápido

---

**Empieza ejecutando Ollama en Docker y luego configura Moltbot para usarlo.**












