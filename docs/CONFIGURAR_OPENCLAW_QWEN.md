# Configurar OpenClaw con Qwen 2.5 7B

Qwen 2.5 7B tiene mejor soporte para tool use y sigue mejor las instrucciones que Mistral 7B (evita respuestas tipo "Here's a summary of...").

## Requisitos previos

- **ollama-qwen** corriendo en el host (Docker, puerto 11437)
- Modelo descargado: `docker exec ollama-qwen ollama pull qwen2.5:7b`
- VM con OpenClaw instalado y gateway configurado
- Conectividad desde la VM al host: `10.0.2.2` (VirtualBox NAT) o IP de red local

## Pasos rápidos

### Desde Windows (recomendado)

```powershell
cd c:\code\moltbot
.\scripts\configurar-openclaw-qwen.ps1 -VMUser clawbot -VMIP 127.0.0.1 -Port 2222
```

Si el host tiene otra IP desde la VM (p. ej. red bridged):

```powershell
.\scripts\configurar-openclaw-qwen.ps1 -HostIP 192.168.1.100
```

### Desde la VM (SSH)

```bash
cd ~/shareFolder
bash configurar-openclaw-qwen.sh
# O con IP explícita del host:
bash configurar-openclaw-qwen.sh 10.0.2.2
```

### Reiniciar el gateway

```bash
# En la VM: Ctrl+C si el gateway está corriendo, luego:
openclaw gateway
```

## Verificación

```bash
# En la VM
openclaw doctor
openclaw models list
```

Deberías ver `ollama/qwen2.5:7b` como modelo primario.

### Validar web_search

Para comprobar que OpenClaw pueda usar búsqueda web:

```bash
# Script de validación completo
bash ~/validar-openclaw-websearch.sh
# O si lo copiaste desde moltbot:
# scp -P 2222 scripts/validar-openclaw-websearch.sh clawbot@127.0.0.1:~/
```

Ver guía detallada: [VALIDAR_OPENCLAW_WEBSEARCH.md](./VALIDAR_OPENCLAW_WEBSEARCH.md)

## Solución de problemas

| Problema | Solución |
|----------|----------|
| "No se pudo conectar a Ollama" | Verifica que Docker y ollama-qwen estén corriendo. Desde el host: `docker ps \| grep ollama-qwen` |
| IP incorrecta | Para VirtualBox NAT: 10.0.2.2. Para bridged: la IP del host en la red local |
| Modelo no aparece | Reinicia el gateway. Revisa `~/.openclaw/openclaw.json` con `agents.defaults.model.primary` |
| "No API key found" | Añade apiKey al provider en **openclaw.json** y a auth-profiles. En la VM: `python3 -c "
import json,os
cfg=os.path.expanduser('~/.openclaw/openclaw.json')
c=json.load(open(cfg))
pid='ollama'
c.setdefault('models',{}).setdefault('providers',{})
c['models']['providers'].setdefault(pid,{})['apiKey']='ollama-local'
json.dump(c,open(cfg,'w'),indent=2)
# auth-profiles
ap=os.path.expanduser('~/.openclaw/agents/main/agent/auth-profiles.json')
os.makedirs(os.path.dirname(ap),exist_ok=True)
a=json.load(open(ap)) if os.path.exists(ap) else {}
a[pid]={'apiKey':'ollama-local'}
json.dump(a,open(ap,'w'),indent=2)
print('OK')
"` — Reinicia el gateway. |

## Qué hace el script

1. Verifica conectividad a `http://HOST_IP:11437/api/tags`
2. Hace backup de openclaw.json y auth-profiles.json
3. Añade el provider `ollama` en models.providers (con baseUrl custom y `api: openai-completions`)
4. Establece `agents.defaults.model.primary` = `ollama/qwen2.5:7b`
5. Añade apiKey en auth-profiles.json para el provider

**Importante:** Se usa el provider `ollama` (no `custom-*`) porque el soporte para tool calling (web_search, etc.) solo funciona correctamente con el provider nativo `ollama`.

## Cambiar de vuelta a Mistral

Edita `~/.openclaw/openclaw.json` y cambia:

```json
"agents": {
  "defaults": {
    "model": {
      "primary": "ollama/mistral:latest"
    }
  }
}
```

(O el provider/ID que tengas para Mistral si está en otro puerto.)
