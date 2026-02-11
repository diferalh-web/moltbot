# 🌐 Interfaz Web para Moltbot

## 📋 Opciones Disponibles

### Opción 1: Open WebUI (Recomendado) ⭐

**Open WebUI** es una interfaz web moderna tipo ChatGPT que se conecta directamente a Ollama.

#### Ventajas:
- ✅ Interfaz moderna y fácil de usar
- ✅ Historial de conversaciones
- ✅ Soporte para múltiples modelos
- ✅ Subida de documentos (RAG)
- ✅ Guardado de prompts favoritos
- ✅ Funciona directamente con Ollama (no necesita Moltbot)

#### Configuración:

**En PowerShell de Windows (como Administrador):**

```powershell
.\scripts\setup-open-webui.ps1
```

O manualmente:

```powershell
docker run -d `
  --name open-webui `
  -p 3000:8080 `
  -v ${env:USERPROFILE}/open-webui-data:/app/backend/data `
  --add-host=host.docker.internal:host-gateway `
  -e OLLAMA_BASE_URL=http://host.docker.internal:11436 `
  --restart unless-stopped `
  --gpus all `
  ghcr.io/open-webui/open-webui:main
```

#### Acceso:

1. Abre en tu navegador: `http://localhost:3000`
2. Crea una cuenta (primera vez)
3. Selecciona el modelo "mistral" en la interfaz
4. ¡Listo para usar!

### Opción 2: Interfaz Web Simple Personalizada

Si prefieres una interfaz más simple o personalizada, puedo crear una interfaz web básica que se conecte a Moltbot.

#### Características:
- Interfaz HTML simple
- Conexión directa a Moltbot vía API
- Diseño minimalista
- Fácil de personalizar

¿Quieres que cree esta opción?

### Opción 3: Usar el Gateway de Moltbot

Moltbot tiene un gateway que puede exponer una API. Podemos configurarlo y crear una interfaz web que se conecte a él.

## 🚀 Recomendación

**Para tu caso, recomiendo Open WebUI** porque:
1. Ya tienes Ollama-Mistral funcionando con GPU
2. Open WebUI se conecta directamente a Ollama
3. No necesitas configurar Moltbot adicionalmente
4. Interfaz profesional lista para usar

## 📝 Pasos Rápidos

1. **Ejecutar script de configuración:**
   ```powershell
   .\scripts\setup-open-webui.ps1
   ```

2. **Abrir en navegador:**
   ```
   http://localhost:3000
   ```

3. **Crear cuenta y empezar a usar**

## 🔧 Configuración Avanzada

### Cambiar el puerto

Si el puerto 3000 está ocupado, cambia a otro:

```powershell
docker run -d --name open-webui -p 8080:8080 ...  # Cambia 3000 por 8080
```

### Conectar a Qwen en lugar de Mistral

Cambia la variable de entorno:
```powershell
-e OLLAMA_BASE_URL=http://host.docker.internal:11437  # Qwen
```

### Acceso desde la VM

Si quieres acceder desde la VM, usa la IP del host:
```
http://192.168.100.42:3000
```

## 🐛 Troubleshooting

**Error: Puerto 3000 ocupado**
- Cambia el puerto en el comando docker run

**Error: No se conecta a Ollama**
- Verifica que ollama-mistral esté corriendo: `docker ps | findstr mistral`
- Verifica que el puerto 11436 esté accesible

**Error: No carga la interfaz**
- Espera 30-60 segundos después de crear el contenedor
- Verifica logs: `docker logs open-webui`

---

**¿Quieres que ejecute el script de configuración ahora?**












