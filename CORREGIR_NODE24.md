# 🔧 Corregir Instalación de Node.js 24

## ❌ Problema

El comando se ejecutó incorrectamente. Necesitas ejecutar el script de setup PRIMERO, y luego instalar.

## ✅ Solución Correcta

**Ejecuta estos comandos EN ORDEN en tu terminal SSH:**

### Paso 1: Desinstalar Node.js actual

```bash
sudo apt remove -y nodejs npm
```

### Paso 2: Agregar repositorio de Node.js 24 (IMPORTANTE - ejecuta completo)

```bash
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
```

**Espera a que termine completamente** - verás mensajes sobre agregar el repositorio.

### Paso 3: Instalar Node.js 24

```bash
sudo apt-get install -y nodejs
```

### Paso 4: Verificar

```bash
node --version
```

Debe mostrar: `v24.x.x` (o superior)

---

## 🔍 Si aún muestra v22

Si después de estos pasos aún muestra v22, verifica:

```bash
# Ver qué repositorios tienes
cat /etc/apt/sources.list.d/nodesource.list

# Actualizar lista de paquetes
sudo apt update

# Ver qué versión está disponible
apt-cache policy nodejs
```

---

**Ejecuta los comandos del Paso 1-3 en orden. El Paso 2 es crítico - debe ejecutarse completo antes del Paso 3.**












