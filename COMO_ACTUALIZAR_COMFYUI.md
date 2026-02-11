# 🔄 Cómo Actualizar ComfyUI

## ✅ Estado Actual

ComfyUI se ha actualizado usando el método de clonación desde GitHub, que garantiza tener la última versión del repositorio oficial.

## 🔍 Verificar Versión Actual

### Método 1: Ver Logs del Contenedor

```powershell
docker logs comfyui --tail 50
```

Busca líneas como:
- `ComfyUI version: ...`
- `Git commit: ...`
- `Starting server...`

### Método 2: Acceder a la Interfaz Web

1. Abre `http://localhost:7860`
2. En la interfaz, busca información de versión en la esquina inferior
3. O revisa la consola del navegador (F12)

### Método 3: Verificar en el Contenedor

```powershell
docker exec comfyui git -C /root/ComfyUI log --oneline -1
```

## 🔄 Actualizar ComfyUI

### Opción 1: Usar el Script Automático (Recomendado)

```powershell
cd C:\code\moltbot
.\scripts\actualizar-comfyui.ps1
```

Este script:
- ✅ Detiene el contenedor actual
- ✅ Actualiza ComfyUI desde GitHub (última versión)
- ✅ Reinstala dependencias si es necesario
- ✅ Reinicia el servicio

### Opción 2: Actualización Manual

```powershell
# Detener contenedor
docker stop comfyui
docker rm comfyui

# Usar docker-compose para recrear
docker-compose -f docker-compose-unified.yml up -d comfyui --force-recreate
```

### Opción 3: Actualizar Sin Recrear (Solo Código)

Si solo quieres actualizar el código sin reinstalar dependencias:

```powershell
docker exec comfyui bash -c "cd /root/ComfyUI && git pull origin main"
docker restart comfyui
```

## 📋 Verificar que Está Actualizado

### 1. Verificar Último Commit

```powershell
docker exec comfyui git -C /root/ComfyUI log --oneline -1
```

### 2. Verificar Fecha de Actualización

```powershell
docker exec comfyui git -C /root/ComfyUI log -1 --format="%ai %s"
```

### 3. Comparar con GitHub

Visita: https://github.com/comfyanonymous/ComfyUI/commits/main

Compara el hash del commit local con el último commit en GitHub.

## ⚙️ Configuración Actual

El contenedor está configurado para:
- **Puerto**: 7860 (host) → 8188 (contenedor)
- **Volúmenes**:
  - Modelos: `${USERPROFILE}/comfyui-models`
  - Output: `${USERPROFILE}/comfyui-output`
  - Input: `${USERPROFILE}/comfyui-input`
- **GPU**: Habilitada (NVIDIA)
- **Auto-actualización**: El script actualiza desde GitHub en cada ejecución

## 🔧 Solución de Problemas

### ComfyUI No Inicia

```powershell
# Ver logs detallados
docker logs comfyui --tail 100

# Verificar errores comunes
docker logs comfyui | Select-String -Pattern "error|Error|ERROR|failed|Failed"
```

### Actualización Fallida

```powershell
# Limpiar y reinstalar
docker stop comfyui
docker rm comfyui
.\scripts\actualizar-comfyui.ps1
```

### Problemas de GPU

```powershell
# Verificar que GPU esté disponible
nvidia-smi

# Verificar configuración GPU en Docker
docker inspect comfyui | Select-String -Pattern "gpu|nvidia"
```

## 📝 Notas Importantes

1. **Tiempo de Instalación**: La primera vez puede tardar 10-30 minutos mientras descarga e instala todas las dependencias
2. **Actualizaciones**: ComfyUI se actualiza frecuentemente, recomiendo actualizar semanalmente o cuando veas nuevas características
3. **Modelos**: Los modelos descargados se mantienen en el volumen, no se pierden al actualizar
4. **Workflows**: Los workflows guardados también se mantienen

## 🚀 Próximos Pasos

1. **Espera a que termine de iniciar** (ver logs: `docker logs -f comfyui`)
2. **Accede a la interfaz**: `http://localhost:7860`
3. **Verifica que funcione** creando un workflow simple
4. **Descarga modelos** si es necesario desde la interfaz

## 📚 Recursos

- **Repositorio Oficial**: https://github.com/comfyanonymous/ComfyUI
- **Documentación**: https://github.com/comfyanonymous/ComfyUI/wiki
- **Últimas Versiones**: https://github.com/comfyanonymous/ComfyUI/releases









