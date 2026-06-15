"""
Image utility functions for preprocessing and validation.
"""
import logging
import os
from typing import Optional, Tuple

import numpy as np
from PIL import Image
from werkzeug.datastructures import FileStorage

logger = logging.getLogger(__name__)

# Supported image formats
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "webp"}
ALLOWED_MIME_TYPES = {"image/png", "image/jpeg", "image/webp"}


def validate_image_file(
    file: FileStorage,
    max_size_bytes: int,
    field_name: str = "image",
) -> Tuple[bool, Optional[str]]:
    """
    Validate an uploaded image file.

    Returns:
        (is_valid, error_message) tuple.
    """
    if file is None or file.filename == "":
        return False, f"{field_name} is required"

    # Check file extension
    ext = _get_extension(file.filename)
    if ext not in ALLOWED_EXTENSIONS:
        return False, (
            f"{field_name} has unsupported format '.{ext}'. "
            f"Allowed: {', '.join(sorted(ALLOWED_EXTENSIONS))}"
        )

    # Check MIME type
    if file.content_type and file.content_type not in ALLOWED_MIME_TYPES:
        return False, (
            f"{field_name} has unsupported MIME type '{file.content_type}'. "
            f"Allowed: {', '.join(sorted(ALLOWED_MIME_TYPES))}"
        )

    # Check file size
    file.seek(0, os.SEEK_END)
    file_size = file.tell()
    file.seek(0)

    if file_size > max_size_bytes:
        max_mb = max_size_bytes / (1024 * 1024)
        return False, f"{field_name} exceeds maximum size of {max_mb:.0f}MB"

    if file_size == 0:
        return False, f"{field_name} is empty"

    return True, None


def save_upload(file: FileStorage, upload_dir: str, filename: str) -> str:
    """Save an uploaded file and return the full path."""
    os.makedirs(upload_dir, exist_ok=True)
    filepath = os.path.join(upload_dir, filename)
    file.save(filepath)
    return filepath


def load_and_resize(
    image_path: str,
    width: int,
    height: int,
) -> Image.Image:
    """Load an image and resize to the specified dimensions."""
    img = Image.open(image_path).convert("RGB")
    img = img.resize((width, height), Image.LANCZOS)
    return img


def auto_crop_to_aspect(
    image: Image.Image,
    target_ratio: float = 3.0 / 4.0,
) -> Tuple[Image.Image, Tuple[int, int, int, int]]:
    """
    Auto-crop an image to the target aspect ratio (width/height).

    Returns:
        (cropped_image, (left, top, right, bottom)) crop coordinates.
    """
    width, height = image.size
    target_width = int(min(width, height * target_ratio))
    target_height = int(min(height, width / target_ratio))

    left = (width - target_width) // 2
    top = (height - target_height) // 2
    right = left + target_width
    bottom = top + target_height

    cropped = image.crop((left, top, right, bottom))
    return cropped, (left, top, right, bottom)


def pil_to_binary_mask(pil_image: Image.Image, threshold: int = 0) -> Image.Image:
    """Convert a PIL image to a binary mask."""
    np_image = np.array(pil_image)
    grayscale = Image.fromarray(np_image).convert("L")
    binary = np.array(grayscale) > threshold
    mask = (binary.astype(np.uint8) * 255)
    return Image.fromarray(mask)


def cleanup_file(filepath: str):
    """Safely remove a file if it exists."""
    try:
        if filepath and os.path.exists(filepath):
            os.remove(filepath)
    except OSError as e:
        logger.warning(f"Failed to clean up file {filepath}: {e}")


def _get_extension(filename: str) -> str:
    """Extract lowercase file extension."""
    if "." not in filename:
        return ""
    return filename.rsplit(".", 1)[1].lower()
