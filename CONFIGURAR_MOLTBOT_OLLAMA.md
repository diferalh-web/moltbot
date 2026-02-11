# 🔗 Configurar Moltbot para Usar Ollama del Host

## ✅ Estado Actual

- ✅ Ollama para Moltbot corriendo en Docker (puerto 11435)
- ✅ IP del host: `192.168.100.42`
- ⏳ Pendiente: Configurar Moltbot en la VM

## 🚀 Configurar Moltbot en la VM

**En tu terminal SSH conectado a la VM**, ejecuta:

```bash
cd ~/moltbot

# Configurar Ollama del host como proveedor
pnpm start config set models.default.provider ollama
pnpm start config set models.default.model llama2
pnpm start config set models.default.baseURL http://192.168.100.42:11435
```

## 📥 Descargar Modelo en Ollama (desde Windows)

**En PowerShell de Windows**, ejecuta:

```powershell
# Descargar modelo (ejemplo: llama2)
docker exec -it ollama-moltbot ollama pull llama2

# Ver modelos instalados
docker exec -it ollama-moltbot ollama list
```

**Modelos recomendados:**
- `llama2` - Modelo general bueno
- `mistral` - Rápido y eficiente  
- `codellama` - Especializado en código
- `llama3` - Última versión (si está disponible)

## 🧪 Probar la Conexión

**En la VM (vía SSH):**

```bash
# Probar que Ollama es accesible desde la VM
curl http://192.168.100.42:11435/api/tags

# Si funciona, verás una lista de modelos (puede estar vacía si no has descargado ninguno)
```

**Luego probar con Moltbot:**

```bash
cd ~/moltbot
pnpm start agent --message "Hola, ¿cómo estás?" --local
```

## 🔧 Verificar Configuración

```bash
# Ver configuración actual de modelos
pnpm start config get models

# Ver estado de salud
pnpm start health
```

## 🆘 Solución de Problemas

### No puedo conectar desde la VM

**Verificar en Windows:**
```powershell
# Verificar que el contenedor está corriendo
docker ps | findstr ollama-moltbot

# Verificar que el puerto está abierto
netstat -an | findstr 11435
```

**Verificar en la VM:**
```bash
# Probar conectividad
ping 192.168.100.42

# Probar puerto
curl http://192.168.100.42:11435/api/tags
```

### Firewall bloquea la conexión

**En Windows (PowerShell como Administrador):**
```powershell
# Verificar regla de firewall
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Ollama*"}

# Crear regla si no existe
New-NetFirewallRule -DisplayName "Ollama Moltbot" -Direction Inbound -LocalPort 11435 -Protocol TCP -Action Allow
```

### Cambiar de modelo

```bash
# Cambiar modelo en Moltbot
pnpm start config set models.default.model mistral

# O usar modelo específico al ejecutar
pnpm start agent --model llama2 --message "Hola"
```

## 📝 Resumen de Configuración

- **Contenedor Docker**: `ollama-moltbot`
- **Puerto**: `11435` (diferente al de anails_ollama que usa 11434)
- **IP del Host**: `192.168.100.42`
- **URL para Moltbot**: `http://192.168.100.42:11435`

---

**Ahora configura Moltbot en la VM con los comandos de arriba.**












