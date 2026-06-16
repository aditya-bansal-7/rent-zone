"""
Application configuration loaded from environment variables.
"""
import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    """Server configuration from environment variables."""

    # Server
    PORT: int = int(os.getenv("PORT", "5000"))
    DEBUG: bool = os.getenv("DEBUG", "false").lower() == "true"

    # Device
    DEVICE: str = os.getenv("DEVICE", "auto")

    # Paths
    OUTPUT_DIR: str = os.getenv("OUTPUT_DIR", "outputs")
    HF_HOME: str = os.getenv("HF_HOME", "./hf_cache")
    CHECKPOINT_DIR: str = os.getenv("CHECKPOINT_DIR", "ckpt")
    UPLOAD_DIR: str = os.getenv("UPLOAD_DIR", "uploads")

    # Upload limits
    MAX_UPLOAD_MB: int = int(os.getenv("MAX_UPLOAD_MB", "20"))

    # Inference defaults
    NUM_INFERENCE_STEPS: int = int(os.getenv("NUM_INFERENCE_STEPS", "30"))
    GUIDANCE_SCALE: float = float(os.getenv("GUIDANCE_SCALE", "2.0"))
    SEED: int = int(os.getenv("SEED", "42"))

    # Queue
    MAX_QUEUE_SIZE: int = int(os.getenv("MAX_QUEUE_SIZE", "10"))

    # Logging
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_FILE: str = os.getenv("LOG_FILE", "server.log")

    # Image dimensions (IDM-VTON standard)
    IMAGE_WIDTH: int = 768
    IMAGE_HEIGHT: int = 1024
    PREPROCESS_WIDTH: int = 384
    PREPROCESS_HEIGHT: int = 512

    # Allowed image extensions
    ALLOWED_EXTENSIONS: set = {"png", "jpg", "jpeg", "webp"}

    @classmethod
    def get_device(cls) -> str:
        """Resolve the compute device."""
        import torch

        if cls.DEVICE != "auto":
            return cls.DEVICE

        if torch.cuda.is_available():
            return "cuda"
        elif hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
            return "mps"
        else:
            return "cpu"

    @classmethod
    def get_max_content_length(cls) -> int:
        """Return max upload size in bytes."""
        return cls.MAX_UPLOAD_MB * 1024 * 1024

    @classmethod
    def ensure_directories(cls):
        """Create required directories if they don't exist."""
        for directory in [cls.OUTPUT_DIR, cls.UPLOAD_DIR, cls.HF_HOME]:
            os.makedirs(directory, exist_ok=True)
