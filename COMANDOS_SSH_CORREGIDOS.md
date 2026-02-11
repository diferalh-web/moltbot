# 🔧 Comandos SSH Corregidos

## ❌ Problema

El comando con comillas simples anidadas causa error:
```bash
sudo sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
```

Error: `sed: -e expression #1, char 30: unterminated 's' command`

## ✅ Solución: Usar Comillas Dobles

**Ejecuta estos comandos EN LA VM** (uno por uno):

### Opción 1: Usar comillas dobles (recomendado)

```bash
sudo sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
```

### Opción 2: Editar manualmente (más seguro)

```bash
sudo nano /etc/ssh/sshd_config
```

**En nano:**
1. Busca la línea: `#PasswordAuthentication no` o `PasswordAuthentication no`
2. Cámbiala a: `PasswordAuthentication yes`
3. Guarda: `Ctrl+O`, `Enter`, `Ctrl+X`

### Opción 3: Usar el script completo

```bash
# Copiar y pegar todo este bloque
sudo systemctl start ssh
sudo systemctl enable ssh
sudo sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo systemctl restart ssh
sudo systemctl status ssh
```

## ✅ Verificar que funcionó

**Después de ejecutar los comandos**, verifica:

```bash
# Ver la configuración
sudo grep -i "PasswordAuthentication" /etc/ssh/sshd_config | grep -v "^#"
```

Debe mostrar: `PasswordAuthentication yes`

**Verificar estado de SSH:**
```bash
sudo systemctl status ssh
```

Debe mostrar: `active (running)`

## 🚀 Probar Conexión

**Desde PowerShell en Windows:**

```powershell
ssh moltbot@127.0.0.1 -p 2222
```

Ahora debería funcionar con tu contraseña.

---

**Usa la Opción 1 o 2. La Opción 2 (nano) es más segura si no estás seguro.**












