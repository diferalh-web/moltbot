# 📁 Ejecutar Scripts desde Carpeta Compartida

## 📋 Ubicación

**En Windows Host:**
```
C:\code\moltbot\shareFolder\
```

**En la VM (Ubuntu):**
La carpeta compartida puede estar montada en diferentes ubicaciones dependiendo de cómo la configuraste:

### Opción 1: VirtualBox Shared Folders
```bash
# Verificar si está montada
ls /media/sf_shareFolder
# o
ls /mnt/shareFolder
```

### Opción 2: Verificar montajes
```bash
# Ver todos los montajes
mount | grep -i share
# o
df -h | grep -i share
```

### Opción 3: Buscar la carpeta
```bash
# Buscar archivos .sh en el sistema
find / -name "configurar-moltbot-mistral-vm.sh" 2>/dev/null
```

## 🚀 Ejecutar Script de Mistral

Una vez que encuentres la carpeta compartida (por ejemplo, `/media/sf_shareFolder`):

```bash
# Navegar a la carpeta compartida
cd /media/sf_shareFolder  # Ajusta la ruta según tu configuración

# Dar permisos de ejecución
chmod +x configurar-moltbot-mistral-vm.sh

# Ejecutar el script
./configurar-moltbot-mistral-vm.sh
```

## 🚀 Ejecutar Script de Qwen

```bash
# Navegar a la carpeta compartida
cd /media/sf_shareFolder  # Ajusta la ruta según tu configuración

# Dar permisos de ejecución
chmod +x configurar-moltbot-qwen-vm.sh

# Ejecutar el script
./configurar-moltbot-qwen-vm.sh
```

## 🔍 Encontrar la Carpeta Compartida

Si no estás seguro de dónde está montada, ejecuta:

```bash
# Opción 1: Buscar por nombre de archivo
find / -name "configurar-moltbot-mistral-vm.sh" 2>/dev/null

# Opción 2: Buscar en ubicaciones comunes
ls /media/sf_* 2>/dev/null
ls /mnt/* 2>/dev/null
ls /media/*/shareFolder 2>/dev/null

# Opción 3: Verificar grupos de usuario
# Si usas VirtualBox Shared Folders, necesitas estar en el grupo vboxsf
groups
# Si no estás en vboxsf, agrega tu usuario:
# sudo usermod -aG vboxsf $USER
# Luego reinicia sesión
```

## ✅ Verificar que los Scripts Están Disponibles

```bash
# Listar archivos en la carpeta compartida
ls -la /media/sf_shareFolder/  # Ajusta la ruta

# Deberías ver:
# - configurar-moltbot-mistral-vm.sh
# - configurar-moltbot-qwen-vm.sh
```

## 🧪 Probar Después de Configurar

Después de ejecutar cualquiera de los scripts:

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola, como estas?" --local
```

## 📝 Notas

- Los scripts hacen backup automático de tus archivos de configuración
- Los backups se guardan en `~/.openclaw/backup/`
- Puedes ejecutar los scripts múltiples veces (cada vez crea un nuevo backup)
- Si algo sale mal, puedes restaurar desde los backups

## 🔄 Cambiar entre Modelos

Para cambiar de Mistral a Qwen (o viceversa), solo ejecuta el script correspondiente:

```bash
# Cambiar a Mistral
./configurar-moltbot-mistral-vm.sh

# Cambiar a Qwen
./configurar-moltbot-qwen-vm.sh
```












