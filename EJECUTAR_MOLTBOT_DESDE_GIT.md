# 🚀 Ejecutar Moltbot desde el Repositorio Clonado

## ✅ Estado Actual

- ✅ Repositorio clonado desde GitHub
- ✅ Dependencias instaladas (`npm install` completado)
- ⏳ Pendiente: Verificar cómo ejecutar Moltbot

## 🔍 Paso 1: Verificar Estructura del Proyecto

**En tu terminal SSH**, ejecuta:

```bash
# Ver estructura del proyecto
ls -la ~/moltbot/

# Ver package.json para encontrar scripts
cat ~/moltbot/package.json | grep -A 10 "scripts"

# Ver si hay un archivo README
cat ~/moltbot/README.md | head -50
```

## 🚀 Paso 2: Ejecutar Moltbot

Basado en el proyecto, intenta:

```bash
cd ~/moltbot

# Opción 1: Ver si hay un script de inicio
npm run start
# O
npm start

# Opción 2: Ejecutar directamente con node
node index.js
# O
node src/index.js
# O
node dist/index.js

# Opción 3: Ver todos los scripts disponibles
npm run
```

## 🔧 Paso 3: Crear Comando Global (Opcional)

Si quieres ejecutar `moltbot` desde cualquier lugar:

```bash
# Crear enlace simbólico
sudo ln -s ~/moltbot/bin/moltbot /usr/local/bin/moltbot
# O si el ejecutable está en otro lugar:
sudo ln -s ~/moltbot/dist/cli.js /usr/local/bin/moltbot

# Verificar
which moltbot
moltbot --version
```

## 📝 Nota sobre Vulnerabilidades

Las advertencias de vulnerabilidades son comunes en proyectos en desarrollo. Puedes ignorarlas por ahora o ejecutar:

```bash
npm audit fix
```

---

**Ejecuta el Paso 1 primero para ver la estructura del proyecto y encontrar cómo ejecutarlo.**












