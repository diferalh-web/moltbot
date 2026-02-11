# 🎨 Custom Nodes Instalados en ComfyUI

## ✅ Instalación Completada

Fecha: 2025-01-13

## 📦 Custom Nodes Instalados

### 1. **ComfyUI Manager** ⭐ (ESENCIAL)
- **Repositorio**: https://github.com/ltdrdata/ComfyUI-Manager
- **Descripción**: Gestor de custom nodes que permite instalar, actualizar y gestionar extensiones desde la interfaz web
- **Funcionalidad**: 
  - Instalar custom nodes con un clic
  - Actualizar nodos existentes
  - Gestionar dependencias
  - Buscar y descubrir nuevos nodos

### 2. **ComfyUI Impact Pack**
- **Repositorio**: https://github.com/ltdrdata/ComfyUI-Impact-Pack
- **Descripción**: Paquete completo de nodos para workflows avanzados
- **Funcionalidad**: 
  - Nodos de procesamiento de imágenes
  - Utilidades para workflows complejos
  - Integración con múltiples modelos

### 3. **ComfyUI AnimateDiff Evolved**
- **Repositorio**: https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved
- **Descripción**: Generación de animaciones y videos desde imágenes
- **Funcionalidad**:
  - Crear animaciones desde imágenes estáticas
  - Control de movimiento
  - Generación de videos cortos

### 4. **ComfyUI IPAdapter Plus**
- **Repositorio**: https://github.com/cubiq/ComfyUI_IPAdapter_plus
- **Descripción**: Transferencia de estilo y composición avanzada
- **Funcionalidad**:
  - Transferencia de estilo entre imágenes
  - Composición de imágenes
  - Control de apariencia

### 5. **ComfyUI Comfyroll Custom Nodes**
- **Repositorio**: https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes
- **Descripción**: Nodos adicionales para workflows
- **Funcionalidad**: Utilidades y nodos auxiliares

### 6. **ComfyUI ControlNet Aux**
- **Repositorio**: https://github.com/Fannovel16/comfyui_controlnet_aux
- **Descripción**: ControlNet auxiliar para control avanzado de generación
- **Funcionalidad**:
  - Control preciso de la generación
  - Detección de bordes, poses, profundidad
  - Integración con ControlNet

### 7. **ComfyUI Easy Use**
- **Repositorio**: https://github.com/yolain/ComfyUI-Easy-Use
- **Descripción**: Nodos simplificados para facilitar el uso
- **Funcionalidad**: Interfaz más amigable para principiantes

## 🚀 Cómo Usar

### Acceder a ComfyUI Manager

1. Abre ComfyUI en tu navegador: `http://localhost:7860`
2. Busca el botón **"Manager"** en la barra superior
3. Haz clic para abrir el gestor de custom nodes

### Instalar Más Custom Nodes

Desde ComfyUI Manager puedes:
- **Buscar** custom nodes por nombre o funcionalidad
- **Instalar** con un solo clic
- **Actualizar** nodos existentes
- **Ver** dependencias requeridas

### Custom Nodes Recomendados Adicionales

Puedes instalar desde el Manager:
- **Face Restoration**: Mejora de caras en imágenes
- **Upscalers**: Escalado de alta calidad
- **ControlNet**: Control avanzado de generación
- **Segment Anything**: Segmentación de objetos
- **WAS Node Suite**: Utilidades avanzadas

## 📝 Notas

- Todos los custom nodes se instalan en: `/root/ComfyUI/custom_nodes/`
- Después de instalar nuevos nodos, reinicia ComfyUI: `docker restart comfyui`
- Algunos custom nodes requieren modelos adicionales que se descargan automáticamente
- ComfyUI Manager facilita la gestión de dependencias

## 🔄 Actualizar Custom Nodes

Para actualizar todos los custom nodes:

```powershell
docker exec comfyui bash -c "cd /root/ComfyUI/custom_nodes && for dir in */; do cd \"\$dir\" && git pull 2>/dev/null && cd .. || true; done"
```

O usa ComfyUI Manager desde la interfaz web.

## 🐛 Solución de Problemas

Si algún custom node no funciona:
1. Verifica los logs: `docker logs comfyui`
2. Revisa las dependencias en ComfyUI Manager
3. Reinstala el nodo desde el Manager
4. Reinicia el contenedor: `docker restart comfyui`

