# 🔥 Configurar Firewall para Ollama-Mistral y Ollama-Qwen

## ⚠️ Requisito: Permisos de Administrador

Los comandos de firewall requieren ejecutar PowerShell **como Administrador**.

## 📋 Opción 1: Ejecutar Script (Recomendado)

1. **Abrir PowerShell como Administrador:**
   - Click derecho en PowerShell
   - Seleccionar "Ejecutar como administrador"

2. **Navegar al directorio:**
   ```powershell
   cd C:\code\moltbot
   ```

3. **Ejecutar script:**
   ```powershell
   .\scripts\configurar-firewall-modelos-netsh.ps1
   ```

## 📋 Opción 2: Comandos Manuales

**En PowerShell como Administrador:**

```powershell
# Regla para Mistral (puerto 11436)
netsh advfirewall firewall add rule name="Ollama Mistral" dir=in action=allow protocol=TCP localport=11436

# Regla para Qwen (puerto 11437)
netsh advfirewall firewall add rule name="Ollama Qwen" dir=in action=allow protocol=TCP localport=11437
```

## ✅ Verificar Reglas Creadas

```powershell
# Ver regla de Mistral
netsh advfirewall firewall show rule name="Ollama Mistral"

# Ver regla de Qwen
netsh advfirewall firewall show rule name="Ollama Qwen"
```

## 🧪 Probar desde la VM

**En la terminal SSH de la VM:**

```bash
# Obtener IP del host (reemplaza con tu IP)
HOST_IP="192.168.56.1"  # o la IP que uses

# Probar Mistral
curl http://$HOST_IP:11436/api/tags

# Probar Qwen
curl http://$HOST_IP:11437/api/tags
```

Si los comandos `curl` funcionan, el firewall está configurado correctamente.

---

**Nota:** Si la IP es diferente a `192.168.56.1`, reemplázala en los comandos de prueba.












