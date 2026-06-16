"""Route blueprints package."""
from flask import Flask

from .health import health_bp
from .tryon import tryon_bp
from .outputs import outputs_bp


def register_routes(app: Flask):
    """Register all route blueprints with the Flask app."""
    app.register_blueprint(health_bp)
    app.register_blueprint(tryon_bp)
    app.register_blueprint(outputs_bp)
