# ✅ Verificar SSH y Conectar

## ✅ Estado Actual

- ✅ PasswordAuthentication yes configurado
- ⏳ Pendiente: Verificar que SSH esté corriendo

## 🔍 Paso 1: Verificar SSH en la VM

**En la VM**, ejecuta:

```bash
sudo systemctl status ssh
```

Debe mostrar: `active (running)`

Si no está corriendo:
```bash
sudo systemctl start ssh
sudo systemctl enable ssh
```

## 🚀 Paso 2: Probar Conexión desde Windows

**Desde PowerShell en Windows**, ejecuta:

```powershell
ssh moltbot@127.0.0.1 -p 2222
```

- Ingresa tu contraseña cuando se solicite
- Deberías ver: `moltbot@moltbot-server:~$`

## 📁 Paso 3: Transferir Scripts

Una vez conectado vía SSH, **abre OTRA ventana de PowerShell** y ejecuta:

```powershell
cd C:\code\moltbot
scp -P 2222 -r scripts\* moltbot@127.0.0.1:~/scripts/
```

- Ingresa tu contraseña cuando se solicite
- Espera a que termine la transferencia

## 🚀 Paso 4: Instalar Node.js y Moltbot

**En la ventana SSH conectada**, ejecuta:

```bash
chmod +x ~/scripts/*.sh
bash ~/scripts/setup-complete.sh
```

Esto tomará 10-15 minutos.

## ✅ Paso 5: Verificar Instalación

```bash
node --version    # Debe ser v22.x.x
npm --version
which moltbot
```

## 💻 Paso 6: Conectar Cursor

1. Abre Cursor
2. `Ctrl+Shift+P` → `Remote-SSH: Connect to Host`
3. Escribe: `moltbot@127.0.0.1 -p 2222`
4. Ingresa contraseña
5. Abre carpeta: `/home/moltbot/moltbot-project`

---

**¡Ahora deberías poder conectarte! Prueba el Paso 2.** 🚀












