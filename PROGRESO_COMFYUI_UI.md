# Barra de Progreso y Colores en Nodos - ComfyUI

## Problema

En la **nueva interfaz de ComfyUI** (por defecto desde ~2024):
- No se muestra barra de progreso total durante la ejecución
- Los nodos no cambian de color al ejecutarse

Es un [problema conocido](https://github.com/crystian/ComfyUI-Crystools/issues/199) de la interfaz actual.

---

## Solución 1: ComfyUI-Crystools (Recomendado)

**Crystools** es una extensión que añade:
- **Barra de progreso** en el menú superior
- **Tiempo transcurrido** al finalizar el workflow
- **Clic en la barra** para saltar al nodo actual en ejecución
- **Monitor de recursos** (CPU, GPU, RAM, VRAM)

### Instalación

```powershell
.\scripts\setup-comfyui-crystools.ps1
```

Luego reinicia ComfyUI:
```powershell
docker restart comfyui
```

Recarga la página (F5) en `http://localhost:7860`.

### Configuración (opcional)

- **Settings** (engranaje) → **Crystools**
- `Show progress bar in menu`: activado por defecto
- `Refresh rate`: para el monitor de recursos (0 = desactivado)

---

## Solución 2: Interfaz antigua

La interfaz clásica puede mostrar el progreso de otra forma.

1. Haz clic en el **icono de engranaje** (Settings)
2. **Comfy** → **Menu**
3. **Use new menu**: desactivar (`disabled`)
4. Recarga la página

La interfaz antigua solo está en inglés.

---

## Comprobar si Crystools está activo

Tras reiniciar ComfyUI, deberías ver:
- Una barra de progreso en la parte superior al ejecutar un workflow
- En la esquina, el monitor de recursos (CPU, GPU, etc.)

Si no aparece, verifica los logs:
```powershell
docker logs comfyui --tail 50
```

Busca líneas como `Loading Crystools` o errores relacionados.
