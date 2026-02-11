# Acceso a Open WebUI desde la red Tailscale

Guía para acceder al WebUI de Moltbot cuando estás en la misma red de Tailscale (mismo tailnet).

## Requisitos previos

- **Tailscale** instalado y activo en el equipo donde corre Docker (el host)
- **Tailscale** instalado en el dispositivo desde el que quieres acceder (PC, móvil, tablet)
- Ambos dispositivos en el **mismo tailnet** (misma cuenta o aprobados)

## Cambios realizados en el proyecto

### 1. Docker Compose (`docker-compose-unified.yml` / `docker-compose-extended.yml`)

- **Puertos**: `0.0.0.0:8082:8080` para que Open WebUI escuche en todas las interfaces de red (incluyendo Tailscale).
- **WEBUI_URL**: Variable de entorno para que Open WebUI conozca la URL pública (importante para OAuth, redirects, etc.).

### 2. Firewall de Windows (`configurar-firewall-extendido.ps1`)

El script ahora incluye todos los puertos necesarios para acceso remoto, incluyendo **8082** (Open WebUI).

## Pasos para configurar el acceso vía Tailscale

### Paso 1: Obtener tu hostname o IP de Tailscale

En el equipo donde corre Docker (Windows con Moltbot):

```powershell
# Ver la IP de Tailscale del host (100.x.x.x)
tailscale ip -4

# Ver el hostname de Tailscale (ej: moltbot-pc)
tailscale status
```

Anota la **IP** (ej: `100.64.1.2`) o el **hostname** de Tailscale (ej: `moltbot-pc`).

### Paso 2: Configurar WEBUI_URL (opcional pero recomendado)

Si vas a acceder usando la IP o hostname de Tailscale, configura la variable antes de levantar los contenedores.

**Opción A – Archivo `.env` en la raíz del proyecto:**

```env
# Para acceso vía Tailscale (reemplaza con tu IP o hostname)
WEBUI_URL=http://100.64.1.2:8082
# o con hostname:
# WEBUI_URL=http://moltbot-pc:8082
```

**Opción B – Variable de entorno en la sesión:**

```powershell
$env:WEBUI_URL = "http://100.64.1.2:8082"
docker compose -f docker-compose-unified.yml up -d --no-deps open-webui --force-recreate
```

**Nota:** Si Open WebUI ya tiene datos guardados, `WEBUI_URL` se persiste en la base de datos. Puedes cambiarla también desde **Admin Panel → Settings → General → WebUI URL**.

### Paso 3: Configurar el firewall de Windows

Ejecuta el script como **Administrador** para abrir los puertos necesarios:

```powershell
.\scripts\configurar-firewall-extendido.ps1
```

Esto abre, entre otros, el puerto **8082** para Open WebUI.

En redes con Tailscale, el tráfico suele pasar por el adaptador virtual de Tailscale. Si el firewall bloquea conexiones, este script debería resolverlo.

### Paso 4: Acceder desde otro dispositivo en Tailscale

En otro dispositivo conectado al mismo tailnet:

1. Abre el navegador.
2. Entra a: **`http://[IP-de-Tailscale-del-host]:8082`**  
   Ejemplo: `http://100.64.1.2:8082`
3. O usa el hostname: **`http://[hostname-tailscale]:8082`**  
   Ejemplo: `http://moltbot-pc:8082`

## Puertos expuestos para acceso remoto

| Puerto | Servicio        | Descripción               |
|--------|-----------------|---------------------------|
| 8082   | Open WebUI      | Interfaz principal       |
| 11436  | Ollama Mistral  | LLM Mistral              |
| 11437  | Ollama Qwen     | LLM Qwen                 |
| 11438  | Ollama Code     | IA de programación       |
| 11439  | Ollama Flux     | Generación de imágenes   |
| 7860   | ComfyUI         | Generación avanzada      |
| 8000   | Stable Video    | Generación de video      |
| 8001   | Draco Core      | Orquestación             |
| 5002   | Coqui TTS       | Síntesis de voz          |
| 5003   | Web Search      | Búsqueda web             |
| 5004   | External APIs   | Gateway APIs externas    |

## Solución de problemas

### No puedo acceder desde otro dispositivo en Tailscale

1. **Comprobar que Tailscale está activo** en ambos dispositivos:
   ```powershell
   tailscale status
   ```

2. **Comprobar que Docker escucha en todas las interfaces:**
   ```powershell
   netstat -an | findstr 8082
   ```
   Deberías ver `0.0.0.0:8082` (o `[::]:8082` en IPv6), no solo `127.0.0.1:8082`.

3. **Recrear Open WebUI** con el binding explícito:
   ```powershell
   docker compose -f docker-compose-unified.yml up -d --no-deps open-webui --force-recreate
   ```

4. **Revisar el firewall**: ejecutar `.\scripts\configurar-firewall-extendido.ps1` como Administrador.

### La página carga pero falla el login o los redirects

Ajusta `WEBUI_URL` a la URL que usas realmente para acceder (IP o hostname de Tailscale y puerto 8082). Ver el Paso 2.

### Ver la configuración actual de Open WebUI

```powershell
docker exec open-webui printenv | findstr WEBUI
```

## Seguridad

- Tailscale cifra el tráfico entre dispositivos.
- Solo dispositivos autorizados en tu tailnet pueden conectarse.
- Considera usar **Tailscale ACLs** para restringir qué máquinas pueden acceder a qué servicios.
