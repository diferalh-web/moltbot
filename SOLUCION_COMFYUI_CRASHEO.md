# Solución: ComfyUI en ciclo de reinicio (Restarting)

## Problema

El contenedor ComfyUI entra en ciclo de reinicio constante:
```
STATUS: Restarting (128) 54 seconds ago
```

## Causa raíz

El contenedor actual **no usa** la imagen oficial `ghcr.io/comfyanonymous/comfyui`. Fue creado con `python:3.11-slim` y un comando que:

1. Instala dependencias (apt, pip, PyTorch)
2. Ejecuta `git clone ... ComfyUI_src`
3. Copia a ComfyUI y arranca el servidor

**El fallo**: cuando el contenedor se **reinicia** (por crash, `docker restart`, etc.), el sistema de archivos persiste. El directorio `ComfyUI_src` ya existe, `git clone` falla con:
```
fatal: destination path 'ComfyUI_src' already exists and is not an empty directory.
```
Git devuelve código 128, el comando falla y `restart: unless-stopped` reintenta infinitamente.

## Solución: usar imagen oficial vía Docker Compose

La forma más estable es usar la imagen oficial de ComfyUI, que no hace `git clone` en cada arranque:

```powershell
# 1. Eliminar el contenedor dañado
docker stop comfyui
docker rm comfyui

# 2. Crear uno nuevo con la imagen oficial
docker compose -f docker-compose-unified.yml up -d comfyui
```

O si usas `docker-compose-extended.yml`:
```powershell
docker compose -f docker-compose-extended.yml up -d comfyui
```

## Alternativa: script de reparación

Ejecuta el script incluido:
```powershell
.\scripts\arreglar-comfyui-crash.ps1
```

## Verificación

```powershell
# Estado del contenedor
docker ps --filter "name=comfyui"

# Logs (debe mostrar "Running on http://0.0.0.0:8188")
docker logs comfyui --tail 20

# Probar API
.\scripts\probar-comfyui-api.ps1
```

## Si la imagen oficial no está disponible

Si `ghcr.io/comfyanonymous/comfyui:latest` no se descarga, el script `arreglar-comfyui-crash.ps1` usará automáticamente `recrear-comfyui-robusto.ps1`, que:

- Monta `comfyui-data` para persistir el código de ComfyUI
- Usa `git clone ... .` o `git pull` según exista `.git`, sin el bug de ComfyUI_src
- Evita problemas de codificación (BOM/CRLF) usando comando bash inline en lugar de archivo de script
