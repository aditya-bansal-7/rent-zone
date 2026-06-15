"""
Health check endpoint.
"""
from flask import Blueprint, jsonify

from services.idm_vton_service import get_service
from models.schemas import health_response

health_bp = Blueprint("health", __name__)


@health_bp.route("/health", methods=["GET"])
def health_check():
    """
    GET /health

    Returns the server health status including model load state,
    device info, and GPU memory stats.
    """
    service = get_service()

    response = health_response(
        model_loaded=service.model_loaded,
        device=service.device,
        gpu_info=service.get_gpu_info(),
    )

    status_code = 200 if service.model_loaded else 503
    return jsonify(response), status_code
