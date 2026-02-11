# 📝 Crear auth-profiles.json con Vim

## ✅ Método con Vim

**Ejecuta estos comandos en la VM:**

```bash
# Crear directorio
mkdir -p ~/.openclaw/agents/main/agent

# Abrir vim
vim ~/.openclaw/agents/main/agent/auth-profiles.json
```

**En vim:**
1. Presiona `i` (modo inserción)
2. Escribe este contenido:

```json
{
  "ollama": {
    "baseURL": "http://192.168.100.42:11435",
    "model": "llama2"
  }
}
```

3. Presiona `Esc` (salir del modo inserción)
4. Escribe `:wq` y presiona `Enter` (guardar y salir)

## ✅ Verificar

```bash
cat ~/.openclaw/agents/main/agent/auth-profiles.json
```

## 🧪 Probar

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola" --local
```

---

**Nota: Vim es más complejo. Si no estás familiarizado, usa nano en su lugar.**












