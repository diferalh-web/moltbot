# Script para verificar y configurar Knowledge Base en Open WebUI
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configuración de Knowledge Base (RAG)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Open WebUI
Write-Host "[1/3] Verificando Open WebUI..." -ForegroundColor Yellow
$webui = docker ps --filter "name=open-webui" --format "{{.Names}}" 2>$null
if (-not $webui) {
    Write-Host "[✗] Open WebUI no está corriendo" -ForegroundColor Red
    Write-Host "    Inicia Open WebUI primero" -ForegroundColor Yellow
    exit 1
}
Write-Host "[✓] Open WebUI está corriendo" -ForegroundColor Green
Write-Host ""

# Verificar base de datos
Write-Host "[2/3] Verificando base de datos..." -ForegroundColor Yellow
$dbPath = "${env:USERPROFILE}\open-webui-data\webui.db"
if (Test-Path $dbPath) {
    Write-Host "[✓] Base de datos encontrada: $dbPath" -ForegroundColor Green
    
    # Verificar tabla knowledge
    $hasKnowledge = docker exec open-webui python3 -c "import sqlite3; conn = sqlite3.connect('/app/backend/data/webui.db'); cursor = conn.cursor(); cursor.execute(\"SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%knowledge%'\"); print('YES' if cursor.fetchone() else 'NO')" 2>$null
    
    if ($hasKnowledge -eq "YES") {
        Write-Host "[✓] Tabla de Knowledge Base encontrada" -ForegroundColor Green
    } else {
        Write-Host "[ℹ] Tabla de Knowledge Base no encontrada (se creará automáticamente)" -ForegroundColor Yellow
    }
} else {
    Write-Host "[ℹ] Base de datos se creará al iniciar Open WebUI" -ForegroundColor Yellow
}
Write-Host ""

# Instrucciones
Write-Host "[3/3] Instrucciones de configuración:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Abre Open WebUI:" -ForegroundColor White
Write-Host "   http://localhost:8082" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Habilita Knowledge Base:" -ForegroundColor White
Write-Host "   - Ve a Settings (⚙️) → Features" -ForegroundColor Gray
Write-Host "   - Habilita 'Knowledge Base' o 'Document Upload'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Crea una Knowledge Base:" -ForegroundColor White
Write-Host "   - En el menú lateral, busca 'Knowledge' o 'Knowledge Base'" -ForegroundColor Gray
Write-Host "   - Haz clic en 'Create Knowledge Base' o '+'" -ForegroundColor Gray
Write-Host "   - Asigna un nombre (ej: 'Mi Base de Conocimiento')" -ForegroundColor Gray
Write-Host "   - Selecciona el modelo para embeddings" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Sube documentos:" -ForegroundColor White
Write-Host "   - Abre tu Knowledge Base" -ForegroundColor Gray
Write-Host "   - Haz clic en 'Upload' o arrastra archivos" -ForegroundColor Gray
Write-Host "   - Formatos soportados: PDF, TXT, MD, DOCX, código fuente" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Usa en chat:" -ForegroundColor White
Write-Host "   - Inicia un nuevo chat" -ForegroundColor Gray
Write-Host "   - Selecciona tu Knowledge Base en el selector" -ForegroundColor Gray
Write-Host "   - Haz preguntas relacionadas con tus documentos" -ForegroundColor Gray
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "[✓] Configuración lista" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para más información, consulta:" -ForegroundColor Yellow
Write-Host "  GUIA_USO_MULTIMEDIA_Y_RAG.md" -ForegroundColor White
Write-Host ""









