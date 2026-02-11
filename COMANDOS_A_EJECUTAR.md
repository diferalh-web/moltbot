# 🚀 Comandos a Ejecutar - Copia y Pega

## ⚠️ Importante

Los comandos SSH requieren tu contraseña, así que debes ejecutarlos manualmente.
Copia y pega estos comandos en PowerShell, uno por uno.

---

## Paso 1: Crear directorio en la VM

**Abre PowerShell** y ejecuta:

```powershell
ssh moltbot@127.0.0.1 -p 2222 "mkdir -p ~/scripts && echo 'Directorio creado'"
```

- Ingresa tu contraseña cuando se solicite
- Deberías ver: "Directorio creado"

---

## Paso 2: Transferir scripts

**En la misma ventana de PowerShell**, ejecuta:

```powershell
cd C:\code\moltbot
scp -P 2222 -r scripts\* moltbot@127.0.0.1:~/scripts/
```

- Ingresa tu contraseña cuando se solicite
- Verás el progreso de la transferencia
- Espera a que termine

---

## Paso 3: Instalar Node.js y Moltbot

**Ejecuta este comando** (tomará 10-15 minutos):

```powershell
ssh moltbot@127.0.0.1 -p 2222 "chmod +x ~/scripts/*.sh && bash ~/scripts/setup-complete.sh"
```

- Ingresa tu contraseña cuando se solicite
- Verás el progreso de la instalación
- **Espera pacientemente** - esto toma tiempo

---

## Paso 4: Verificar instalación

**Ejecuta para verificar:**

```powershell
ssh moltbot@127.0.0.1 -p 2222 "node --version && npm --version && which moltbot"
```

Deberías ver:
- Versión de Node.js (v22.x.x)
- Versión de npm
- Ruta de moltbot

---

## Paso 5: Conectar Cursor

1. **Abre Cursor**
2. Presiona `Ctrl+Shift+P`
3. Escribe: `Remote-SSH: Connect to Host`
4. Escribe: `moltbot@127.0.0.1 -p 2222`
5. Ingresa tu contraseña
6. Abre carpeta: `/home/moltbot/moltbot-project`

---

## 🆘 Si algo falla

### Error: "Connection refused" o "Connection timed out"

**Verifica que la VM esté encendida:**
- Abre VirtualBox
- Verifica que `moltbot-vm` esté en estado "Running"

**Verifica SSH en la VM:**
- En VirtualBox, abre la consola de la VM
- Ejecuta: `sudo systemctl status ssh`
- Si no está corriendo: `sudo systemctl start ssh`

### Error: "Permission denied"

- Verifica que estés usando la contraseña correcta
- Verifica que el usuario sea `moltbot` (o el que creaste)

### Los scripts no se transfieren

**Verifica que estás en el directorio correcto:**
```powershell
cd C:\code\moltbot
dir scripts
```

Debes ver los archivos `.sh`

---

## ✅ Orden de Ejecución

1. ✅ Crear directorio (Paso 1)
2. ✅ Transferir scripts (Paso 2)
3. ✅ Instalar Node.js y Moltbot (Paso 3) - **Toma 10-15 minutos**
4. ✅ Verificar (Paso 4)
5. ✅ Conectar Cursor (Paso 5)

---

**Copia y pega los comandos uno por uno. Avísame cuando termines cada paso.** 🚀












