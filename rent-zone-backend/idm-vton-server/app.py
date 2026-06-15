"""
IDM-VTON Flask Inference Server

Production-ready virtual try-on API server using the yisol/IDM-VTON model.
The model is loaded once at startup and kept in memory for all requests.
"""
import logging
import sys
import os
import threading

# ---------------------------------------------------------------------------
# Compatibility shim: huggingface_hub >= 0.24.0 removed `cached_download`.
# diffusers==0.25.1 still imports it via diffusers/utils/dynamic_modules_utils.py.
# Patch it before diffusers (or any library that triggers it) is imported.
# ---------------------------------------------------------------------------
try:
    import huggingface_hub
    if not hasattr(huggingface_hub, "cached_download"):
        from huggingface_hub import hf_hub_download
        # Set the attribute on the already-loaded module object so that
        # `from huggingface_hub import cached_download` works in sub-imports.
        huggingface_hub.cached_download = hf_hub_download
        sys.modules["huggingface_hub"].cached_download = hf_hub_download
except Exception:
    pass  # If huggingface_hub isn't installed yet, skip gracefully
# ---------------------------------------------------------------------------

# Ensure the project root is on the Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from flask import Flask
from flask_cors import CORS

from config import Config
from routes import register_routes
from utils.error_handlers import register_error_handlers
from utils.logging_config import setup_logging

logger = logging.getLogger(__name__)


def create_app() -> Flask:
    """
    Flask application factory.

    Creates and configures the Flask app with:
    - CORS support
    - Blueprint routes
    - Global error handlers
    - Logging
    - Upload size limits
    """
    app = Flask(__name__)

    # Configuration
    app.config["MAX_CONTENT_LENGTH"] = Config.get_max_content_length()

    # Ensure required directories exist
    Config.ensure_directories()

    # Setup logging
    setup_logging(app, log_level=Config.LOG_LEVEL, log_file=Config.LOG_FILE)

    # CORS
    CORS(app, resources={
        r"/api/*": {"origins": "*"},
        r"/health": {"origins": "*"},
        r"/outputs/*": {"origins": "*"},
    })

    # Register routes
    register_routes(app)

    # Register error handlers
    register_error_handlers(app)

    # Root route
    @app.route("/")
    def index():
        return {
            "service": "IDM-VTON Inference Server",
            "version": "1.0.0",
            "endpoints": {
                "health": "GET /health",
                "tryon": "POST /api/v1/tryon",
                "outputs": "GET /outputs/<filename>",
            },
        }

    logger.info("Flask app created successfully")
    return app


def preload_model(app: Flask):
    """
    Preload the IDM-VTON model in a background thread.

    This runs during server startup so the model is ready when
    the first request arrives.
    """
    def _load():
        with app.app_context():
            try:
                from services.idm_vton_service import get_service
                service = get_service()
                service.load_model()
            except Exception as e:
                logger.critical(f"Failed to preload model: {e}", exc_info=True)
                # Don't exit — the server can still respond with 503

    thread = threading.Thread(target=_load, name="model-loader", daemon=True)
    thread.start()
    logger.info("Model preloading started in background thread")
    return thread


# Create the app instance
app = create_app()

# Preload model on startup (not in reload/debug child processes)
if os.environ.get("WERKZEUG_RUN_MAIN") == "true" or not Config.DEBUG:
    _loader_thread = preload_model(app)


if __name__ == "__main__":
    logger.info(f"Starting IDM-VTON server on port {Config.PORT}")
    logger.info(f"Device: {Config.get_device()}")
    logger.info(f"Max upload: {Config.MAX_UPLOAD_MB}MB")
    logger.info(f"Output dir: {Config.OUTPUT_DIR}")

    app.run(
        host="0.0.0.0",
        port=Config.PORT,
        debug=Config.DEBUG,
        use_reloader=Config.DEBUG,
    )
