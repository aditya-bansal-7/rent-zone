"""
Response schema helpers for consistent API responses.
"""
from typing import Any, Optional


def success_response(data: dict = None, **kwargs) -> dict:
    """Build a successful JSON response."""
    response = {"success": True}
    if data:
        response.update(data)
    response.update(kwargs)
    return response


def error_response(error: str, details: Optional[Any] = None) -> dict:
    """Build an error JSON response."""
    response = {
        "success": False,
        "error": error,
    }
    if details is not None:
        response["details"] = details
    return response


def health_response(
    model_loaded: bool,
    device: str,
    gpu_info: Optional[dict] = None,
) -> dict:
    """Build health check response."""
    response = {
        "status": "healthy" if model_loaded else "loading",
        "model_loaded": model_loaded,
        "device": device,
    }
    if gpu_info:
        response["gpu"] = gpu_info
    return response


def tryon_response(image_url: str, inference_time: float) -> dict:
    """Build try-on success response."""
    return success_response(
        image_url=image_url,
        inference_time_seconds=round(inference_time, 2),
    )
