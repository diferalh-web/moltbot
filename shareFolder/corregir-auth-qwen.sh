#!/bin/bash
# Añade la API key de Qwen a auth-profiles.json
# Ejecutar en la VM: bash corregir-auth-qwen.sh

AUTH_FILE="$HOME/.openclaw/agents/main/agent/auth-profiles.json"

mkdir -p "$(dirname "$AUTH_FILE")"

python3 - "$AUTH_FILE" << 'PYEOF'
import json
import os
import sys

auth_file = os.path.expanduser(sys.argv[1])
provider_id = "ollama"

if os.path.exists(auth_file):
    with open(auth_file, "r") as f:
        auth = json.load(f)
else:
    auth = {}

auth[provider_id] = {"apiKey": "ollama-local"}

with open(auth_file, "w") as f:
    json.dump(auth, f, indent=2)

print("[OK] apiKey añadido para", provider_id)
PYEOF
