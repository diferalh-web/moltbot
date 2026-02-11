# 🔍 Diagnóstico Completo de SSH - Permission Denied

## 🔴 Problema

Incluso con un nuevo usuario, recibes "Permission denied". Esto indica un problema más profundo con SSH o la configuración del sistema.

## ✅ Diagnóstico Paso a Paso

### Paso 1: Verificar que SSH está realmente escuchando

**En la VM**, ejecuta:

```bash
# Verificar que SSH está corriendo
sudo systemctl status ssh

# Verificar en qué puerto está escuchando
sudo netstat -tlnp | grep ssh
# O
sudo ss -tlnp | grep ssh
```

Debe mostrar algo como: `0.0.0.0:22` o `:::22`

### Paso 2: Verificar configuración SSH completa

**En la VM**, ejecuta:

```bash
# Ver toda la configuración relevante
sudo grep -E "PasswordAuthentication|PubkeyAuthentication|UsePAM|PermitRootLogin|ChallengeResponseAuthentication" /etc/ssh/sshd_config
```

**Asegúrate de que esté así:**
```
PasswordAuthentication yes
PubkeyAuthentication yes
UsePAM yes
PermitRootLogin no
ChallengeResponseAuthentication no
```

### Paso 3: Verificar PAM (Pluggable Authentication Modules)

**En la VM**, verifica:

```bash
# Verificar configuración PAM para SSH
cat /etc/pam.d/sshd | grep -v "^#"
```

No debe tener líneas que bloqueen la autenticación.

### Paso 4: Ver logs en tiempo real (MUY IMPORTANTE)

**En la VM**, ejecuta:

```bash
sudo tail -f /var/log/auth.log
```

**En otra ventana de PowerShell en Windows**, intenta conectarte:

```powershell
ssh -v moltbot2@127.0.0.1 -p 2222
```

**Observa los logs en la VM** - te dirán EXACTAMENTE por qué falla.

### Paso 5: Verificar Port Forwarding de VirtualBox

El problema puede estar en VirtualBox, no en SSH.

**En Windows (PowerShell como Administrador):**

```powershell
# Verificar que el port forwarding está configurado
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" showvminfo moltbot-vm | Select-String "ssh"
```

**O verificar manualmente en VirtualBox:**
1. Abre VirtualBox
2. Selecciona `moltbot-vm` (apagada)
3. Configuración → Red → Adaptador 1 → Avanzado → Reenvío de puertos
4. Debe haber una regla: `ssh, TCP, 127.0.0.1, 2222, , 22`

### Paso 6: Probar conexión directa (si usas Bridge)

Si cambiaste la red a "Adaptador puente", obtén la IP directa:

**En la VM:**
```bash
hostname -I
```

**Desde Windows:**
```powershell
ssh moltbot2@IP_DE_LA_VM
# Sin el -p 2222
```

### Paso 7: Verificar que el usuario puede iniciar sesión localmente

**En la VM**, verifica:

```bash
# Cambiar al nuevo usuario
su - moltbot2
# Ingresa la contraseña

# Si funciona, verifica:
whoami
pwd
exit
```

### Paso 8: Reiniciar SSH completamente

**En la VM:**

```bash
# Detener SSH
sudo systemctl stop ssh

# Verificar que no hay procesos
sudo ps aux | grep sshd

# Iniciar SSH
sudo systemctl start ssh

# Verificar estado
sudo systemctl status ssh
```

### Paso 9: Verificar firewall (si hay)

**En la VM:**

```bash
# Verificar UFW
sudo ufw status

# Si está activo, permitir SSH
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw reload
```

### Paso 10: Probar con modo debug de SSH

**En la VM**, inicia SSH en modo debug:

```bash
# Detener servicio SSH
sudo systemctl stop ssh

# Iniciar SSH manualmente en modo debug
sudo /usr/sbin/sshd -d -p 22
```

**En otra ventana de PowerShell**, intenta conectarte. Verás mensajes de debug detallados.

## 🎯 Solución Más Probable

Basado en el problema, la causa más probable es:

### Opción A: Port Forwarding de VirtualBox

**Solución:**

1. **Apaga la VM** en VirtualBox
2. **Configuración → Red → Adaptador 1 → Avanzado → Reenvío de puertos**
3. **Elimina** la regla SSH existente
4. **Agrega nueva regla:**
   - Nombre: `ssh`
   - Protocolo: `TCP`
   - IP del anfitrión: `127.0.0.1`
   - Puerto del anfitrión: `2222`
   - IP del invitado: (deja vacío)
   - Puerto del invitado: `22`
5. **Guarda** y reinicia la VM

### Opción B: Cambiar a Red Bridge

**Solución:**

1. **Apaga la VM**
2. **Configuración → Red → Adaptador 1**
3. **Cambia de "NAT" a "Adaptador puente"**
4. **Selecciona** tu adaptador de red
5. **Inicia la VM**
6. **Obtén la IP:** `hostname -I` en la VM
7. **Conéctate:** `ssh moltbot2@IP_DE_LA_VM` (sin `-p 2222`)

## 🔧 Comando de Verificación Completa

**En la VM**, ejecuta este bloque completo:

```bash
echo "=== Estado SSH ==="
sudo systemctl status ssh --no-pager | head -10
echo ""
echo "=== Puerto SSH ==="
sudo ss -tlnp | grep :22
echo ""
echo "=== Configuración SSH ==="
sudo grep -E "PasswordAuthentication|PubkeyAuthentication|UsePAM" /etc/ssh/sshd_config | grep -v "^#"
echo ""
echo "=== Usuario ==="
id moltbot2
echo ""
echo "=== Logs recientes ==="
sudo tail -20 /var/log/auth.log
```

---

**Empieza con el Paso 4 (logs en tiempo real) para ver el error exacto, o prueba la Opción B (Bridge) que suele resolver estos problemas.**












