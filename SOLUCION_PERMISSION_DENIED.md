# 🔧 Solución Completa para Permission Denied

## 🔍 Diagnóstico Completo

Si aún recibes "Permission denied" después de configurar PasswordAuthentication, hay otras causas posibles.

## ✅ Solución 1: Verificar y Reiniciar SSH Correctamente

**En la VM**, ejecuta estos comandos en orden:

```bash
# Verificar configuración actual
sudo grep -i "PasswordAuthentication" /etc/ssh/sshd_config

# Verificar otras configuraciones que pueden bloquear
sudo grep -i "PermitRootLogin\|PubkeyAuthentication\|ChallengeResponseAuthentication" /etc/ssh/sshd_config

# Reiniciar SSH completamente
sudo systemctl stop ssh
sudo systemctl start ssh
sudo systemctl status ssh
```

## ✅ Solución 2: Verificar Usuario y Permisos

**En la VM**, verifica:

```bash
# Verificar que el usuario existe
id moltbot

# Verificar grupos
groups moltbot

# Verificar directorio home
ls -la /home/moltbot

# Verificar permisos del directorio home
stat /home/moltbot
```

El directorio home debe tener permisos `755` o `700`.

## ✅ Solución 3: Habilitar Todas las Opciones de Autenticación

**En la VM**, edita el archivo SSH:

```bash
sudo nano /etc/ssh/sshd_config
```

**Asegúrate de que estas líneas estén así:**

```
PasswordAuthentication yes
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
PermitRootLogin no
```

**Guarda y reinicia:**
```bash
sudo systemctl restart ssh
```

## ✅ Solución 4: Verificar Logs de SSH

**En la VM**, revisa los logs para ver el error exacto:

```bash
# Ver logs en tiempo real
sudo tail -f /var/log/auth.log

# O en algunos sistemas:
sudo journalctl -u ssh -f
```

**Luego intenta conectarte desde Windows** y verás el error exacto en los logs.

## ✅ Solución 5: Crear Nuevo Usuario (Solución Definitiva)

Si nada funciona, crea un nuevo usuario:

**En la VM:**

```bash
# Crear nuevo usuario
sudo adduser moltbot2

# Agregar a sudoers
sudo usermod -aG sudo moltbot2

# Verificar que puede hacer sudo
sudo -u moltbot2 sudo -l
```

**Luego intenta conectarte con el nuevo usuario:**

```powershell
# Desde Windows
ssh moltbot2@127.0.0.1 -p 2222
```

## ✅ Solución 6: Verificar Firewall (si aplica)

**En la VM:**

```bash
# Verificar si hay firewall activo
sudo ufw status

# Si está activo, permitir SSH
sudo ufw allow ssh
sudo ufw allow 22/tcp
```

## ✅ Solución 7: Probar con Verbose para Ver el Error Exacto

**Desde PowerShell en Windows:**

```powershell
ssh -v moltbot@127.0.0.1 -p 2222
```

El modo verbose (`-v`) mostrará información detallada del error.

## 🎯 Pasos Recomendados (en orden)

1. **Ejecuta Solución 1** (verificar y reiniciar SSH)
2. **Ejecuta Solución 3** (habilitar todas las opciones)
3. **Ejecuta Solución 4** (ver logs mientras intentas conectar)
4. **Si nada funciona, Solución 5** (crear nuevo usuario)

## 🔍 Verificación Final

**En la VM**, ejecuta este comando completo para verificar todo:

```bash
echo "=== Configuración SSH ==="
sudo grep -E "PasswordAuthentication|PubkeyAuthentication|UsePAM" /etc/ssh/sshd_config | grep -v "^#"
echo ""
echo "=== Estado SSH ==="
sudo systemctl status ssh --no-pager | head -10
echo ""
echo "=== Usuario ==="
id moltbot
echo ""
echo "=== Permisos Home ==="
ls -ld /home/moltbot
```

---

**Empieza con la Solución 1 y 3, luego revisa los logs (Solución 4) para ver el error exacto.**












