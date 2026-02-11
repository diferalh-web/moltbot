"""
Open WebUI Multimedia Extension
Integra generación de imágenes, video, síntesis de voz, búsqueda web, clonación de voz,
APIs externas y herramientas de marketing
"""

# Funciones básicas existentes
from .image_generator import (
    generate_image,
    generate_marketing_image,
    generate_banner,
    generate_social_media_image
)
from .video_generator import (
    generate_video,
    generate_marketing_video,
    create_video_from_images,
    generate_video_with_audio,
    check_video_status
)
from .tts_generator import text_to_speech, list_available_voices

# Nuevas funcionalidades
from .web_search import web_search, search_and_summarize, list_search_providers
from .tools import get_tools, call_tool, TOOLS
from .voice_cloning import (
    clone_voice,
    clone_voice_from_file,
    clone_voice_from_url,
    is_voice_cloning_available
)
from .external_apis import (
    call_gemini,
    call_huggingface,
    list_available_providers
)

# Herramientas de marketing
from .marketing_tools import (
    generate_marketing_copy,
    generate_hashtags,
    analyze_competitor,
    create_campaign_brief,
    get_social_media_dimensions,
    get_marketing_templates
)

# Router de API (imagen, video, TTS) - Open WebUI puede buscar "router"
from .router import router as multimedia_router
router = multimedia_router

# Templates de marketing
from .marketing_templates import (
    get_workflow,
    get_prompt_template,
    get_image_style,
    get_voice_tone,
    list_all_workflows,
    list_all_templates,
    list_all_styles,
    list_all_tones
)

__all__ = [
    # Router API
    'router',
    'multimedia_router',
    # Funciones básicas
    'generate_image',
    'generate_video',
    'text_to_speech',
    'list_available_voices',
    
    # Búsqueda web
    'web_search',
    'search_and_summarize',
    'list_search_providers',
    # Herramientas
    'get_tools',
    'call_tool',
    'TOOLS',
    
    # Clonación de voz
    'clone_voice',
    'clone_voice_from_file',
    'clone_voice_from_url',
    'is_voice_cloning_available',
    
    # APIs externas
    'call_gemini',
    'call_huggingface',
    'list_available_providers',
    
    # Marketing - imágenes
    'generate_marketing_image',
    'generate_banner',
    'generate_social_media_image',
    
    # Marketing - videos
    'generate_marketing_video',
    'create_video_from_images',
    'generate_video_with_audio',
    'check_video_status',
    
    # Marketing - herramientas
    'generate_marketing_copy',
    'generate_hashtags',
    'analyze_competitor',
    'create_campaign_brief',
    'get_social_media_dimensions',
    'get_marketing_templates',
    
    # Marketing - templates
    'get_workflow',
    'get_prompt_template',
    'get_image_style',
    'get_voice_tone',
    'list_all_workflows',
    'list_all_templates',
    'list_all_styles',
    'list_all_tones'
]




