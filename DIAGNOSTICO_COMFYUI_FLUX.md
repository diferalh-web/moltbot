# Diagnóstico ComfyUI + Flux

## Resumen

| Modelo | Resultado | Tiempo |
|--------|-----------|--------|
| **SD 1.5** (v1-5-pruned-emaonly) | ✅ Funciona | ~9s a 256x256 |
| **Flux** (flux1-schnell-fp8) | ❌ Falla | Contenedor se reinicia |

## Causa probable

Flux FP8 (~10GB) en RTX 5070 (12GB VRAM) provoca **crash/reinicio** durante la generación. SD 1.5 (~2GB) funciona correctamente.

## Soluciones

### 1. Usar SD 1.5 para pruebas
El script de diagnóstico prueba SD 1.5 primero si existe `v1-5-pruned-emaonly.safetensors`.

### 2. Probar Flux con menos VRAM
Recrear ComfyUI con modo lowvram (recrear-comfyui-robusto o docker run con variable):

```powershell
# Añadir al arranque: -e COMFYUI_LOWVRAM=1
# O en docker run: -e COMFYUI_LOWVRAM=1
```

### 3. Reducir resolución del workflow Flux
Si Flux llegara a ejecutarse, usar 256x256 o 384x384 en lugar de 512x512.

### 4. Script probar-comfyui-test con SD 1.5
Modificar el workflow o añadir opción `-SD15` para usar SD 1.5 en lugar de Flux.

## Verificación

```powershell
.\scripts\diagnostico-comfyui-flux.ps1
```

- Si aparece `diag_test_00001_.png` → SD 1.5 OK
- Si no aparece `diag_flux_*.png` tras probar Flux → problema específico de Flux/VRAM
