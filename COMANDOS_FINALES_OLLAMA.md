# ✅ Comandos Finales - Ollama para Moltbot

## ✅ Estado Actual

- ✅ Contenedor `ollama-moltbot` creado y corriendo
- ✅ Puerto: `11435`
- ✅ IP del host: `192.168.100.42`
- ⏳ Pendiente: Configurar firewall y descargar modelo

## 🔧 Paso 1: Configurar Firewall (Requiere Administrador)

**Abre PowerShell como Administrador** y ejecuta:

```powershell
netsh advfirewall firewall add rule name="Ollama Moltbot" dir=in action=allow protocol=TCP localport=11435
```

O manualmente:
1. **Windows Defender Firewall → Configuración avanzada**
2. **Reglas de entrada → Nueva regla**
3. **Puerto → TCP → 11435**
4. **Permitir conexión**
5. **Aplicar a todos los perfiles**

## 📥 Paso 2: Descargar Modelo en Ollama

**En PowerShell de Windows** (normal, no necesita admin):

```powershell
# Descargar modelo llama2
docker exec ollama-moltbot ollama pull llama2

# Ver modelos instalados
docker exec ollama-moltbot ollama list
```

**Modelos recomendados:**
- `llama2` - Modelo general
- `mistral` - Rápido y eficiente
- `codellama` - Especializado en código

## 🔗 Paso 3: Configurar Moltbot en la VM

**En tu terminal SSH conectado a la VM**, ejecuta:

```bash
cd ~/moltbot

# Configurar Ollama del host
pnpm start config set models.default.provider ollama
pnpm start config set models.default.model llama2
pnpm start config set models.default.baseURL http://192.168.100.42:11435
```

## 🧪 Paso 4: Probar Conexión

**En la VM (vía SSH):**

```bash
# Probar que Ollama es accesible
curl http://192.168.100.42:11435/api/tags

# Si funciona, probar con Moltbot
cd ~/moltbot
pnpm start agent --message "Hola" --local
```

## 📋 Resumen de Configuración

- **Contenedor**: `ollama-moltbot`
- **Puerto**: `11435` (separado de anails_ollama en 11434)
- **IP Host**: `192.168.100.42`
- **URL para Moltbot**: `http://192.168.100.42:11435`

---

**Ejecuta los pasos 1-3 y luego prueba la conexión desde la VM.**












