# 🚀 Configurar Moltbot - Método Simple

## ✅ Archivo Creado

He creado el archivo `openclaw.json` en tu directorio actual.

## 📋 Pasos a Ejecutar

### Opción 1: Transferir Archivo (Más Fácil)

**En PowerShell, ejecuta:**

```powershell
cd C:\code\moltbot
scp -P 2222 openclaw.json moltbot2@127.0.0.1:~/.openclaw/openclaw.json
```

Te pedirá la contraseña, ingrésala.

### Opción 2: Crear Directamente en la VM

**1. Conéctate a la VM:**
```powershell
ssh moltbot2@127.0.0.1 -p 2222
```

**2. En la VM, ejecuta:**
```bash
mkdir -p ~/.openclaw
nano ~/.openclaw/openclaw.json
```

**3. Pega este contenido:**
```json
{
  "models": {
    "llama2": {
      "provider": "ollama",
      "model": "llama2",
      "baseURL": "http://192.168.100.42:11435"
    }
  },
  "model": "llama2"
}
```

**4. Guarda:** `Ctrl+O`, `Enter`, `Ctrl+X`

**5. Verifica:**
```bash
cat ~/.openclaw/openclaw.json
```

## 🧪 Probar

**En la VM:**

```bash
# Probar conexión a Ollama
curl http://192.168.100.42:11435/api/tags

# Probar Moltbot
cd ~/moltbot
pnpm start agent --message "Hola, ¿cómo estás?" --local
```

---

**Recomiendo la Opción 1 (transferir archivo) - es la más rápida.**












