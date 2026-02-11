# 🚀 Ejecutar Instalación Directamente en la VM

## 🔍 Problema

El script `setup-complete.sh` intenta usar `sudo` de forma interactiva, pero cuando se ejecuta vía SSH no puede pedir la contraseña.

## ✅ Solución: Ejecutar Directamente en la VM

**Conéctate vía SSH de forma interactiva** y ejecuta los comandos directamente:

### Opción 1: Conectarte y Ejecutar Manualmente

**1. Conéctate vía SSH (interactivo):**

```powershell
ssh moltbot2@127.0.0.1 -p 2222
```

**2. Una vez dentro de la VM, ejecuta:**

```bash
# Ir al directorio de scripts
cd ~/scripts

# Hacer ejecutables
chmod +x *.sh

# Instalar solo Node.js y Moltbot (sin SSH)
bash install-only.sh
```

**O ejecuta los comandos directamente:**

```bash
# Actualizar sistema
sudo apt update

# Instalar Node.js
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar
node --version
npm --version

# Instalar Moltbot
sudo npm install -g moltbot@latest

# Verificar
which moltbot
```

### Opción 2: Usar el Script Modificado

**1. Transfiere el nuevo script:**

```powershell
cd C:\code\moltbot
scp -P 2222 scripts\install-only.sh moltbot2@127.0.0.1:~/scripts/
```

**2. Conéctate vía SSH:**

```powershell
ssh moltbot2@127.0.0.1 -p 2222
```

**3. Ejecuta:**

```bash
cd ~/scripts
chmod +x install-only.sh
bash install-only.sh
```

## 🎯 Recomendación

**Usa la Opción 1** - es más simple y te permite ver el progreso en tiempo real.

---

**Conéctate vía SSH de forma interactiva y ejecuta los comandos directamente en la VM.**












