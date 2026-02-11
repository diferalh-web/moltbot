# 🚀 Continuar Instalación - SSH Funcionando

## ✅ Estado Actual

- ✅ SSH conectado y funcionando
- ⏳ Pendiente: Transferir scripts e instalar Node.js y Moltbot

## 📁 Paso 1: Transferir Scripts a la VM

**Abre OTRA ventana de PowerShell** (deja la SSH abierta) y ejecuta:

```powershell
cd C:\code\moltbot
scp -r scripts\* moltbot2@IP_DE_LA_VM:~/scripts/
```

**O si usas port forwarding (127.0.0.1:2222):**

```powershell
cd C:\code\moltbot
scp -P 2222 -r scripts\* moltbot2@127.0.0.1:~/scripts/
```

- Ingresa tu contraseña cuando se solicite
- Espera a que termine la transferencia
- Verás el progreso de cada archivo

## 🚀 Paso 2: Instalar Node.js y Moltbot

**En la ventana SSH conectada a la VM**, ejecuta:

```bash
# Crear directorio si no existe
mkdir -p ~/scripts

# Hacer scripts ejecutables
chmod +x ~/scripts/*.sh

# Ejecutar instalación completa
bash ~/scripts/setup-complete.sh
```

**Esto tomará 10-15 minutos** e instalará:
- ✅ SSH (verificación)
- ✅ Node.js 22.x
- ✅ Moltbot

## ✅ Paso 3: Verificar Instalación

**En la VM (vía SSH)**, ejecuta:

```bash
node --version    # Debe ser v22.x.x
npm --version
which moltbot     # O: moltbot --version
```

## 💻 Paso 4: Conectar Cursor

1. **Abre Cursor**
2. **Instala extensión** (si no la tienes): `Remote - SSH`
3. **Conecta**: 
   - Presiona `Ctrl+Shift+P`
   - Escribe: `Remote-SSH: Connect to Host`
   - Escribe: `moltbot2@IP_DE_LA_VM` (o `moltbot2@127.0.0.1 -p 2222` si usas port forwarding)
4. **Ingresa contraseña** cuando se solicite
5. **Abre carpeta**: `/home/moltbot2/moltbot-project`

## 📝 Nota Importante

Si cambiaste a Bridge y obtuviste una IP nueva, úsala en lugar de `127.0.0.1:2222`.

---

**¡Sigue con el Paso 1 y 2 ahora!** 🚀












