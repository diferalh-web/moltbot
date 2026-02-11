# 📝 Crear Configuración con Nano (Sin Copiar/Pegar)

## 🚀 Método Simple con Nano

**En tu terminal SSH, ejecuta estos comandos uno por uno:**

### Paso 1: Crear directorio
```bash
mkdir -p ~/.openclaw
```

### Paso 2: Abrir nano
```bash
nano ~/.openclaw/openclaw.json
```

### Paso 3: Escribir manualmente (línea por línea):

```
{
  "models": {
    "llama2": {
      "provider": "ollama",
      "model": "llama2",
      "baseURL": "http://192.168.100.42:11435"
    }
  },
  "model": "llama2"
}
```

**Importante:** 
- Escribe exactamente como se muestra arriba
- Respeta las comillas dobles `"`
- Respeta las comas `,`
- Respeta las llaves `{` y `}`

### Paso 4: Guardar y salir
- Presiona `Ctrl+O` (guardar)
- Presiona `Enter` (confirmar nombre)
- Presiona `Ctrl+X` (salir)

### Paso 5: Verificar
```bash
cat ~/.openclaw/openclaw.json
```

---

**O usa el método alternativo más simple abajo.**












