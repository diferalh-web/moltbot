# 🐳 Conectar Moltbot (VM) a Ollama (Docker en PC Host)

## 📋 Resumen

Esta configuración permite que:
- **Ollama** corra en Docker en tu PC Windows (host)
- **Moltbot** corra en la VM (VirtualBox)
- Ambos se comuniquen a través de la red

## 🔧 Paso 1: Configurar Docker en Windows para Exponer Ollama

### Opción A: Docker Desktop (Recomendado)

**En tu PC Windows**, ejecuta Ollama:

```powershell
# Crear directorio para datos
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\ollama-data"

# Ejecutar Ollama en Docker
docker run -d `
  --name ollama `
  -p 11434:11434 `
  -v "$env:USERPROFILE\ollama-data:/root/.ollama" `
  --restart unless-stopped `
  ollama/ollama:latest
```

**IMPORTANTE:** Docker Desktop por defecto expone los puertos en `localhost`. Necesitas configurarlo para que sea accesible desde la red.

### Opción B: Configurar Docker para Acceso de Red

Si Docker Desktop no permite conexiones externas, necesitas:

1. **Abrir Docker Desktop**
2. **Settings → General → Expose daemon on tcp://localhost:2375 without TLS** (NO recomendado para producción)
3. **O mejor: Configurar firewall de Windows**

## 🔧 Paso 2: Configurar Red de VirtualBox

### Opción A: Red Bridge (Recomendado)

1. **Apaga la VM** en VirtualBox
2. **Configuración → Red → Adaptador 1**
3. **Cambia de "NAT" a "Adaptador puente"**
4. **Selecciona** tu adaptador de red (WiFi o Ethernet)
5. **Inicia la VM**

Ahora la VM tendrá una IP en tu red local (ej: `192.168.1.100`)

### Opción B: NAT con Port Forwarding

Si prefieres mantener NAT:

1. **Apaga la VM**
2. **Configuración → Red → Adaptador 1 → Avanzado → Reenvío de puertos**
3. **Agrega regla:**
   - Nombre: `ollama`
   - Protocolo: TCP
   - IP del anfitrión: `127.0.0.1`
   - Puerto del anfitrión: `11434`
   - IP del invitado: (deja vacío)
   - Puerto del invitado: `11434`

## 🔍 Paso 3: Obtener IP del Host desde la VM

**En tu PC Windows**, obtén tu IP local:

```powershell
# Ver IP de tu PC
ipconfig | findstr "IPv4"
```

Anota la IP (ej: `192.168.1.50`)

**O desde la VM**, puedes encontrar la IP del host:

```bash
# Si usas Bridge, el host generalmente es el gateway
ip route | grep default
# O
hostname -I
# El host suele ser la IP del router o una IP cercana
```

## 🦙 Paso 4: Verificar que Ollama es Accesible desde la VM

**En la VM (vía SSH)**, ejecuta:

```bash
# Reemplaza IP_HOST con la IP de tu PC Windows
# Ejemplo: curl http://192.168.1.50:11434/api/tags

# Primero, prueba desde la VM
curl http://IP_DE_TU_PC_WINDOWS:11434/api/tags
```

Si funciona, verás una lista de modelos (puede estar vacía si no has descargado ninguno).

## 🔧 Paso 5: Configurar Firewall de Windows

**En tu PC Windows (como Administrador)**, ejecuta:

```powershell
# Permitir puerto 11434 en el firewall
New-NetFirewallRule -DisplayName "Ollama Docker" -Direction Inbound -LocalPort 11434 -Protocol TCP -Action Allow
```

O manualmente:
1. **Windows Defender Firewall → Configuración avanzada**
2. **Reglas de entrada → Nueva regla**
3. **Puerto → TCP → 11434**
4. **Permitir conexión**
5. **Aplicar a todos los perfiles**

## 🚀 Paso 6: Configurar Moltbot para Usar Ollama del Host

**En la VM (vía SSH)**, ejecuta:

```bash
cd ~/moltbot

# Configurar Moltbot para usar la IP del host
pnpm start config set models.default.provider ollama
pnpm start config set models.default.model llama2
pnpm start config set models.default.baseURL http://IP_DE_TU_PC_WINDOWS:11434
# Ejemplo: http://192.168.1.50:11434
```

## 📥 Paso 7: Descargar Modelos en Ollama (desde Windows)

**En tu PC Windows**, ejecuta:

```powershell
# Descargar modelo
docker exec -it ollama ollama pull llama2

# Ver modelos instalados
docker exec -it ollama ollama list
```

## 🧪 Paso 8: Probar la Conexión

**En la VM**, ejecuta:

```bash
# Probar conexión directa
curl http://IP_DE_TU_PC_WINDOWS:11434/api/tags

# Probar con Moltbot
cd ~/moltbot
pnpm start agent --message "Hola" --local
```

## 🔧 Configuración Alternativa: Usar Hostname

Si prefieres usar un nombre en lugar de IP:

### En Windows:
1. **Configuración → Sistema → Acerca de → Nombre del dispositivo**
2. Anota el nombre (ej: `DESKTOP-ABC123`)

### En la VM:
```bash
# Agregar entrada al /etc/hosts (si es necesario)
echo "IP_DE_TU_PC_WINDOWS  windows-host" | sudo tee -a /etc/hosts

# Usar en configuración
pnpm start config set models.default.baseURL http://windows-host:11434
```

## 🆘 Solución de Problemas

### No puedo conectar desde la VM

**Verificar en Windows:**
```powershell
# Verificar que Docker está corriendo
docker ps | findstr ollama

# Verificar que el puerto está abierto
netstat -an | findstr 11434
```

**Verificar en la VM:**
```bash
# Probar conectividad
ping IP_DE_TU_PC_WINDOWS

# Probar puerto
telnet IP_DE_TU_PC_WINDOWS 11434
# O
nc -zv IP_DE_TU_PC_WINDOWS 11434
```

### Firewall bloquea la conexión

**En Windows:**
```powershell
# Verificar reglas de firewall
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Ollama*"}

# Si no existe, crear la regla (ver Paso 5)
```

### Docker Desktop no expone el puerto

**Solución:**
1. Verifica que el contenedor está corriendo: `docker ps`
2. Verifica que el puerto está mapeado: `docker port ollama`
3. Prueba desde Windows: `curl http://localhost:11434/api/tags`

## 📝 Resumen de IPs

- **IP de tu PC Windows**: `192.168.1.50` (ejemplo - obtén la real con `ipconfig`)
- **IP de la VM**: `192.168.1.100` (ejemplo - si usas Bridge)
- **Puerto de Ollama**: `11434`

**Moltbot en la VM se conectará a**: `http://IP_DE_TU_PC_WINDOWS:11434`

---

**Sigue los pasos en orden. La clave es configurar el firewall de Windows y usar la IP correcta del host.**












