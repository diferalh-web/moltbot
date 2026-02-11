# 🔒 Guía de Seguridad y Configuración - Moltbot/OpenClaw

Esta guía explica cómo usar los scripts de seguridad y personalización para configurar tu instalación de Moltbot/OpenClaw de forma segura.

## 📁 Archivos en esta Carpeta Compartida

### Scripts de Seguridad

1. **`aplicar-mejoras-seguridad.sh`**
   - Aplica mejoras de seguridad a la configuración existente
   - Valida archivos JSON
   - Crea backups automáticos
   - Aplica permisos seguros
   - No modifica la funcionalidad, solo mejora la seguridad

2. **`generar-config-desde-cuestionario.sh`**
   - Genera archivos de configuración del workspace
   - Basado en tus respuestas al cuestionario
   - Crea: IDENTITY.md, USER.md, SOUL.md, TOOLS.md, HEARTBEAT.md

### Documentación

3. **`CUESTIONARIO_PERSONALIZACION.md`**
   - Cuestionario con 20+ preguntas para personalizar tu asistente
   - Responde las preguntas antes de ejecutar el generador

4. **`README_SEGURIDAD.md`** (este archivo)
   - Guía completa de uso

---

## 🚀 Uso Rápido

### Paso 1: Aplicar Mejoras de Seguridad

```bash
# Desde la VM, navega a la carpeta compartida
cd /media/sf_shareFolder  # o la ruta donde esté montada

# Dar permisos de ejecución
chmod +x aplicar-mejoras-seguridad.sh

# Ejecutar el script
./aplicar-mejoras-seguridad.sh
```

**¿Qué hace este script?**
- ✅ Valida que la configuración actual sea correcta
- ✅ Crea backups de todos los archivos importantes
- ✅ Aplica permisos seguros (700 para directorios, 600 para archivos)
- ✅ Configura el gateway para solo escuchar en localhost
- ✅ Verifica que no haya credenciales expuestas
- ✅ Valida que los JSON sigan siendo válidos después de los cambios

**Importante:** Este script es **no destructivo**. Solo mejora la seguridad sin cambiar la funcionalidad.

### Paso 2: Personalizar con el Cuestionario

```bash
# 1. Abre y responde el cuestionario
# Puedes editarlo directamente o responder en un archivo de texto

# 2. Ejecuta el generador (te hará las preguntas interactivamente)
chmod +x generar-config-desde-cuestionario.sh
./generar-config-desde-cuestionario.sh

# 3. O si prefieres, edita los archivos manualmente
nano ~/.openclaw/workspace/IDENTITY.md
```

---

## 📋 Proceso Completo Recomendado

### 1. Verificar que Moltbot esté funcionando

```bash
cd ~/moltbot
pnpm start agent --message "test" --local
```

### 2. Aplicar mejoras de seguridad

```bash
cd /media/sf_shareFolder
./aplicar-mejoras-seguridad.sh
```

### 3. Verificar que sigue funcionando

```bash
cd ~/moltbot
pnpm start agent --message "test" --local
```

### 4. Personalizar (opcional)

```bash
cd /media/sf_shareFolder
./generar-config-desde-cuestionario.sh
```

### 5. Revisar archivos generados

```bash
ls -la ~/.openclaw/workspace/
cat ~/.openclaw/workspace/IDENTITY.md
```

---

## 🔍 Verificación Post-Instalación

### Verificar permisos

```bash
# Verificar que los permisos sean correctos
find ~/.openclaw -type d -exec ls -ld {} \; | grep -v "^d[rwx-]\{6\}---"
find ~/.openclaw -type f -exec ls -l {} \; | grep -v "^-rw-------"

# Si encuentras archivos con permisos incorrectos, ejecuta:
cd /media/sf_shareFolder
./aplicar-mejoras-seguridad.sh
```

### Verificar que no haya credenciales expuestas

```bash
# Verificar que auth-profiles.json tenga permisos 600
stat -c "%a %n" ~/.openclaw/agents/main/agent/auth-profiles.json

# Verificar que no esté en git (si usas git)
cd ~/.openclaw
git ls-files | grep auth-profiles.json || echo "No está en git (correcto)"
```

### Verificar backups

```bash
# Listar backups creados
ls -lh ~/.openclaw/backup/

# Restaurar un backup si es necesario
cp ~/.openclaw/backup/openclaw.json.20240101_120000 ~/.openclaw/openclaw.json
```

---

## 🛡️ Mejores Prácticas de Seguridad

