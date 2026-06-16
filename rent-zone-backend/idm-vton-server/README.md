# IDM-VTON Flask Inference Server

Production-ready Flask API server for the [yisol/IDM-VTON](https://huggingface.co/yisol/IDM-VTON) virtual try-on model.

Upload a person image and a garment image, and the server returns a photorealistic image of the person wearing the garment.

## Features

- 🚀 **Model preloading** — loads once at startup, stays in memory
- 🎮 **GPU accelerated** — CUDA support with CPU fallback
- 🔒 **Thread-safe** — serialized GPU access via inference lock
- 📦 **Docker ready** — GPU-enabled Dockerfile + docker-compose
- 📊 **Structured logging** — request timing, inference duration, errors
- ✅ **Input validation** — format, size, required fields
- 🏗️ **Clean architecture** — Flask Blueprints, services, utils

## Quick Start

### Prerequisites

- Python 3.11+
- NVIDIA GPU with 8GB+ VRAM (recommended)
- CUDA 12.1+ and cuDNN
- Git

### 1. Clone and Install

```bash
cd rent-zone-backend/idm-vton-server

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install PyTorch with CUDA support
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# Install dependencies
pip install -r requirements.txt

# Install detectron2 (required for DensePose)
pip install 'git+https://github.com/facebookresearch/detectron2.git'
```

### 2. Setup Models and Checkpoints

```bash
python scripts/setup_models.py
```

This will:
- Clone the IDM-VTON source code (pipeline, UNet, preprocessing)
- Download preprocessing checkpoints (~2GB):
  - Human parsing ONNX models
  - DensePose model
  - OpenPose body pose model

### 3. Configure

```bash
cp .env.example .env
# Edit .env as needed
```

### 4. Start the Server

```bash
# Development
python app.py

# Production (with gunicorn)
gunicorn --bind 0.0.0.0:5000 --workers 1 --timeout 300 --preload app:app
```

## API Reference

### Health Check

```bash
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "device": "cuda",
  "gpu": {
    "name": "NVIDIA GeForce RTX 4090",
    "memory_allocated_mb": 4521.3,
    "memory_reserved_mb": 5120.0,
    "memory_total_mb": 24564.0
  }
}
```

### Virtual Try-On

```bash
POST /api/v1/tryon
Content-Type: multipart/form-data
```

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `person_image` | file | ✅ | Person image (JPEG/PNG/WebP) |
| `garment_image` | file | ✅ | Garment image (JPEG/PNG/WebP) |
| `garment_description` | text | ✅ | Description of the garment |
| `denoise_steps` | int | ❌ | Denoising steps (default: 30) |
| `seed` | int | ❌ | Random seed (default: 42) |

**Response:**
```json
{
  "success": true,
  "image_url": "/outputs/a1b2c3d4-result.png",
  "inference_time_seconds": 12.34
}
```

### Get Generated Image

```bash
GET /outputs/<filename>
```

Returns the generated PNG image.

## Example curl Requests

```bash
# Health check
curl http://localhost:5000/health

# Virtual try-on
curl -X POST http://localhost:5000/api/v1/tryon \
  -F "person_image=@person.jpg" \
  -F "garment_image=@shirt.png" \
  -F "garment_description=blue denim jacket"

# With optional parameters
curl -X POST http://localhost:5000/api/v1/tryon \
  -F "person_image=@person.jpg" \
  -F "garment_image=@shirt.png" \
  -F "garment_description=blue denim jacket" \
  -F "denoise_steps=40" \
  -F "seed=123"

# Download the result
curl http://localhost:5000/outputs/<uuid>-result.png --output result.png
```

## Docker Deployment

### Prerequisites

- Docker 20+
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

### Build and Run

```bash
# Build the image (includes model setup)
docker compose build

# Start the server
docker compose up -d

# View logs
docker compose logs -f idm-vton

# Stop
docker compose down
```

### GPU Verification

```bash
# Verify GPU is accessible in container
docker compose exec idm-vton python -c "import torch; print(torch.cuda.is_available())"
```

## Configuration

All settings are configurable via environment variables (`.env` file):

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `5000` | Server port |
| `DEBUG` | `false` | Enable debug mode |
| `DEVICE` | `auto` | Compute device: `auto`, `cuda`, `cpu`, `mps` |
| `OUTPUT_DIR` | `outputs` | Directory for generated images |
| `HF_HOME` | `./hf_cache` | HuggingFace model cache directory |
| `CHECKPOINT_DIR` | `ckpt` | Preprocessing checkpoint directory |
| `MAX_UPLOAD_MB` | `20` | Maximum upload file size in MB |
| `NUM_INFERENCE_STEPS` | `30` | Default denoising steps |
| `GUIDANCE_SCALE` | `2.0` | Classifier-free guidance scale |
| `SEED` | `42` | Default random seed |
| `MAX_QUEUE_SIZE` | `10` | Maximum queued requests |
| `LOG_LEVEL` | `INFO` | Logging level |

## Project Structure

```
idm-vton-server/
├── app.py                      # Flask app factory + startup
├── config.py                   # Environment configuration
├── requirements.txt            # Python dependencies
├── Dockerfile                  # GPU-enabled Docker image
├── docker-compose.yml          # Docker Compose with GPU
├── routes/
│   ├── health.py               # GET /health
│   ├── tryon.py                # POST /api/v1/tryon
│   └── outputs.py              # GET /outputs/<filename>
├── services/
│   └── idm_vton_service.py     # Model loading + inference
├── models/
│   └── schemas.py              # Response schemas
├── utils/
│   ├── image_utils.py          # Image preprocessing
│   ├── logging_config.py       # Structured logging
│   └── error_handlers.py       # Global error handlers
├── scripts/
│   └── setup_models.py         # Download models & checkpoints
├── src/                        # Vendored IDM-VTON pipeline (auto-setup)
├── preprocess/                 # Vendored preprocessing (auto-setup)
├── configs/                    # DensePose configs (auto-setup)
├── ckpt/                       # Checkpoints (auto-setup, gitignored)
├── outputs/                    # Generated images (gitignored)
└── hf_cache/                   # Model cache (gitignored)
```

## Error Responses

All errors return consistent JSON:

```json
{
  "success": false,
  "error": "Description of the error"
}
```

| Status | Description |
|--------|-------------|
| 400 | Invalid input (missing files, bad format) |
| 404 | Resource not found |
| 413 | File too large |
| 500 | Internal server error |
| 503 | Model still loading |

## Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| GPU VRAM | 8 GB | 12+ GB |
| System RAM | 16 GB | 32 GB |
| Disk Space | 15 GB | 25 GB |
| GPU | NVIDIA GTX 1080 | NVIDIA RTX 3090+ |

## License

This project uses the [IDM-VTON model](https://github.com/yisol/IDM-VTON) which is subject to its own license terms.
