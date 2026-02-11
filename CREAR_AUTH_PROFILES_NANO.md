# 📝 Crear auth-profiles.json con Nano

## ✅ Método con Nano (Más Fácil)

**Ejecuta estos comandos en la VM:**

```bash
# Crear directorio
mkdir -p ~/.openclaw/agents/main/agent

# Abrir nano
nano ~/.openclaw/agents/main/agent/auth-profiles.json
```

**En nano, escribe este contenido:**

```json
{
  "ollama": {
    "baseURL": "http://192.168.100.42:11435",
    "model": "llama2"
  }
}
```

**Para guardar y salir:**
1. Presiona `Ctrl+O` (guardar)
2. Presiona `Enter` (confirmar nombre de archivo)
3. Presiona `Ctrl+X` (salir)

## ✅ Verificar

```bash
cat ~/.openclaw/agents/main/agent/auth-profiles.json
```

Deberías ver el JSON que escribiste.

## 🧪 Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

---

**Nano es más fácil que vim porque muestra los comandos en la parte inferior de la pantalla.**












