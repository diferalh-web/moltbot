# 🔧 Configurar SSH en la VM

## 🔍 Problema

La contraseña funciona en la VM pero no vía SSH. Esto significa que SSH necesita ser configurado para permitir autenticación por contraseña.

## ✅ Solución: Configurar SSH en la VM

**En la VM (desde VirtualBox, consola de la VM)**, ejecuta estos comandos:

### Paso 1: Verificar estado de SSH

```bash
sudo systemctl status ssh
```

Si no está corriendo:
```bash
sudo systemctl start ssh
sudo systemctl enable ssh
```

### Paso 2: Verificar configuración de autenticación

```bash
sudo grep -i "PasswordAuthentication" /etc/ssh/sshd_config
```

Si muestra `PasswordAuthentication no` o está comentado, necesitas habilitarlo.

### Paso 3: Habilitar autenticación por contraseña

```bash
# Hacer backup de la configuración
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Habilitar autenticación por contraseña
sudo sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Si no funcionó, editar manualmente
sudo nano /etc/ssh/sshd_config
```

**En nano, busca la línea:**
```
#PasswordAuthentication no
```
o
```
PasswordAuthentication no
```

**Cámbiala a:**
```
PasswordAuthentication yes
```

**Guarda:** `Ctrl+O`, `Enter`, `Ctrl+X`

### Paso 4: Reiniciar SSH

```bash
sudo systemctl restart ssh
sudo systemctl status ssh
```

Debe mostrar: `active (running)`

### Paso 5: Verificar que funciona

**Desde PowerShell en Windows**, intenta de nuevo:

```powershell
ssh moltbot@127.0.0.1 -p 2222
```

Ahora debería funcionar con tu contraseña.

## 🔧 Solución Alternativa: Verificar Usuario

A veces el problema es que el usuario no tiene permisos. Verifica:

```bash
# En la VM
whoami
id
groups
```

El usuario debe estar en el grupo `sudo`.

## 🔧 Solución Alternativa: Crear Clave SSH (sin contraseña)

Si prefieres no usar contraseña, puedes configurar claves SSH:

**En Windows (PowerShell):**

```powershell
# Generar clave SSH (si no tienes una)
ssh-keygen -t rsa -b 4096

# Copiar clave a la VM
ssh-copy-id -p 2222 moltbot@127.0.0.1
```

Luego podrás conectarte sin contraseña.

## ✅ Verificación Final

Después de configurar SSH, prueba:

```powershell
# Desde PowerShell
ssh moltbot@127.0.0.1 -p 2222 "echo 'SSH funciona correctamente'"
```

Deberías ver: "SSH funciona correctamente"

---

**Ejecuta los comandos del Paso 1-4 en la VM y luego intenta conectarte de nuevo desde Windows.**












