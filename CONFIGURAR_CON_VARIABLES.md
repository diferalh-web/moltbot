# ✅ Configurar Moltbot con Variables de Entorno

## ❌ Problema

La estructura de configuración JSON no es válida para esta versión de OpenClaw. El error indica que no reconoce las claves que estamos usando.

## ✅ Solución: Usar Variables de Entorno

**En tu terminal SSH, ejecuta:**

```bash
# Configurar variables de entorno
export OPENCLAW_MODEL_PROVIDER=ollama
export OPENCLAW_MODEL_NAME=llama2
export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435
```

**O en una sola línea:**

```bash
export OPENCLAW_MODEL_PROVIDER=ollama OPENCLAW_MODEL_NAME=llama2 OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435
```

## 🧪 Probar

```bash
# Verificar variables
echo $OPENCLAW_MODEL_PROVIDER
echo $OPENCLAW_MODEL_NAME
echo $OPENCLAW_MODEL_BASE_URL

# Probar conexión a Ollama
curl http://192.168.100.42:11435/api/tags

# Probar Moltbot
cd ~/moltbot
pnpm start agent --message "Hola, ¿cómo estás?" --local
```

## 🔄 Hacer Permanente (Opcional)

**Para que las variables persistan después de cerrar SSH:**

```bash
# Agregar al archivo .bashrc
echo 'export OPENCLAW_MODEL_PROVIDER=ollama' >> ~/.bashrc
echo 'export OPENCLAW_MODEL_NAME=llama2' >> ~/.bashrc
echo 'export OPENCLAW_MODEL_BASE_URL=http://192.168.100.42:11435' >> ~/.bashrc

# Recargar configuración
source ~/.bashrc
```

## 🗑️ Limpiar Archivo de Configuración Incorrecto

**Si quieres eliminar el archivo que causó el error:**

```bash
rm ~/.openclaw/openclaw.json
```

---

**Este método es más simple y debería funcionar sin problemas.**












