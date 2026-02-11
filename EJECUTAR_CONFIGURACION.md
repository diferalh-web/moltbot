# 🚀 Ejecutar Configuración de Moltbot con Ollama

## ✅ Estado Actual

- ✅ Contenedor `ollama-moltbot` corriendo
- ✅ Modelo `llama2` instalado
- ⏳ Pendiente: Configurar firewall y Moltbot

## 🔧 Paso 1: Configurar Firewall (Requiere Admin)

**Abre PowerShell como Administrador** y ejecuta:

```powershell
netsh advfirewall firewall add rule name="Ollama Moltbot" dir=in action=allow protocol=TCP localport=11435
```

O ejecuta el script automático:

```powershell
cd C:\code\moltbot
powershell -ExecutionPolicy Bypass -File .\scripts\configurar-moltbot-ollama.ps1
```

## 🔗 Paso 2: Configurar Moltbot en la VM

**Opción A: Ejecutar comando completo (copia y pega en PowerShell):**

```powershell
ssh moltbot2@127.0.0.1 -p 2222 "cd ~/moltbot && pnpm start config set models.default.provider ollama && pnpm start config set models.default.model llama2 && pnpm start config set models.default.baseURL http://192.168.100.42:11435 && echo 'Configuracion completada'"
```

**Opción B: Ejecutar comandos uno por uno en SSH:**

Conéctate a la VM:
```powershell
ssh moltbot2@127.0.0.1 -p 2222
```

Luego ejecuta:
```bash
cd ~/moltbot
pnpm start config set models.default.provider ollama
pnpm start config set models.default.model llama2
pnpm start config set models.default.baseURL http://192.168.100.42:11435
```

## 🧪 Paso 3: Probar Conexión

**En la VM (vía SSH):**

```bash
# Probar que Ollama es accesible
curl http://192.168.100.42:11435/api/tags

# Si funciona, deberías ver una lista con llama2
```

**Luego probar con Moltbot:**

```bash
cd ~/moltbot
pnpm start agent --message "Hola, ¿cómo estás?" --local
```

## 📋 Resumen de Configuración

- **Contenedor**: `ollama-moltbot`
- **Puerto**: `11435`
- **IP Host**: `192.168.100.42`
- **URL**: `http://192.168.100.42:11435`
- **Modelo**: `llama2`

## 🆘 Solución de Problemas

### No puedo conectarme desde la VM

**Verificar en Windows:**
```powershell
docker ps | findstr ollama-moltbot
netstat -an | findstr 11435
```

**Verificar en la VM:**
```bash
ping 192.168.100.42
curl http://192.168.100.42:11435/api/tags
```

### Firewall bloquea la conexión

**En PowerShell como Administrador:**
```powershell
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Ollama*"}
```

Si no existe, créala manualmente o ejecuta el comando de arriba.

---

**Ejecuta los pasos 1-3 y avísame si todo funciona correctamente.**












