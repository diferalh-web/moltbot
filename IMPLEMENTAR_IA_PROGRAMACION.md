# Implementar IA de Programación (DeepSeek-Coder)

## Descripción

Configuración de Ollama-Code con modelos especializados en programación, arquitectura de software, seguridad, ethical hacking, cloud computing e IA.

## Modelos Disponibles

### DeepSeek-Coder (33B) - Recomendado
- **Especialidades**: Java, Python, SQL, arquitectura de software, seguridad, ethical hacking, cloud computing (AWS/Azure/GCP), DevOps, IA/ML
- **Ventajas**: Mejor rendimiento que CodeLlama en tareas complejas, entiende contexto empresarial
- **Requisitos**: ~20GB espacio, ~8-10GB VRAM, ~32GB RAM

### WizardCoder (34B)
- **Especialidades**: Seguridad, ethical hacking, análisis de código
- **Ventajas**: Excelente para tareas de seguridad y auditoría
- **Requisitos**: ~20GB espacio, ~8-10GB VRAM, ~32GB RAM

### CodeLlama (34B)
- **Especialidades**: Programación general, múltiples lenguajes
- **Ventajas**: Más rápido, menor consumo VRAM que DeepSeek
- **Requisitos**: ~20GB espacio, ~6-8GB VRAM, ~32GB RAM

## Instalación

### Paso 1: Ejecutar Script de Configuración

```powershell
cd C:\code\moltbot
.\scripts\setup-coder-llm.ps1
```

Este script:
- Crea el contenedor `ollama-code` en el puerto 11438
- Configura GPU NVIDIA
- Configura firewall
- Verifica el estado

### Paso 2: Descargar Modelos

```powershell
# Descargar DeepSeek-Coder (recomendado)
docker exec ollama-code ollama pull deepseek-coder:33b

# Descargar WizardCoder (seguridad)
docker exec ollama-code ollama pull wizardcoder:34b

# Descargar CodeLlama (alternativa ligera)
docker exec ollama-code ollama pull codellama:34b
```

**Nota**: Cada modelo tarda 30-60 minutos en descargarse dependiendo de tu conexión.

### Paso 3: Verificar Instalación

```powershell
# Ver modelos instalados
docker exec ollama-code ollama list

# Probar API
curl http://localhost:11438/api/tags
```

## Uso

### Desde Open WebUI

1. Abre `http://localhost:8082`
2. En el selector de modelo, busca:
   - `deepseek-coder:33b`
   - `wizardcoder:34b`
   - `codellama:34b`
3. Selecciona el modelo deseado
4. Haz preguntas sobre programación, arquitectura, seguridad, etc.

### Ejemplos de Prompts

**Programación:**
```
Escribe una función en Python que calcule el factorial de un número usando recursión.
```

**Arquitectura:**
```
Diseña una arquitectura de microservicios para un e-commerce usando AWS.
```

**Seguridad:**
```
Analiza este código Java y encuentra vulnerabilidades de seguridad:
[pegar código]
```

**Cloud Computing:**
```
¿Cómo configurar un pipeline CI/CD en Azure DevOps para una aplicación .NET?
```

**Ethical Hacking:**
```
Explica cómo funciona un ataque de SQL injection y cómo prevenirlo.
```

## Integración con Open WebUI

El modelo está automáticamente disponible en Open WebUI después de ejecutar `configure-open-webui-extended.ps1`.

## Solución de Problemas

### Error: "Out of memory"
- **Solución**: Usa modelos más pequeños o cierra otros servicios que usen GPU

### Error: "Model not found"
- **Solución**: Verifica que el modelo se descargó correctamente:
  ```powershell
  docker exec ollama-code ollama list
  ```

### Error: "Connection refused"
- **Solución**: Verifica que el contenedor está corriendo:
  ```powershell
  docker ps | findstr ollama-code
  ```

## Recursos

- **Puerto**: 11438
- **API Base**: `http://localhost:11438`
- **Documentación Ollama**: https://ollama.ai
- **DeepSeek-Coder**: https://github.com/deepseek-ai/DeepSeek-Coder












