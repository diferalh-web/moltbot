# 🔧 Solucionar Problema de SSH

## 🔍 Diagnóstico

Estás recibiendo "Permission denied" cuando intentas conectarte vía SSH. Esto significa:
- ✅ La conexión SSH está funcionando (llega a pedir contraseña)
- ❌ La contraseña no es correcta o hay un problema de autenticación

## 🔑 Solución 1: Verificar Contraseña

### Opción A: Verificar en la VM directamente

1. **Abre VirtualBox**
2. **Abre la consola de la VM** `moltbot-vm` (haz doble clic o "Iniciar")
3. **Inicia sesión** con el usuario y contraseña que creaste durante la instalación
4. **Verifica el usuario:**
   ```bash
   whoami
   ```
   Debe mostrar: `moltbot` (o el usuario que creaste)

5. **Verifica que puedes iniciar sesión** con esa contraseña

### Opción B: Resetear contraseña (si la olvidaste)

Si olvidaste la contraseña, puedes resetearla:

1. **En la VM** (desde VirtualBox), cuando arranque, presiona `Esc` o `Shift` durante el arranque
2. **Selecciona** la opción de recuperación o modo de emergencia
3. **O simplemente inicia sesión** en la consola de VirtualBox y ejecuta:
   ```bash
   passwd moltbot
   ```
   Ingresa una nueva contraseña

## 🔧 Solución 2: Verificar Configuración SSH

**En la VM** (desde VirtualBox), ejecuta:

```bash
# Verificar que SSH está corriendo
sudo systemctl status ssh

# Si no está corriendo, iniciarlo
sudo systemctl start ssh
sudo systemctl enable ssh

# Verificar configuración
sudo cat /etc/ssh/sshd_config | grep -i "PasswordAuthentication"
```

Debe mostrar: `PasswordAuthentication yes`

Si muestra `no`, ejecuta:
```bash
sudo sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

## 🔧 Solución 3: Verificar Usuario y Permisos

**En la VM**, ejecuta:

```bash
# Verificar que el usuario existe
id moltbot

# Verificar que puede hacer sudo
sudo -l

# Verificar el directorio home
ls -la /home/moltbot
```

## 🔧 Solución 4: Probar Conexión con Usuario Root (temporal)

Si nada funciona, puedes probar con root (si está habilitado):

```bash
# En la VM, habilitar root (temporalmente)
sudo passwd root
# Ingresa una contraseña para root

# Desde Windows, intentar:
ssh root@127.0.0.1 -p 2222
```

**Luego deshabilita root por seguridad:**
```bash
sudo passwd -l root
```

## ✅ Verificación Final

Una vez que puedas conectarte, verifica:

```bash
# Desde PowerShell en Windows
ssh moltbot@127.0.0.1 -p 2222 "echo 'Conexion exitosa'"
```

Deberías ver: "Conexion exitosa"

## 🎯 Pasos Recomendados

1. **Abre la VM en VirtualBox** (consola)
2. **Inicia sesión** con tu usuario y contraseña
3. **Verifica que la contraseña funciona** en la consola
4. **Verifica SSH:**
   ```bash
   sudo systemctl status ssh
   sudo systemctl start ssh
   ```
5. **Intenta conectarte desde Windows** con la misma contraseña

## 🆘 Si Nada Funciona

**Crea un nuevo usuario en la VM:**

```bash
# En la VM (desde VirtualBox)
sudo adduser moltbot2
# Sigue las instrucciones para crear el usuario

# Agregar a sudoers
sudo usermod -aG sudo moltbot2

# Intentar conectarte con el nuevo usuario
# Desde Windows:
ssh moltbot2@127.0.0.1 -p 2222
```

---

**¿Puedes iniciar sesión en la VM desde VirtualBox?** Si sí, entonces el problema es solo con SSH. Si no, necesitas resetear la contraseña.












