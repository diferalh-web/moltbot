# 🔧 Corregir Error de Sintaxis en JSON

## ❌ Error Detectado

```
Expecting value: line 8 column 18 (char 152)
```

Hay un error de sintaxis en la línea 8, columna 18 del archivo.

## ✅ Solución: Ver y Corregir el Archivo

### Paso 1: Ver el Contenido Actual

```bash
cat ~/.openclaw/agents/main/agent/auth-profiles.json
```

### Paso 2: Identificar el Error

**Errores comunes:**
- Coma faltante o extra
- Comillas mal cerradas
- Llaves o corchetes mal cerrados
- Valores sin comillas donde se requieren

### Paso 3: Corregir el Archivo

```bash
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Reemplaza TODO el contenido con este JSON válido:**

```json
{
  "version": 1,
  "profiles": {
    "ollama:default": {
      "type": "api_key",
      "provider": "ollama",
      "key": "ollama",
      "baseURL": "http://192.168.100.42:11435",
      "model": "llama2"
    },
    "synthetic:default": {
      "type": "api_key",
      "provider": "synthetic",
      "key": "ollama",
      "baseURL": "http://192.168.100.42:11435",
      "model": "llama2"
    }
  },
  "lastGood": {
    "ollama": "ollama:default"
  },
  "usageStats": {}
}
```

**Importante:**
- Todas las comillas son dobles `"`
- Todas las comas están en el lugar correcto
- Todas las llaves están cerradas

Guarda: `Ctrl+O`, `Enter`, `Ctrl+X`

### Paso 4: Validar de Nuevo

```bash
cat ~/.openclaw/agents/main/agent/auth-profiles.json | python3 -m json.tool
```

Si está bien, mostrará el JSON formateado sin errores.

### Paso 5: Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

---

**Primero ejecuta `cat` para ver el contenido actual y compartirlo, o reemplaza todo el contenido con el JSON válido de arriba.**