### 1. Permisos de Archivos

- **Directorios:** `700` (solo el propietario puede leer, escribir, ejecutar)
- **Archivos de configuración:** `600` (solo el propietario puede leer y escribir)
- **Archivos con credenciales:** `600` (nunca `644` o `755`)

### 2. Credenciales

- **NUNCA** incluyas API keys en:
  - Archivos JSON públicos
  - Repositorios Git
  - Logs
  - Archivos compartidos

- **USA:**
  - `auth-profiles.json` con permisos 600
  - Variables de entorno en `.env` con permisos 600
  - Gestores de secretos si es posible

### 3. Gateway

- **Siempre** configura el gateway para escuchar solo en `127.0.0.1` (localhost)
- Si necesitas acceso remoto, usa un proxy reverso con autenticación
- No expongas puertos directamente a internet

### 4. Backups

- Los backups se crean automáticamente en `~/.openclaw/backup/`
- Revisa periódicamente que los backups estén actualizados
- Considera cifrar los backups si contienen información sensible

### 5. Validación

- Siempre valida JSON después de cambios manuales:
  ```bash
  python3 -m json.tool ~/.openclaw/openclaw.json
  ```

---

## 🆘 Solución de Problemas

### El script falla al aplicar permisos

**Problema:** "No se pudieron aplicar permisos"

**Solución:**
```bash
# Verificar que eres el propietario
ls -la ~/.openclaw

# Si no eres el propietario, cambiar:
sudo chown -R $USER:$USER ~/.openclaw
```

### Los archivos JSON quedan inválidos

**Problema:** "JSON inválido después de cambios"

**Solución:**
```bash
# Restaurar desde backup
cp ~/.openclaw/backup/openclaw.json.TIMESTAMP ~/.openclaw/openclaw.json

# Validar manualmente
python3 -m json.tool ~/.openclaw/openclaw.json
```

### Moltbot deja de funcionar después de aplicar cambios

**Problema:** Moltbot no inicia o da errores

**Solución:**
1. Verificar que los JSON sean válidos
2. Verificar permisos (no deben ser demasiado restrictivos para el proceso de Moltbot)
3. Revisar logs: `journalctl -u moltbot` o `pnpm start logs`
4. Restaurar desde backup si es necesario

### No puedo acceder a la carpeta compartida

**Problema:** No encuentro `/media/sf_shareFolder`

**Solución:**
```bash
# Buscar la carpeta compartida
find / -name "aplicar-mejoras-seguridad.sh" 2>/dev/null

# Verificar grupo vboxsf
groups | grep vboxsf

# Si no estás en el grupo:
sudo usermod -aG vboxsf $USER
# Luego reinicia sesión SSH
```

---

## 📚 Archivos de Configuración Generados

### IDENTITY.md
Define la personalidad del asistente:
- Nombre
- Tipo de criatura
- Emoji
- Vibe/personalidad

### USER.md
Información sobre el usuario:
- Nombre
- Zona horaria
- Preferencias de tono
- Notas adicionales

### SOUL.md
Límites y comportamiento:
- Nivel de autonomía
- Restricciones
- Manejo de información confidencial
- Principios y valores

### TOOLS.md
Configuración del entorno:
- Hosts SSH
- Dispositivos IoT
- Preferencias de TTS
- Nombres de habitaciones/dispositivos
- Herramientas locales

### HEARTBEAT.md
Tareas periódicas:
- Frecuencia de verificaciones
- Lista de tareas a verificar
- Instrucciones para el asistente

---

## ✅ Checklist de Seguridad

Después de ejecutar los scripts, verifica:

- [ ] Todos los directorios tienen permisos 700
- [ ] Todos los archivos tienen permisos 600
- [ ] `auth-profiles.json` tiene permisos 600
- [ ] `.env` (si existe) tiene permisos 600
- [ ] El gateway está configurado para `127.0.0.1`
- [ ] Los backups se crearon correctamente
- [ ] Los archivos JSON son válidos
- [ ] Moltbot sigue funcionando después de los cambios
- [ ] No hay credenciales en archivos públicos
- [ ] `.gitignore` está configurado (si usas git)

---

## 📞 Soporte

Si encuentras problemas:

1. Revisa los mensajes de error del script
2. Verifica los backups en `~/.openclaw/backup/`
3. Valida los archivos JSON manualmente
4. Revisa los logs de Moltbot
5. Restaura desde backup si es necesario

---

**Última actualización:** 2024
**Versión del script:** 1.0












