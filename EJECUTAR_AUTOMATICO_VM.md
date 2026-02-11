# 🚀 Ejecutar Configuración Automática (VM)

## 📋 Opción Rápida: Script Automático

He creado un script que busca automáticamente la carpeta compartida y ejecuta la configuración.

### Paso 1: Encontrar y Ejecutar

**En la terminal SSH de la VM:**

```bash
# Opción 1: Si conoces la ruta de la carpeta compartida
cd /media/sf_shareFolder  # o la ruta que uses
chmod +x encontrar-y-ejecutar-mistral.sh
./encontrar-y-ejecutar-mistral.sh

# Opción 2: Buscar primero
find / -name "encontrar-y-ejecutar-mistral.sh" 2>/dev/null
# Luego navega a la carpeta y ejecuta
```

### Paso 2: El Script Hace Todo

El script:
1. ✅ Busca automáticamente la carpeta compartida
2. ✅ Encuentra el script de configuración de Mistral
3. ✅ Verifica permisos
4. ✅ Ejecuta la configuración
5. ✅ Valida los archivos JSON

### Paso 3: Probar Moltbot

```bash
cd ~/moltbot
pnpm start agent --session-id test-session --message "hola, como estas?" --local
```

## 🔍 Si el Script No Encuentra la Carpeta

### Verificar Grupo vboxsf

```bash
# Verificar si estás en el grupo
groups | grep vboxsf

# Si no estás en el grupo, agregarte:
sudo usermod -aG vboxsf $USER

# Luego reinicia sesión SSH
exit
# Vuelve a conectarte
```

### Verificar Montaje de Carpeta Compartida

```bash
# Ver montajes
mount | grep -i share

# Ver si existe /media/sf_*
ls -la /media/

# Verificar permisos
ls -la /media/sf_shareFolder/ 2>/dev/null
```

### Montar Manualmente (si es necesario)

```bash
# Crear directorio de montaje
sudo mkdir -p /media/sf_shareFolder

# Montar (ajusta "shareFolder" al nombre de tu carpeta compartida en VirtualBox)
sudo mount -t vboxsf shareFolder /media/sf_shareFolder
```

## 📝 Alternativa: Ejecutar Scripts Manualmente

Si prefieres ejecutar los scripts manualmente:

### Para Mistral:

```bash
# 1. Encontrar la carpeta
find / -name "configurar-moltbot-mistral-vm.sh" 2>/dev/null

# 2. Navegar a la carpeta
cd /ruta/encontrada

# 3. Dar permisos
chmod +x configurar-moltbot-mistral-vm.sh

# 4. Ejecutar
./configurar-moltbot-mistral-vm.sh
```

### Para Qwen:

```bash
# 1. Encontrar la carpeta
find / -name "configurar-moltbot-qwen-vm.sh" 2>/dev/null

# 2. Navegar a la carpeta
cd /ruta/encontrada

# 3. Dar permisos
chmod +x configurar-moltbot-qwen-vm.sh

# 4. Ejecutar
./configurar-moltbot-qwen-vm.sh
```

## ✅ Verificar Configuración

Después de ejecutar cualquier script:

```bash
# Verificar que los JSON son válidos
python3 -m json.tool ~/.openclaw/agents/main/agent/config.json
python3 -m json.tool ~/.openclaw/agents/main/agent/models.json

# Ver la configuración actual
cat ~/.openclaw/agents/main/agent/config.json
```

## 🔄 Cambiar entre Modelos

Para cambiar de Mistral a Qwen (o viceversa), solo ejecuta el script correspondiente:

```bash
# Cambiar a Mistral
./configurar-moltbot-mistral-vm.sh

# Cambiar a Qwen
./configurar-moltbot-qwen-vm.sh
```

Los scripts hacen backup automático antes de cambiar nada.












