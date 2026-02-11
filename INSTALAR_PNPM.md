# 📦 Instalar pnpm para Moltbot

## 🔍 Problema

El error `Error: spawn pnpm ENOENT` indica que el proyecto necesita `pnpm` (Package Manager) pero no está instalado.

## ✅ Solución: Instalar pnpm

**En tu terminal SSH**, ejecuta:

```bash
# Instalar pnpm globalmente
npm install -g pnpm

# Verificar instalación
pnpm --version
```

## 🚀 Después de Instalar pnpm

Una vez instalado pnpm, intenta ejecutar Moltbot de nuevo:

```bash
cd ~/moltbot
npm start
```

O directamente con pnpm:

```bash
cd ~/moltbot
pnpm start
```

## 🔧 Si Aún Hay Problemas

Si después de instalar pnpm aún hay problemas, puede que necesites:

1. **Reinstalar dependencias con pnpm:**
   ```bash
   cd ~/moltbot
   pnpm install
   ```

2. **Compilar el proyecto:**
   ```bash
   pnpm build
   ```

3. **Luego ejecutar:**
   ```bash
   pnpm start
   ```

---

**Instala pnpm primero y luego intenta ejecutar Moltbot de nuevo.**












