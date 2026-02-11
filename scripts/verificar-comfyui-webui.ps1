# Valida que ComfyUI este habilitado y la configuracion en Open WebUI para generacion de imagenes (Flux).
# Ejecutar desde el host (donde corre Docker).

$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "=== Validacion ComfyUI + Open WebUI (imagenes) ===" -ForegroundColor Cyan
Write-Host ""

# 1. ComfyUI
Write-Host "[1] ComfyUI" -ForegroundColor Yellow
$comfy = docker ps --filter "name=comfyui" --format "{{.Names}}" 2>$null
if (-not $comfy) {
    Write-Host "    [X] Contenedor 'comfyui' no esta corriendo." -ForegroundColor Red
    Write-Host "        Levanta el stack: docker compose -f docker-compose-extended.yml up -d comfyui" -ForegroundColor White
} else {
    Write-Host "    [OK] Contenedor comfyui corriendo" -ForegroundColor Green
    $portOk = $false
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:7860" -UseBasicParsing -TimeoutSec 5
        if ($r.StatusCode -eq 200) { $portOk = $true }
    } catch {}
    if ($portOk) {
        Write-Host "    [OK] API accesible en http://localhost:7860" -ForegroundColor Green
    } else {
        Write-Host "    [!] No se pudo conectar a http://localhost:7860 (puerto 7860 mapeado?)" -ForegroundColor Yellow
    }
    # Intentar listar checkpoints
    try {
        $obj = Invoke-RestMethod -Uri "http://localhost:7860/object_info/CheckpointLoaderSimple" -TimeoutSec 5
        if ($obj.PSObject.Properties.Name -match "CheckpointLoaderSimple") {
            $ckpts = $obj.CheckpointLoaderSimple.input.required.ckpt_name[0]
            if ($ckpts) {
                Write-Host "    Checkpoints disponibles: $($ckpts -join ', ')" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host "    (No se pudo listar checkpoints; ComfyUI puede aun estar iniciando)" -ForegroundColor Gray
    }
}
Write-Host ""

# 2. Open WebUI - variables de entorno
Write-Host "[2] Open WebUI - Variables de imagen" -ForegroundColor Yellow
$webui = docker ps --filter "name=open-webui" --format "{{.Names}}" 2>$null
if (-not $webui) {
    Write-Host "    [X] Contenedor 'open-webui' no esta corriendo." -ForegroundColor Red
} else {
    $envOut = docker exec open-webui env 2>$null
    $hasEnable = $envOut -match "ENABLE_IMAGE_GENERATION=true"
    $hasEngine = $envOut -match "IMAGE_GENERATION_ENGINE=comfyui"
    $hasComfyUrl = ($envOut -match "COMFYUI_BASE_URL=") -or ($envOut -match "IMAGE_GENERATION_API_URL=")
    if ($hasEnable) { Write-Host "    [OK] ENABLE_IMAGE_GENERATION=true" -ForegroundColor Green } else { Write-Host "    [X] ENABLE_IMAGE_GENERATION no esta en true" -ForegroundColor Red }
    if ($hasEngine) { Write-Host "    [OK] IMAGE_GENERATION_ENGINE=comfyui" -ForegroundColor Green } else { Write-Host "    [!] IMAGE_GENERATION_ENGINE=comfyui recomendado (evita OpenAI)" -ForegroundColor Yellow }
    if ($hasComfyUrl) { Write-Host "    [OK] COMFYUI_BASE_URL / IMAGE_GENERATION_API_URL apuntan a ComfyUI" -ForegroundColor Green } else { Write-Host "    [X] Falta COMFYUI_BASE_URL o IMAGE_GENERATION_API_URL" -ForegroundColor Red }
}
Write-Host ""

# 3. Pasos en la interfaz
Write-Host "[3] Configuracion en la interfaz (Admin > Settings > Images)" -ForegroundColor Yellow
Write-Host "    1. Abre: http://localhost:8082" -ForegroundColor White
Write-Host "    2. Admin Panel > Settings > Images" -ForegroundColor White
Write-Host "    3. Image Generation Engine: ComfyUI" -ForegroundColor White
Write-Host "    4. API URL: http://comfyui:8188/  (desde dentro de Docker) o la URL que use tu red)" -ForegroundColor White
Write-Host "    5. Activa 'Image Generation (Experimental)'" -ForegroundColor White
Write-Host "    6. Sube el workflow: extensions/open-webui-multimedia/workflow_api_flux.json" -ForegroundColor White
Write-Host "    7. Mapea nodos si la UI lo pide: prompt -> nodo 2 (text), dimensiones -> nodo 4" -ForegroundColor White
Write-Host "    8. Set Default Model: nombre de tu checkpoint (ej. flux1-schnell.safetensors)" -ForegroundColor White
Write-Host ""
Write-Host "    Workflow incluido en el proyecto: workflow_api_flux.json" -ForegroundColor Cyan
Write-Host "    Documentacion: CONFIGURAR_FLUX_COMFYUI_WEBUI.md" -ForegroundColor Cyan
Write-Host ""

Write-Host "=== Fin validacion ===" -ForegroundColor Cyan
Write-Host ""
