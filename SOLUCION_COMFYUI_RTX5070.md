# ComfyUI en RTX 5070 / 50 series (Blackwell)

## El problema

La RTX 5070 usa la arquitectura **Blackwell (sm_120)**. PyTorch con CUDA 12.1 no incluye kernels para esta arquitectura:

```
RuntimeError: CUDA error: no kernel image is available for execution on the device
```

## Opciones

### Opción 1: PyTorch estable con CUDA 12.8

PyTorch estable ya ofrece builds con CUDA 12.8 que soportan RTX 50:

```bash
pip uninstall torch torchvision torchaudio -y
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
```

### Opción 2: PyTorch nightly con CUDA 12.8

Usuarios con RTX 5060/5070 confirman que ComfyUI funciona con nightly cu128:

```bash
pip uninstall torch torchvision torchaudio -y
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128
```

### Opción 3: Modo CPU (sin GPU)

Más lento, pero funciona siempre:

```powershell
.\scripts\recrear-comfyui-robusto.ps1 -UseCPU
```

## Aplicar en ComfyUI (Docker)

Usa el parámetro `-RTX50` del script robusto para instalar PyTorch con CUDA 12.8:

```powershell
docker stop comfyui
docker rm comfyui
.\scripts\recrear-comfyui-robusto.ps1 -RTX50
```

La primera vez puede tardar 15–20 minutos (descarga PyTorch cu128). Luego prueba:

```powershell
.\scripts\probar-comfyui-api.ps1
```

## Requisitos del driver

- `nvidia-smi` debe mostrar CUDA 12.8 o superior
- RTX 50 requiere drivers recientes (560+ en Windows)

## Referencias

- [PyTorch #164342 - sm_120 support](https://github.com/pytorch/pytorch/issues/164342)
- [NVIDIA Blackwell Migration Guide](https://forums.developer.nvidia.com/t/software-migration-guide-for-nvidia-blackwell-rtx-gpus/321330)
- [Stack Overflow - PyTorch CUDA 12.8](https://stackoverflow.com/questions/79537819/what-is-the-command-to-install-pytorch-with-cuda-12-8)
