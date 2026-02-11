# Versionado con Git y GitHub

El proyecto está inicializado como repositorio Git con la rama **main** como estado estable actual.

## Estado actual

- **Rama:** `main`
- **Commit inicial:** estado estable (Open WebUI, Draco, web-search, ComfyUI, Ollama, extensiones, scripts).
- **.gitignore:** excluye `.env`, secretos, `C/` (discos virtuales), `__pycache__`, logs, etc.

## Crear el repositorio en GitHub y subir el código

1. **Crea el repositorio en GitHub** (sin README, sin .gitignore, vacío):
   - Ve a [https://github.com/new](https://github.com/new)
   - **Owner:** `diferalh-web`
   - **Repository name:** por ejemplo `moltbot`
   - Deja **sin marcar** "Add a README", ".gitignore" y "license"
   - Clic en **Create repository**

2. **Conecta tu carpeta local con GitHub y haz push** (en PowerShell desde `c:\code\moltbot`):

   ```powershell
   git remote add origin https://github.com/diferalh-web/moltbot.git
   git branch -M main
   git push -u origin main
   ```

   Si GitHub te pide autenticación, usa tu usuario y un **Personal Access Token** (Settings → Developer settings → Personal access tokens) como contraseña, o configura SSH y usa la URL `git@github.com:diferalh-web/moltbot.git`.

3. **Cambiar la identidad de Git** (opcional, si quieres otro nombre/email en los commits):

   ```powershell
   git config user.name "Tu Nombre"
   git config user.email "tu@email.com"
   ```

## Comandos útiles

- Ver estado: `git status`
- Añadir cambios: `git add .` o `git add archivo`
- Nuevo commit: `git commit -m "Descripción del cambio"`
- Subir a GitHub: `git push`
- Descargar cambios: `git pull`
