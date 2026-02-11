# 🔄 Actualizar ComfyUI - Método Simple

## ✅ Método Recomendado: Usar Docker Compose

El método más simple y confiable es usar docker-compose:

```powershell
# Detener ComfyUI
docker stop comfyui
docker rm comfyui

# Actualizar y recrear
docker-compose -f docker-compose-unified.yml pull comfyui
docker-compose -f docker-compose-unified.yml up -d comfyui
```

## 📋 Verificar Estado

```powershell
# Ver estado
docker ps --filter "name=comfyui"

# Ver logs
docker logs -f comfyui
```

## ⏱️ Tiempo de Instalación

- **Primera vez**: 10-30 minutos
- **Actualizaciones**: 5-15 minutos

## ✅ Cuando Esté Listo

Verás en los logs:
```
Running on http://0.0.0.0:8188
```

Luego accede a: `http://localhost:7860`

## 🔍 Verificar Versión

```powershell
docker exec comfyui git -C /root/ComfyUI log --oneline -1
```

## 📝 Nota

Si el método de docker-compose no funciona (problemas con la imagen oficial), el contenedor se crea usando `python:3.11-slim` y clonando desde GitHub, lo cual garantiza la última versión.









