"""
Logging configuration for the IDM-VTON server.
"""
import logging
import sys
import time
from functools import wraps

from flask import Flask, request, g


def setup_logging(app: Flask, log_level: str = "INFO", log_file: str = "server.log"):
    """
    Configure structured logging for the application.

    Sets up console and file handlers with timestamps and contextual information.
    """
    level = getattr(logging, log_level.upper(), logging.INFO)

    # Root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(level)

    # Clear existing handlers
    root_logger.handlers.clear()

    # Formatter
    formatter = logging.Formatter(
        fmt="%(asctime)s | %(levelname)-8s | %(name)-25s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(level)
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)

    # File handler
    try:
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(level)
        file_handler.setFormatter(formatter)
        root_logger.addHandler(file_handler)
    except (OSError, PermissionError) as e:
        root_logger.warning(f"Could not create log file '{log_file}': {e}")

    # Reduce noise from third-party libraries
    logging.getLogger("urllib3").setLevel(logging.WARNING)
    logging.getLogger("werkzeug").setLevel(logging.WARNING)
    logging.getLogger("PIL").setLevel(logging.WARNING)
    logging.getLogger("transformers").setLevel(logging.WARNING)
    logging.getLogger("diffusers").setLevel(logging.WARNING)

    # Register request timing middleware
    _register_request_logging(app)

    app.logger.info(f"Logging initialized at level={log_level}")


def _register_request_logging(app: Flask):
    """Register before/after request hooks for timing and logging."""

    @app.before_request
    def _start_timer():
        g.start_time = time.time()

    @app.after_request
    def _log_request(response):
        if hasattr(g, "start_time"):
            duration_ms = (time.time() - g.start_time) * 1000
            logger = logging.getLogger("request")
            logger.info(
                f"{request.method} {request.path} -> {response.status_code} "
                f"({duration_ms:.1f}ms)"
            )
        return response


def log_duration(func):
    """Decorator to log the duration of a function call."""
    logger = logging.getLogger(func.__module__)

    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        try:
            result = func(*args, **kwargs)
            duration = time.time() - start
            logger.info(f"{func.__name__} completed in {duration:.2f}s")
            return result
        except Exception as e:
            duration = time.time() - start
            logger.error(f"{func.__name__} failed after {duration:.2f}s: {e}")
            raise

    return wrapper
