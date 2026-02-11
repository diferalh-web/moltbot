# 📝 Cuestionario de Personalización - OpenClaw/Moltbot

Este cuestionario te ayudará a personalizar los archivos de configuración de tu asistente AI. Responde las preguntas y luego usa el script `generar-config-desde-cuestionario.sh` para crear los archivos automáticamente.

---

## 👤 Información Básica del Usuario

### 1. ¿Cuál es tu nombre o cómo te gusta que te llamen?
**Respuesta:** _________________________________________________
*[Se usará en USER.md]*

### 2. ¿En qué zona horaria vives?
**Ejemplos:** America/Mexico_City, Europe/Madrid, America/New_York, Asia/Tokyo
**Respuesta:** _________________________________________________
*[Se usará en USER.md]*

### 3. ¿Prefieres que el asistente use un tono formal o informal?
- [ ] Formal
- [ ] Informal  
- [ ] Mixto según contexto
**Respuesta:** _________________________________________________

---

## 🤖 Personalidad del Asistente (IDENTITY.md)

### 4. ¿Qué nombre quieres para tu asistente AI?
**Ejemplos:** OpenClaw, Asistente, Helper, Assistant
**Respuesta:** _________________________________________________

### 5. ¿Qué tipo de criatura o personalidad quieres que tenga?
**Ejemplos:** robot, gato, ayudante, asistente digital, compañero
**Respuesta:** _________________________________________________

### 6. ¿Qué emoji representa mejor a tu asistente?
**Ejemplos:** 🦀, 🤖, 🐱, ⚡, 🦉, 🐉, 🦎
**Respuesta:** _________________________________________________

### 7. Describe el "vibe" o personalidad en 3-5 palabras:
**Ejemplos:** "helpful, resourceful, friendly, efficient" o "serio, profesional, preciso"
**Respuesta:** _________________________________________________

---

## 🛡️ Límites y Comportamiento (SOUL.md)

### 8. ¿Qué nivel de autonomía quieres que tenga el asistente?
- [ ] Solo sugerencias, nunca ejecutar comandos automáticamente
- [ ] Ejecutar comandos simples con confirmación
- [ ] Ejecutar comandos complejos con confirmación
- [ ] Alta autonomía para tareas rutinarias
**Respuesta:** _________________________________________________

### 9. ¿Hay temas o áreas que el asistente NO debe tocar?
**Ejemplos:** "No modificar archivos del sistema", "No acceder a datos financieros", "No ejecutar comandos destructivos"
**Respuesta:** _________________________________________________

### 10. ¿Cómo debe manejar información confidencial?
- [ ] Nunca almacenar información sensible
- [ ] Almacenar solo con cifrado
- [ ] Preguntar antes de almacenar cualquier dato personal
**Respuesta:** _________________________________________________

### 11. ¿Qué hacer cuando el asistente no está seguro de algo?
- [ ] Admitir incertidumbre y preguntar
- [ ] Intentar con la mejor suposición
- [ ] Buscar más información antes de responder
**Respuesta:** _________________________________________________

### 12. ¿Hay principios o valores que el asistente debe seguir?
**Ejemplos:** "Tratar datos del usuario con confidencialidad", "Nunca compartir credenciales", "Respetar límites de privacidad"
**Respuesta:** _________________________________________________

---

## 🔧 Configuración del Entorno (TOOLS.md)

### 13. ¿Tienes hosts SSH configurados que el asistente debe conocer?
- [ ] Sí: _________________________________________________
- [ ] No

### 14. ¿Usas dispositivos IoT o cámaras que el asistente debe conocer?
- [ ] Sí: _________________________________________________
- [ ] No

### 15. ¿Tienes preferencias de TTS (Text-to-Speech) o voces?
- [ ] Sí: _________________________________________________
- [ ] No

### 16. ¿Hay nombres de habitaciones, altavoces o dispositivos específicos?
**Ejemplos:** "Sala de estar", "Altavoz cocina", "Luz principal"
**Respuesta:** _________________________________________________

### 17. ¿Hay herramientas o servicios locales que el asistente debe conocer?
**Ejemplos:** "Ollama en http://192.168.100.42:11435", "Base de datos local en puerto 5432"
**Respuesta:** _________________________________________________

---

## 🔒 Configuración de Seguridad

### 18. ¿Prefieres usar variables de entorno o archivos de configuración para credenciales?
- [ ] Variables de entorno (.env)
- [ ] Archivos de configuración (auth-profiles.json)
- [ ] Ambos
**Respuesta:** _________________________________________________

### 19. ¿Qué nivel de logging quieres?
- [ ] Mínimo (solo errores)
- [ ] Normal (errores y advertencias)
- [ ] Detallado (todo, incluyendo debug)
**Respuesta:** _________________________________________________

### 20. ¿El asistente debe tener acceso a internet para buscar información?
- [ ] Sí, siempre
- [ ] Sí, pero con confirmación
- [ ] No, solo recursos locales
**Respuesta:** _________________________________________________

---

## ⏰ Tareas Periódicas (HEARTBEAT.md)

### 21. ¿Qué tareas periódicas quieres que el asistente verifique?
- [ ] Estado de salud del sistema
- [ ] Backups automáticos
- [ ] Actualizaciones de seguridad
- [ ] Revisión de logs
- [ ] Verificación de servicios
- [ ] Otras: _________________________________________________

### 22. ¿Con qué frecuencia quieres que se ejecuten los heartbeats?
- [ ] Cada hora
- [ ] Diariamente
- [ ] Semanalmente
- [ ] Solo cuando se solicite
**Respuesta:** _________________________________________________

---

## 📝 Información Adicional (Opcional)

### 23. ¿Hay algo más que quieras personalizar o configurar?
**Respuesta libre:**
_________________________________________________
_________________________________________________
_________________________________________________

---

## 📋 Instrucciones de Uso

1. **Responde todas las preguntas** en este documento
2. **Guarda tus respuestas** en un archivo de texto o edita este documento directamente
3. **Ejecuta el script generador** desde la VM:
   ```bash
   cd /media/sf_shareFolder
   chmod +x generar-config-desde-cuestionario.sh
   ./generar-config-desde-cuestionario.sh
   ```
4. **Revisa los archivos generados** en `~/.openclaw/workspace/`

---

## 📁 Archivos que se Generarán

- `IDENTITY.md` - Nombre, tipo, vibe, emoji del asistente
- `USER.md` - Información del usuario (nombre, timezone, preferencias)
- `SOUL.md` - Límites, principios y comportamiento del asistente
- `TOOLS.md` - Configuración local (SSH, dispositivos, herramientas)
- `HEARTBEAT.md` - Tareas periódicas y verificaciones

---

**Nota:** Puedes editar estos archivos manualmente después de generarlos si necesitas ajustar algo.












