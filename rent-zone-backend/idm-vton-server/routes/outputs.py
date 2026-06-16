"""
Serve generated output images.
"""
import os

from flask import Blueprint, abort, send_from_directory

from config import Config

outputs_bp = Blueprint("outputs", __name__)


@outputs_bp.route("/outputs/<path:filename>", methods=["GET"])
def serve_output(filename: str):
    """
    GET /outputs/<filename>

    Serve a generated try-on result image.
    """
    # Security: prevent directory traversal
    if ".." in filename or filename.startswith("/"):
        abort(404)

    output_dir = os.path.abspath(Config.OUTPUT_DIR)
    filepath = os.path.join(output_dir, filename)

    if not os.path.isfile(filepath):
        abort(404)

    return send_from_directory(output_dir, filename, mimetype="image/png")
