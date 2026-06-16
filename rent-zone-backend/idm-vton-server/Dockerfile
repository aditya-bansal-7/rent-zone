# ============================================================
# IDM-VTON Flask Inference Server — Dockerfile
# GPU-enabled build using NVIDIA CUDA runtime
# ============================================================

# Stage 1: Base with CUDA + Python 3.11
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04 AS base

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    git \
    wget \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Upgrade pip
RUN python -m pip install --upgrade pip setuptools wheel

# ============================================================
# Stage 2: Install dependencies
# ============================================================
FROM base AS deps

WORKDIR /app

# Install PyTorch with CUDA 12.1 support
RUN pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# Copy and install requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install detectron2 from source
RUN pip install 'git+https://github.com/facebookresearch/detectron2.git'

# ============================================================
# Stage 3: Application
# ============================================================
FROM deps AS app

WORKDIR /app

# Copy application code
COPY . .

# Run setup script to download checkpoints and source code
RUN python scripts/setup_models.py

# Create required directories
RUN mkdir -p outputs uploads hf_cache

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=300s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Run with gunicorn for production
# - 1 worker because model is GPU-bound and memory-heavy
# - Long timeout for inference (5 minutes)
# - Preload app so model loads once
CMD ["gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "1", \
     "--timeout", "300", \
     "--preload", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "app:app"]
