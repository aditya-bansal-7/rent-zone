"""
Global error handlers for consistent JSON error responses.
"""
import logging
import traceback

from flask import Flask, jsonify
from werkzeug.exceptions import HTTPException, RequestEntityTooLarge

logger = logging.getLogger(__name__)


def register_error_handlers(app: Flask):
    """Register global exception handlers on the Flask app."""

    @app.errorhandler(400)
    def bad_request(error):
        return jsonify({
            "success": False,
            "error": str(error.description) if hasattr(error, "description") else "Bad request",
        }), 400

    @app.errorhandler(404)
    def not_found(error):
        return jsonify({
            "success": False,
            "error": "Resource not found",
        }), 404

    @app.errorhandler(405)
    def method_not_allowed(error):
        return jsonify({
            "success": False,
            "error": "Method not allowed",
        }), 405

    @app.errorhandler(413)
    @app.errorhandler(RequestEntityTooLarge)
    def file_too_large(error):
        return jsonify({
            "success": False,
            "error": "File too large. Check MAX_UPLOAD_MB configuration.",
        }), 413

    @app.errorhandler(422)
    def unprocessable(error):
        return jsonify({
            "success": False,
            "error": str(error.description) if hasattr(error, "description") else "Unprocessable entity",
        }), 422

    @app.errorhandler(429)
    def too_many_requests(error):
        return jsonify({
            "success": False,
            "error": "Too many requests. Please try again later.",
        }), 429

    @app.errorhandler(500)
    def internal_error(error):
        logger.error(f"Internal server error: {error}")
        logger.error(traceback.format_exc())
        return jsonify({
            "success": False,
            "error": "Internal server error",
        }), 500

    @app.errorhandler(503)
    def service_unavailable(error):
        return jsonify({
            "success": False,
            "error": "Service unavailable. Model may still be loading.",
        }), 503

    @app.errorhandler(Exception)
    def handle_unexpected_error(error):
        """Catch-all for unhandled exceptions."""
        if isinstance(error, HTTPException):
            return jsonify({
                "success": False,
                "error": error.description,
            }), error.code

        logger.critical(f"Unhandled exception: {error}")
        logger.critical(traceback.format_exc())
        return jsonify({
            "success": False,
            "error": "An unexpected error occurred",
        }), 500
