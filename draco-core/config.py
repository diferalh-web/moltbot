"""
Draco Core Configuration
Service URLs and settings from environment variables
"""

import os
from typing import Optional

# Service URLs
COMFYUI_URL = os.getenv("COMFYUI_URL", "http://comfyui:8188")
WEB_SEARCH_URL = os.getenv("WEB_SEARCH_URL", "http://web-search:5003")
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://ollama-mistral:11434")
TTS_URL = os.getenv("TTS_URL", "http://coqui-tts:5002")
VIDEO_URL = os.getenv("VIDEO_URL", "http://stable-video:8000")

# ComfyUI settings
COMFYUI_CHECKPOINT = os.getenv("COMFYUI_CHECKPOINT_NAME", "v1-5-pruned-emaonly.safetensors")

# Chroma / memory
CHROMA_PERSIST_DIR = os.getenv("CHROMA_PERSIST_DIR", "/app/data/chroma")
CHROMA_COLLECTION_NAME = os.getenv("CHROMA_COLLECTION_NAME", "draco_memory")

# Security
DRACO_API_TOKEN = os.getenv("DRACO_API_TOKEN", "")
DRACO_REQUIRE_AUTH = os.getenv("DRACO_REQUIRE_AUTH", "false").lower() == "true"

# Flow storage
FLOWS_DIR = os.getenv("FLOWS_DIR", "/app/flows")


def get_comfyui_url() -> str:
    return COMFYUI_URL.rstrip("/")


def get_web_search_url() -> str:
    return WEB_SEARCH_URL.rstrip("/")
