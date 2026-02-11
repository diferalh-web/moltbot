# 🔨 Compilar Moltbot

## 🔍 Problema

El error `Cannot find module '/home/moltbot2/moltbot/dist/entry.js'` indica que el proyecto necesita ser compilado primero.

El mensaje `[openclaw] Building TypeScript (dist is stale)` sugiere que intentó compilar pero falló.

## ✅ Solución: Compilar el Proyecto

**En tu terminal SSH**, ejecuta:

```bash
cd ~/moltbot

# Compilar el proyecto
pnpm build
```

**Nota:** Esto puede tomar varios minutos ya que compila todo el proyecto TypeScript.

## 🚀 Después de Compilar

Una vez que termine la compilación, ejecuta:

```bash
pnpm start
```

O:

```bash
npm start
```

## 🔧 Si el Build Falla

Si `pnpm build` falla, puede que necesites:

1. **Instalar dependencias adicionales:**
   ```bash
   pnpm install
   ```

2. **Verificar que todas las dependencias estén instaladas:**
   ```bash
   pnpm install --frozen-lockfile
   ```

3. **Ver los errores de compilación:**
   - Revisa los mensajes de error
   - Puede que falten algunas dependencias del sistema

---

**Ejecuta `pnpm build` primero y espera a que termine. Luego intenta ejecutar Moltbot de nuevo.**












