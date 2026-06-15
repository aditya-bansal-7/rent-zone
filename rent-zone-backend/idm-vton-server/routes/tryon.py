"""
Virtual try-on endpoint.
"""
import logging
import time
import uuid

from flask import Blueprint, jsonify, request

from config import Config
from models.schemas import error_response, tryon_response
from services.idm_vton_service import get_service
from utils.image_utils import cleanup_file, save_upload, validate_image_file

logger = logging.getLogger(__name__)

tryon_bp = Blueprint("tryon", __name__, url_prefix="/api/v1")


@tryon_bp.route("/tryon", methods=["POST"])
def try_on():
    """
    POST /api/v1/tryon

    Accept multipart form-data with:
        - person_image (required): Person image file (JPEG/PNG/WebP)
        - garment_image (required): Garment image file (JPEG/PNG/WebP)
        - garment_description (required): Text description of the garment
        - denoise_steps (optional): Number of denoising steps (default: 30)
        - seed (optional): Random seed for reproducibility (default: 42)

    Returns:
        JSON with the generated image URL and inference time.
    """
    service = get_service()

    # Check model is loaded
    if not service.model_loaded:
        return jsonify(error_response("Model is still loading. Please try again shortly.")), 503

    # --- Validate inputs ---
    max_size = Config.get_max_content_length()

    # Person image
    person_file = request.files.get("person_image")
    valid, err = validate_image_file(person_file, max_size, "person_image")
    if not valid:
        return jsonify(error_response(err)), 400

    # Garment image
    garment_file = request.files.get("garment_image")
    valid, err = validate_image_file(garment_file, max_size, "garment_image")
    if not valid:
        return jsonify(error_response(err)), 400

    # Garment description
    garment_description = request.form.get("garment_description", "").strip()
    if not garment_description:
        return jsonify(error_response("garment_description is required")), 400

    # Optional parameters
    try:
        denoise_steps = int(request.form.get("denoise_steps", Config.NUM_INFERENCE_STEPS))
        if not 1 <= denoise_steps <= 100:
            return jsonify(error_response("denoise_steps must be between 1 and 100")), 400
    except (ValueError, TypeError):
        return jsonify(error_response("denoise_steps must be a valid integer")), 400

    try:
        seed = int(request.form.get("seed", Config.SEED))
    except (ValueError, TypeError):
        return jsonify(error_response("seed must be a valid integer")), 400

    # --- Save uploaded files ---
    request_id = str(uuid.uuid4())[:8]
    person_path = None
    garment_path = None

    try:
        person_ext = person_file.filename.rsplit(".", 1)[1].lower()
        garment_ext = garment_file.filename.rsplit(".", 1)[1].lower()

        person_path = save_upload(
            person_file, Config.UPLOAD_DIR, f"{request_id}-person.{person_ext}"
        )
        garment_path = save_upload(
            garment_file, Config.UPLOAD_DIR, f"{request_id}-garment.{garment_ext}"
        )

        logger.info(
            f"[{request_id}] Try-on request: "
            f"garment='{garment_description}', steps={denoise_steps}, seed={seed}"
        )

        # --- Run inference ---
        start_time = time.time()

        output_filename = service.run_tryon(
            person_image_path=person_path,
            garment_image_path=garment_path,
            garment_description=garment_description,
            denoise_steps=denoise_steps,
            seed=seed,
        )

        inference_time = time.time() - start_time
        image_url = f"/outputs/{output_filename}"

        logger.info(
            f"[{request_id}] Inference completed in {inference_time:.2f}s -> {image_url}"
        )

        return jsonify(tryon_response(image_url, inference_time)), 200

    except RuntimeError as e:
        logger.error(f"[{request_id}] Inference error: {e}", exc_info=True)
        return jsonify(error_response(f"Inference failed: {str(e)}")), 500

    except Exception as e:
        logger.error(f"[{request_id}] Unexpected error: {e}", exc_info=True)
        return jsonify(error_response("An unexpected error occurred during try-on")), 500

    finally:
        # Clean up uploaded files
        cleanup_file(person_path)
        cleanup_file(garment_path)
