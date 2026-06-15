"""
IDM-VTON model service.

Handles model loading, preprocessing, and inference for virtual try-on.
Implements singleton pattern to ensure the model is loaded only once.
"""
import gc
import logging
import os
import threading
import time
import uuid
from typing import Optional, Tuple

import numpy as np
import torch
from PIL import Image
from torchvision import transforms
from torchvision.transforms.functional import to_pil_image

from config import Config
from server_utils.logging_config import log_duration

logger = logging.getLogger(__name__)


class IDMVTONService:
    """
    Singleton service for IDM-VTON virtual try-on inference.

    Loads the model once at startup and reuses it for all requests.
    Thread-safe via a lock on the inference method.
    """

    _instance: Optional["IDMVTONService"] = None
    _lock = threading.Lock()

    def __new__(cls):
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = super().__new__(cls)
                    cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if self._initialized:
            return
        self._initialized = True

        self.device: str = Config.get_device()
        self.model_loaded: bool = False
        self.pipe = None
        self.unet_encoder = None
        self.parsing_model = None
        self.openpose_model = None
        self.tokenizer_one = None
        self.tokenizer_two = None
        self.noise_scheduler = None
        self.text_encoder_one = None
        self.text_encoder_two = None
        self.image_encoder = None
        self.vae = None
        self._inference_lock = threading.Lock()

        # Standard image transform
        self.tensor_transform = transforms.Compose([
            transforms.ToTensor(),
            transforms.Normalize([0.5], [0.5]),
        ])

        logger.info(f"IDMVTONService initialized (device={self.device})")

    @log_duration
    def load_model(self):
        """
        Load all IDM-VTON model components into memory.

        This is called once at server startup. All submodels are loaded
        from the HuggingFace hub and placed on the target device.
        """
        if self.model_loaded:
            logger.info("Model already loaded, skipping")
            return

        logger.info("=" * 60)
        logger.info("LOADING IDM-VTON MODEL")
        logger.info(f"Device: {self.device}")
        logger.info(f"HF_HOME: {Config.HF_HOME}")
        logger.info("=" * 60)

        # Set HF cache directory
        os.environ["HF_HOME"] = Config.HF_HOME
        os.environ["TRANSFORMERS_CACHE"] = os.path.join(Config.HF_HOME, "transformers")
        os.environ["DIFFUSERS_CACHE"] = os.path.join(Config.HF_HOME, "diffusers")

        base_path = "yisol/IDM-VTON"
        dtype = torch.float16 if self.device != "cpu" else torch.float32

        try:
            # --- Import vendored IDM-VTON modules ---
            from src.tryon_pipeline import StableDiffusionXLInpaintPipeline as TryonPipeline
            from src.unet_hacked_garmnet import UNet2DConditionModel as UNet2DConditionModel_ref
            from src.unet_hacked_tryon import UNet2DConditionModel

            from transformers import (
                AutoTokenizer,
                CLIPImageProcessor,
                CLIPTextModel,
                CLIPTextModelWithProjection,
                CLIPVisionModelWithProjection,
            )
            from diffusers import AutoencoderKL, DDPMScheduler

            # 1. UNet (try-on)
            logger.info("Loading UNet (try-on)...")
            unet = UNet2DConditionModel.from_pretrained(
                base_path, subfolder="unet", torch_dtype=dtype,
            )
            unet.requires_grad_(False)

            # 2. Tokenizers
            logger.info("Loading tokenizers...")
            self.tokenizer_one = AutoTokenizer.from_pretrained(
                base_path, subfolder="tokenizer", revision=None, use_fast=False,
            )
            self.tokenizer_two = AutoTokenizer.from_pretrained(
                base_path, subfolder="tokenizer_2", revision=None, use_fast=False,
            )

            # 3. Noise scheduler
            logger.info("Loading noise scheduler...")
            self.noise_scheduler = DDPMScheduler.from_pretrained(
                base_path, subfolder="scheduler",
            )

            # 4. Text encoders
            logger.info("Loading text encoders...")
            self.text_encoder_one = CLIPTextModel.from_pretrained(
                base_path, subfolder="text_encoder", torch_dtype=dtype,
            )
            self.text_encoder_two = CLIPTextModelWithProjection.from_pretrained(
                base_path, subfolder="text_encoder_2", torch_dtype=dtype,
            )

            # 5. Image encoder
            logger.info("Loading image encoder...")
            self.image_encoder = CLIPVisionModelWithProjection.from_pretrained(
                base_path, subfolder="image_encoder", torch_dtype=dtype,
            )

            # 6. VAE
            logger.info("Loading VAE...")
            self.vae = AutoencoderKL.from_pretrained(
                base_path, subfolder="vae", torch_dtype=dtype,
            )

            # 7. UNet Encoder (garment)
            logger.info("Loading UNet Encoder (garment)...")
            self.unet_encoder = UNet2DConditionModel_ref.from_pretrained(
                base_path, subfolder="unet_encoder", torch_dtype=dtype,
            )

            # Freeze all models
            for model in [self.unet_encoder, self.image_encoder,
                          self.vae, unet, self.text_encoder_one,
                          self.text_encoder_two]:
                model.requires_grad_(False)

            # 8. Preprocessing models
            logger.info("Loading preprocessing models (parsing + openpose)...")
            from preprocess.humanparsing.run_parsing import Parsing
            from preprocess.openpose.run_openpose import OpenPose

            gpu_id = 0 if self.device.startswith("cuda") else -1
            self.parsing_model = Parsing(gpu_id)
            self.openpose_model = OpenPose(gpu_id)

            # 9. Assemble pipeline
            logger.info("Assembling TryonPipeline...")
            self.pipe = TryonPipeline.from_pretrained(
                base_path,
                unet=unet,
                vae=self.vae,
                feature_extractor=CLIPImageProcessor(),
                text_encoder=self.text_encoder_one,
                text_encoder_2=self.text_encoder_two,
                tokenizer=self.tokenizer_one,
                tokenizer_2=self.tokenizer_two,
                scheduler=self.noise_scheduler,
                image_encoder=self.image_encoder,
                torch_dtype=dtype,
            )
            self.pipe.unet_encoder = self.unet_encoder

            # Move pipeline to device
            if self.device != "cpu":
                logger.info(f"Moving pipeline to {self.device}...")
                self.pipe.to(self.device)
                self.pipe.unet_encoder.to(self.device)
                if hasattr(self.openpose_model, "preprocessor"):
                    self.openpose_model.preprocessor.body_estimation.model.to(self.device)

            self.model_loaded = True
            logger.info("=" * 60)
            logger.info("MODEL LOADED SUCCESSFULLY")
            self._log_gpu_info()
            logger.info("=" * 60)

        except Exception as e:
            logger.error(f"Failed to load model: {e}", exc_info=True)
            self.model_loaded = False
            raise RuntimeError(f"Model loading failed: {e}") from e

    @log_duration
    def run_tryon(
        self,
        person_image_path: str,
        garment_image_path: str,
        garment_description: str,
        denoise_steps: int = None,
        seed: int = None,
        auto_crop: bool = True,
        auto_mask: bool = True,
    ) -> str:
        """
        Run virtual try-on inference.

        Args:
            person_image_path: Path to the person image.
            garment_image_path: Path to the garment image.
            garment_description: Text description of the garment.
            denoise_steps: Number of denoising steps (default from config).
            seed: Random seed for reproducibility.
            auto_crop: Whether to auto-crop person image to 3:4 ratio.
            auto_mask: Whether to auto-generate the mask.

        Returns:
            Path to the generated output image.

        Raises:
            RuntimeError: If the model is not loaded or inference fails.
        """
        if not self.model_loaded:
            raise RuntimeError("Model is not loaded. Wait for server startup to complete.")

        denoise_steps = denoise_steps or Config.NUM_INFERENCE_STEPS
        seed = seed if seed is not None else Config.SEED

        with self._inference_lock:
            return self._run_inference(
                person_image_path=person_image_path,
                garment_image_path=garment_image_path,
                garment_description=garment_description,
                denoise_steps=denoise_steps,
                seed=seed,
                auto_crop=auto_crop,
                auto_mask=auto_mask,
            )

    def _run_inference(
        self,
        person_image_path: str,
        garment_image_path: str,
        garment_description: str,
        denoise_steps: int,
        seed: int,
        auto_crop: bool,
        auto_mask: bool,
    ) -> str:
        """Internal inference method (called under lock)."""
        from detectron2.data.detection_utils import (
            _apply_exif_orientation,
            convert_PIL_to_numpy,
        )
        from utils_mask import get_mask_location
        import apply_net

        W = Config.IMAGE_WIDTH    # 768
        H = Config.IMAGE_HEIGHT   # 1024
        PW = Config.PREPROCESS_WIDTH   # 384
        PH = Config.PREPROCESS_HEIGHT  # 512

        logger.info(f"Starting inference: garment='{garment_description}', "
                     f"steps={denoise_steps}, seed={seed}")

        # --- Load and prepare images ---
        garment_img = Image.open(garment_image_path).convert("RGB").resize((W, H))
        human_img_orig = Image.open(person_image_path).convert("RGB")

        # Auto-crop to 3:4 aspect ratio
        crop_coords = None
        crop_size = None
        if auto_crop:
            width, height = human_img_orig.size
            target_width = int(min(width, height * (3 / 4)))
            target_height = int(min(height, width * (4 / 3)))
            left = (width - target_width) / 2
            top = (height - target_height) / 2
            right = (width + target_width) / 2
            bottom = (height + target_height) / 2
            cropped_img = human_img_orig.crop((left, top, right, bottom))
            crop_size = cropped_img.size
            crop_coords = (int(left), int(top), int(right), int(bottom))
            human_img = cropped_img.resize((W, H))
        else:
            human_img = human_img_orig.resize((W, H))

        # --- Generate mask ---
        if auto_mask:
            logger.info("Generating auto-mask (parsing + openpose)...")
            keypoints = self.openpose_model(human_img.resize((PW, PH)))
            model_parse, _ = self.parsing_model(human_img.resize((PW, PH)))
            mask, mask_gray = get_mask_location("hd", "upper_body", model_parse, keypoints)
            mask = mask.resize((W, H))
        else:
            from server_utils.image_utils import pil_to_binary_mask
            mask = pil_to_binary_mask(human_img)

        mask_gray = (1 - transforms.ToTensor()(mask)) * self.tensor_transform(human_img)
        mask_gray = to_pil_image((mask_gray + 1.0) / 2.0)

        # --- Generate DensePose ---
        logger.info("Generating DensePose image...")
        human_img_arg = _apply_exif_orientation(human_img.resize((PW, PH)))
        human_img_arg = convert_PIL_to_numpy(human_img_arg, format="BGR")

        densepose_config = os.path.join(
            os.path.dirname(__file__), "..", "configs", "densepose_rcnn_R_50_FPN_s1x.yaml"
        )
        densepose_model = os.path.join(
            Config.CHECKPOINT_DIR, "densepose", "model_final_162be9.pkl"
        )

        args = apply_net.create_argument_parser().parse_args((
            "show", densepose_config, densepose_model, "dp_segm",
            "-v", "--opts", "MODEL.DEVICE", self.device,
        ))
        pose_img = args.func(args, human_img_arg)
        pose_img = pose_img[:, :, ::-1]
        pose_img = Image.fromarray(pose_img).resize((W, H))

        # --- Run diffusion pipeline ---
        logger.info("Running diffusion pipeline...")
        with torch.no_grad():
            with torch.cuda.amp.autocast(enabled=self.device.startswith("cuda")):
                with torch.inference_mode():
                    # Encode prompts
                    prompt = "model is wearing " + garment_description
                    negative_prompt = "monochrome, lowres, bad anatomy, worst quality, low quality"

                    (
                        prompt_embeds,
                        negative_prompt_embeds,
                        pooled_prompt_embeds,
                        negative_pooled_prompt_embeds,
                    ) = self.pipe.encode_prompt(
                        prompt,
                        num_images_per_prompt=1,
                        do_classifier_free_guidance=True,
                        negative_prompt=negative_prompt,
                    )

                    # Cloth prompt embeddings
                    prompt_c = "a photo of " + garment_description
                    if not isinstance(prompt_c, list):
                        prompt_c = [prompt_c]
                    neg_c = [negative_prompt]

                    (prompt_embeds_c, _, _, _) = self.pipe.encode_prompt(
                        prompt_c,
                        num_images_per_prompt=1,
                        do_classifier_free_guidance=False,
                        negative_prompt=neg_c,
                    )

                    # Prepare tensors
                    dtype = torch.float16 if self.device != "cpu" else torch.float32
                    pose_tensor = self.tensor_transform(pose_img).unsqueeze(0).to(
                        self.device, dtype
                    )
                    garment_tensor = self.tensor_transform(garment_img).unsqueeze(0).to(
                        self.device, dtype
                    )
                    generator = torch.Generator(self.device).manual_seed(seed)

                    # Run pipeline
                    images = self.pipe(
                        prompt_embeds=prompt_embeds.to(self.device, dtype),
                        negative_prompt_embeds=negative_prompt_embeds.to(self.device, dtype),
                        pooled_prompt_embeds=pooled_prompt_embeds.to(self.device, dtype),
                        negative_pooled_prompt_embeds=negative_pooled_prompt_embeds.to(
                            self.device, dtype
                        ),
                        num_inference_steps=denoise_steps,
                        generator=generator,
                        strength=1.0,
                        pose_img=pose_tensor,
                        text_embeds_cloth=prompt_embeds_c.to(self.device, dtype),
                        cloth=garment_tensor,
                        mask_image=mask,
                        image=human_img,
                        height=H,
                        width=W,
                        ip_adapter_image=garment_img.resize((W, H)),
                        guidance_scale=Config.GUIDANCE_SCALE,
                    )[0]

        # --- Post-process and save ---
        output_image = images[0]

        if auto_crop and crop_coords and crop_size:
            output_image = output_image.resize(crop_size)
            human_img_orig.paste(output_image, (crop_coords[0], crop_coords[1]))
            output_image = human_img_orig

        # Save output
        os.makedirs(Config.OUTPUT_DIR, exist_ok=True)
        output_filename = f"{uuid.uuid4()}-result.png"
        output_path = os.path.join(Config.OUTPUT_DIR, output_filename)
        output_image.save(output_path, "PNG", quality=95)

        logger.info(f"Output saved: {output_path}")

        # Clean up GPU memory
        if self.device.startswith("cuda"):
            torch.cuda.empty_cache()

        return output_filename

    def get_gpu_info(self) -> Optional[dict]:
        """Get GPU memory information if available."""
        if not torch.cuda.is_available():
            return None

        try:
            return {
                "name": torch.cuda.get_device_name(0),
                "memory_allocated_mb": round(
                    torch.cuda.memory_allocated(0) / 1024 / 1024, 1
                ),
                "memory_reserved_mb": round(
                    torch.cuda.memory_reserved(0) / 1024 / 1024, 1
                ),
                "memory_total_mb": round(
                    torch.cuda.get_device_properties(0).total_mem / 1024 / 1024, 1
                ),
            }
        except Exception:
            return None

    def _log_gpu_info(self):
        """Log GPU info if available."""
        info = self.get_gpu_info()
        if info:
            logger.info(f"GPU: {info['name']}")
            logger.info(
                f"GPU Memory: {info['memory_allocated_mb']}MB allocated / "
                f"{info['memory_total_mb']}MB total"
            )
        else:
            logger.info("No GPU detected, running on CPU")


# Module-level singleton accessor
def get_service() -> IDMVTONService:
    """Get the singleton IDMVTONService instance."""
    return IDMVTONService()
