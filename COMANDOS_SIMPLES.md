# 🚀 Comandos Simples - Copia y Pega

## ⚠️ Importante

Ejecuta estos comandos **uno por uno** en PowerShell. Cada uno te pedirá la contraseña.

---

## Paso 1: Crear directorio en la VM

**Copia y pega en PowerShell:**

```powershell
ssh moltbot2@127.0.0.1 -p 2222 "mkdir -p ~/scripts && echo 'OK'"
```

- Ingresa tu contraseña cuando se solicite
- Deberías ver: `OK`

---

## Paso 2: Transferir scripts

**Copia y pega en PowerShell:**

```powershell
cd C:\code\moltbot
scp -P 2222 -r scripts\* moltbot2@127.0.0.1:~/scripts/
```

- Ingresa tu contraseña cuando se solicite
- Verás el progreso de la transferencia
- Espera a que termine

---

## Paso 3: Instalar Node.js y Moltbot

**Copia y pega en PowerShell:**

```powershell
ssh moltbot2@127.0.0.1 -p 2222 "chmod +x ~/scripts/*.sh && bash ~/scripts/setup-complete.sh"
```

- Ingresa tu contraseña cuando se solicite
- **Esto tomará 10-15 minutos**
- Verás el progreso de la instalación
- **Espera pacientemente**

---

## Paso 4: Verificar instalación

**Copia y pega en PowerShell:**

```powershell
ssh moltbot2@127.0.0.1 -p 2222 "node --version && npm --version && which moltbot"
```

Deberías ver:
- Versión de Node.js (v22.x.x)
- Versión de npm
- Ruta de moltbot

---

## 💻 Paso 5: Conectar Cursor

1. Abre Cursor
2. `Ctrl+Shift+P` → `Remote-SSH: Connect to Host`
3. Escribe: `moltbot2@127.0.0.1 -p 2222`
4. Ingresa contraseña
5. Abre carpeta: `/home/moltbot2/moltbot-project`

---

## 🔄 Si usas IP diferente (Bridge)

Si cambiaste a Bridge y tienes una IP diferente (ej: `192.168.1.100`), reemplaza `127.0.0.1 -p 2222` con solo la IP:

```powershell
# Ejemplo con IP 192.168.1.100
ssh moltbot2@192.168.1.100 "mkdir -p ~/scripts && echo 'OK'"
scp -r scripts\* moltbot2@192.168.1.100:~/scripts/
ssh moltbot2@192.168.1.100 "chmod +x ~/scripts/*.sh && bash ~/scripts/setup-complete.sh"
```

---

**Ejecuta los comandos uno por uno. Avísame cuando termines cada paso.** 🚀












