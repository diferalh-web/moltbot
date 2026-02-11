# 🚀 Crear Configuración con Echo (Más Simple)

## ✅ Método Alternativo - Usando Echo

**En tu terminal SSH, ejecuta estos comandos uno por uno:**

```bash
mkdir -p ~/.openclaw
```

Luego ejecuta este comando completo (copia toda la línea):

```bash
echo '{"models":{"llama2":{"provider":"ollama","model":"llama2","baseURL":"http://192.168.100.42:11435"}},"model":"llama2"}' > ~/.openclaw/openclaw.json
```

**O si prefieres, ejecuta línea por línea:**

```bash
echo '{' > ~/.openclaw/openclaw.json
echo '  "models": {' >> ~/.openclaw/openclaw.json
echo '    "llama2": {' >> ~/.openclaw/openclaw.json
echo '      "provider": "ollama",' >> ~/.openclaw/openclaw.json
echo '      "model": "llama2",' >> ~/.openclaw/openclaw.json
echo '      "baseURL": "http://192.168.100.42:11435"' >> ~/.openclaw/openclaw.json
echo '    }' >> ~/.openclaw/openclaw.json
echo '  },' >> ~/.openclaw/openclaw.json
echo '  "model": "llama2"' >> ~/.openclaw/openclaw.json
echo '}' >> ~/.openclaw/openclaw.json
```

### Verificar:
```bash
cat ~/.openclaw/openclaw.json
```

---

**Este método es más fácil porque puedes escribir los comandos directamente.**












