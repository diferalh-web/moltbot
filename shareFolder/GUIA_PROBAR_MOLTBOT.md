# 🧪 Guía para Probar Funcionalidades de Moltbot

Esta guía te ayudará a explorar y probar las diferentes funcionalidades de Moltbot.

## 📋 Comandos Básicos

### Ver Ayuda General
```bash
cd ~/moltbot
pnpm start --help
```

### Ver Ayuda del Agente
```bash
pnpm start agent --help
```

### Ver Estado del Sistema
```bash
# Estado de salud
pnpm start health

# Estado de canales
pnpm start status

# Ver configuración
pnpm start config get
```

## 🤖 Probar el Agente

### Conversación Básica
```bash
# Mensaje simple
pnpm start agent --session-id test1 --message "Hola, ¿cómo estás?" --local

# Pregunta sobre capacidades
pnpm start agent --session-id test2 --message "¿Qué puedes hacer?" --local

# Pregunta técnica
pnpm start agent --session-id test3 --message "Explícame qué es un API" --local
```

### Conversación con Contexto (Misma Sesión)
```bash
# Primera pregunta
pnpm start agent --session-id mi-sesion --message "Mi nombre es Juan" --local

# Segunda pregunta (debería recordar tu nombre)
pnpm start agent --session-id mi-sesion --message "¿Cuál es mi nombre?" --local

# Tercera pregunta
pnpm start agent --session-id mi-sesion --message "¿Qué sabes sobre mí?" --local
```

### Diferentes Tipos de Preguntas
```bash
# Pregunta de programación
pnpm start agent --session-id code --message "Escribe una función en Python que calcule el factorial" --local

# Pregunta de análisis
pnpm start agent --session-id analysis --message "Analiza las ventajas y desventajas de usar Docker" --local

# Pregunta creativa
pnpm start agent --session-id creative --message "Escribe un poema corto sobre la tecnología" --local
```

## 🔧 Configuración

### Ver Configuración Actual
```bash
# Ver toda la configuración
pnpm start config get

# Ver configuración de modelos
pnpm start config get models

# Ver configuración del agente
pnpm start config get agents
```

### Cambiar Configuración
```bash
# Cambiar modelo (si tienes varios)
pnpm start config set model mistral

# Ver ayuda de configuración
pnpm start config --help
```

## 📊 Monitoreo y Logs

### Ver Logs
```bash
# Ver logs en tiempo real (si está disponible)
pnpm start logs

# O ver logs del sistema
journalctl -u moltbot -f
```

### Ver Estado de Salud
```bash
pnpm start health
```

## 🌐 Canales (Opcional)

### Configurar WhatsApp
```bash
pnpm start channels login whatsapp
```

### Configurar Telegram
```bash
pnpm start channels login telegram
```

### Ver Canales Disponibles
```bash
pnpm start channels --help
```

## 🧪 Pruebas Avanzadas

### Probar con Diferentes Modelos (si tienes varios)
```bash
# Cambiar temporalmente el modelo
pnpm start config set model llama2
pnpm start agent --session-id test --message "hola" --local

# Volver a Mistral
pnpm start config set model mistral
pnpm start agent --session-id test --message "hola" --local
```

### Probar Límites del Modelo
```bash
# Pregunta larga
pnpm start agent --session-id long --message "Explícame en detalle cómo funciona el machine learning, incluyendo los diferentes tipos de algoritmos, casos de uso, y mejores prácticas" --local

# Pregunta compleja
pnpm start agent --session-id complex --message "Compara las ventajas y desventajas de usar microservicios vs arquitectura monolítica, considerando factores como escalabilidad, mantenimiento, y complejidad" --local
```

## 📝 Scripts de Prueba Rápida

### Crear un Script de Prueba
```bash
# Crear script de prueba
cat > ~/test-moltbot.sh << 'EOF'
#!/bin/bash
echo "Probando Moltbot..."
cd ~/moltbot

echo "1. Pregunta simple:"
pnpm start agent --session-id test --message "Hola" --local

echo ""
echo "2. Pregunta sobre capacidades:"
pnpm start agent --session-id test --message "¿Qué puedes hacer?" --local
EOF

chmod +x ~/test-moltbot.sh
./test-moltbot.sh
```

## 🔍 Solución de Problemas

### Si el Agente No Responde
```bash
# Verificar configuración
cat ~/.openclaw/agents/main/agent/config.json | python3 -m json.tool

# Verificar que Mistral está corriendo
curl http://192.168.100.42:11436/v1/models

# Ver logs de errores
pnpm start agent --session-id test --message "test" --local 2>&1 | grep -i error
```

### Si Hay Timeouts
```bash
# Probar con un mensaje más corto
pnpm start agent --session-id test --message "hi" --local

# Verificar conectividad
./diagnosticar-ollama.sh
```

## 📚 Recursos Adicionales

### Ver Documentación
```bash
# Ver README del proyecto
cat ~/moltbot/README.md

# Ver archivos de configuración
ls -la ~/.openclaw/
```

### Explorar Workspace
```bash
# Ver archivos del workspace (si los creaste)
ls -la ~/.openclaw/workspace/
cat ~/.openclaw/workspace/IDENTITY.md 2>/dev/null || echo "Workspace no configurado aún"
```

## 🎯 Pruebas Recomendadas para Empezar

1. **Prueba Básica:**
   ```bash
   pnpm start agent --session-id test --message "Hola, ¿cómo estás?" --local
   ```

2. **Prueba de Memoria:**
   ```bash
   pnpm start agent --session-id memory --message "Mi color favorito es el azul" --local
   pnpm start agent --session-id memory --message "¿Cuál es mi color favorito?" --local
   ```

3. **Prueba de Capacidades:**
   ```bash
   pnpm start agent --session-id capabilities --message "¿Qué puedes hacer? Lista tus capacidades principales" --local
   ```

4. **Prueba Técnica:**
   ```bash
   pnpm start agent --session-id tech --message "Explícame qué es Docker en términos simples" --local
   ```

5. **Ver Estado:**
   ```bash
   pnpm start health
   pnpm start status
   ```

---

**¡Diviértete explorando Moltbot!** 🚀












