#!/usr/bin/env python3
"""
Setup script for IDM-VTON server.

Downloads and sets up:
1. IDM-VTON source code (pipeline, UNet modules, preprocessing)
2. Required checkpoints (human parsing, DensePose, OpenPose)
3. DensePose config files

Run this script before starting the server for the first time:
    python scripts/setup_models.py
"""
import os
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

# Project root
ROOT = Path(__file__).parent.parent.absolute()


def log(msg: str):
    print(f"[SETUP] {msg}")


def download_file(url: str, dest: str, desc: str = ""):
    """Download a file from URL to destination."""
    dest_path = Path(dest)
    if dest_path.exists():
        log(f"  ✓ Already exists: {dest}")
        return

    dest_path.parent.mkdir(parents=True, exist_ok=True)
    log(f"  ↓ Downloading {desc or dest_path.name}...")

    try:
        urllib.request.urlretrieve(url, dest)
        size_mb = dest_path.stat().st_size / (1024 * 1024)
        log(f"  ✓ Downloaded: {dest} ({size_mb:.1f} MB)")
    except Exception as e:
        log(f"  ✗ Failed to download {url}: {e}")
        raise


def clone_idm_vton_source():
    """Clone IDM-VTON repo and extract required source files."""
    log("=" * 50)
    log("STEP 1: Setting up IDM-VTON source code")
    log("=" * 50)

    temp_dir = ROOT / "_idm_vton_repo"

    # Check if source files already exist
    src_dir = ROOT / "src"
    preprocess_dir = ROOT / "preprocess"
    if (src_dir / "tryon_pipeline.py").exists() and preprocess_dir.exists():
        log("  ✓ Source files already exist in src/ and preprocess/")
    else:
        log("  Cloning IDM-VTON repository (sparse checkout)...")
        if temp_dir.exists():
            shutil.rmtree(temp_dir)

        subprocess.run([
            "git", "clone", "--depth", "1", "--filter=blob:none", "--sparse",
            "https://github.com/yisol/IDM-VTON.git", str(temp_dir)
        ], check=True, capture_output=True)

        subprocess.run([
            "git", "-C", str(temp_dir), "sparse-checkout", "set",
            "src",
            "preprocess",
            "gradio_demo",
            "configs",
            "ip_adapter"
        ], check=True)

        # Copy source files
        src_dir.mkdir(exist_ok=True)
        for src_file in (temp_dir / "src").glob("*"):
            if src_file.is_file():
                shutil.copy2(src_file, src_dir / src_file.name)
                log(f"  ✓ Copied src/{src_file.name}")

        # Also copy __init__.py if exists
        init_file = temp_dir / "src" / "__init__.py"
        if init_file.exists():
            shutil.copy2(init_file, src_dir / "__init__.py")

        # Create __init__.py if it doesn't exist
        if not (src_dir / "__init__.py").exists():
            (src_dir / "__init__.py").write_text("")

        # Copy preprocessing modules
        preprocess_src = temp_dir / "preprocess"
        preprocess_dst = ROOT / "preprocess"
        if preprocess_src.exists():
            if preprocess_dst.exists():
                shutil.rmtree(preprocess_dst)
            shutil.copytree(preprocess_src, preprocess_dst)
            if not (preprocess_dst / "__init__.py").exists():
                (preprocess_dst / "__init__.py").write_text("")
            log("  ✓ Copied preprocess/")

        # Copy ip_adapter modules
        ip_adapter_src = temp_dir / "ip_adapter"
        ip_adapter_dst = ROOT / "ip_adapter"
        if ip_adapter_src.exists():
            if ip_adapter_dst.exists():
                shutil.rmtree(ip_adapter_dst)
            shutil.copytree(ip_adapter_src, ip_adapter_dst)
            log("  ✓ Copied ip_adapter/")

        # Copy utility files from gradio_demo
        for f in ["utils_mask.py", "apply_net.py"]:
            src_file = temp_dir / "gradio_demo" / f
            if src_file.exists():
                shutil.copy2(src_file, ROOT / f)
                log(f"  ✓ Copied {f}")

        # Copy DensePose configs
        configs_src = temp_dir / "gradio_demo" / "configs"
        configs_dst = ROOT / "configs"
        if configs_src.exists():
            if configs_dst.exists():
                shutil.rmtree(configs_dst)
            shutil.copytree(configs_src, configs_dst)
            log("  ✓ Copied configs/")

        # Clean up temp directory
        shutil.rmtree(temp_dir)
        log("  ✓ Cleaned up temporary clone")


def download_checkpoints():
    """Download required preprocessing checkpoints."""
    log("")
    log("=" * 50)
    log("STEP 2: Downloading checkpoints")
    log("=" * 50)

    ckpt_dir = ROOT / "ckpt"
    base_url = "https://huggingface.co/yisol/IDM-VTON/resolve/main"

    checkpoints = {
        "humanparsing/parsing_atr.onnx": f"{base_url}/humanparsing/parsing_atr.onnx",
        "humanparsing/parsing_lip.onnx": f"{base_url}/humanparsing/parsing_lip.onnx",
        "densepose/model_final_162be9.pkl": f"{base_url}/densepose/model_final_162be9.pkl",
        "openpose/ckpts/body_pose_model.pth": f"{base_url}/openpose/ckpts/body_pose_model.pth",
    }

    for rel_path, url in checkpoints.items():
        dest = ckpt_dir / rel_path
        download_file(url, str(dest), rel_path)


def setup_directories():
    """Create required directories."""
    log("")
    log("=" * 50)
    log("STEP 3: Creating directories")
    log("=" * 50)

    dirs = ["outputs", "uploads", "hf_cache"]
    for d in dirs:
        path = ROOT / d
        path.mkdir(exist_ok=True)
        log(f"  ✓ {d}/")


def verify_setup():
    """Verify all required files are in place."""
    log("")
    log("=" * 50)
    log("VERIFICATION")
    log("=" * 50)

    required_files = [
        "src/tryon_pipeline.py",
        "src/unet_hacked_garmnet.py",
        "src/unet_hacked_tryon.py",
        "src/unet_block_hacked_garmnet.py",
        "src/unet_block_hacked_tryon.py",
        "src/attentionhacked_garmnet.py",
        "src/attentionhacked_tryon.py",
        "src/transformerhacked_garmnet.py",
        "src/transformerhacked_tryon.py",
        "ip_adapter/ip_adapter.py",
        "ip_adapter/resampler.py",
        "ckpt/humanparsing/parsing_atr.onnx",
        "ckpt/humanparsing/parsing_lip.onnx",
        "ckpt/densepose/model_final_162be9.pkl",
        "ckpt/openpose/ckpts/body_pose_model.pth",
    ]

    all_ok = True
    for f in required_files:
        path = ROOT / f
        if path.exists():
            log(f"  ✓ {f}")
        else:
            log(f"  ✗ MISSING: {f}")
            all_ok = False

    if all_ok:
        log("")
        log("✅ Setup complete! You can now start the server:")
        log("   python app.py")
    else:
        log("")
        log("⚠️  Some files are missing. Please check the errors above.")
        sys.exit(1)


if __name__ == "__main__":
    log("IDM-VTON Server Setup")
    log(f"Project root: {ROOT}")
    log("")

    clone_idm_vton_source()
    download_checkpoints()
    setup_directories()
    verify_setup()
