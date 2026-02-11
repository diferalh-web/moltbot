# 🔧 Comando de Firewall Corregido

## ❌ Error

El comando tenía una barra invertida `\` al final que causaba el error.

## ✅ Comando Correcto

**Ejecuta este comando en PowerShell como Administrador:**

```powershell
netsh advfirewall firewall add rule name="Ollama Moltbot" dir=in action=allow protocol=TCP localport=11435
```

**O este formato alternativo:**

```powershell
netsh advfirewall firewall add rule name="Ollama Moltbot" dir=in protocol=TCP localport=11435 action=allow
```

## ✅ Verificar que se Creó

Después de ejecutar, verifica con:

```powershell
Get-NetFirewallRule -DisplayName "Ollama Moltbot"
```

Deberías ver la regla listada.

## 🔄 Si Aún Da Error

**Opción 1: Usar New-NetFirewallRule (PowerShell moderno)**

```powershell
New-NetFirewallRule -DisplayName "Ollama Moltbot" -Direction Inbound -LocalPort 11435 -Protocol TCP -Action Allow
```

**Opción 2: Configuración Manual**

1. Abre **Windows Defender Firewall con seguridad avanzada**
2. Click derecho en **Reglas de entrada** → **Nueva regla**
3. Selecciona **Puerto** → Siguiente
4. Selecciona **TCP** y escribe `11435` → Siguiente
5. Selecciona **Permitir la conexión** → Siguiente
6. Marca todos los perfiles → Siguiente
7. Nombre: `Ollama Moltbot` → Finalizar

---

**Ejecuta el comando corregido y avísame si funciona.**












