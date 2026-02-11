# 🚀 Actualizar Node.js a v24 - Comandos para la VM

## ✅ Ejecuta estos comandos en tu terminal SSH (donde ya estás conectado)

### Paso 1: Desinstalar Node.js actual

```bash
sudo apt remove -y nodejs npm
```

### Paso 2: Instalar Node.js 24.x

```bash
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Paso 3: Verificar instalación

```bash
node --version
npm --version
```

Debe mostrar:
- Node.js: `v24.x.x` (o superior)
- npm: versión actualizada

### Paso 4: Verificar Moltbot

```bash
# Ver si está instalado
npm list -g moltbot

# Ver qué se instaló
ls -la $(npm root -g)/moltbot 2>/dev/null || echo "No encontrado en npm global"

# Buscar en el sistema
which moltbot
```

---

## 🔄 Si Moltbot no funciona después

Si después de actualizar Node.js, Moltbot aún no funciona, puede que necesites instalarlo desde GitHub:

```bash
# Buscar el repositorio oficial
cd ~
git clone https://github.com/moltbot/moltbot.git
cd moltbot
npm install
# O si usa pnpm:
npm install -g pnpm
pnpm install
```

---

**Copia y pega los comandos del Paso 1-3 en tu terminal SSH. Avísame cuando termine.**












