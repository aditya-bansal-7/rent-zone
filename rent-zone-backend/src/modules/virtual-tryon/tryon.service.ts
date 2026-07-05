import prisma from '../../config/db';
import { uploadToCloudinary } from '../../utils/cloudinary.utils';
import axios from 'axios';

// ── Perfect Corp YCE API v3.0 ──────────────────────────────────────────────────
// No file upload step needed — just pass public image URLs directly.
// Endpoint: POST to start task, GET /{taskId} to poll status.
const YCE_BASE_URL = 'https://yce-api-01.makeupar.com/s2s/v3.0/task/cloth';
const YCE_POLL_INTERVAL_MS = 2000;  // poll every 2 seconds
const YCE_MAX_POLL_ATTEMPTS = 150;  // max 150 × 2s = 5 minutes

const yceHeaders = (apiKey: string) => ({
  'Content-Type': 'application/json',
  Authorization: `Bearer ${apiKey}`,
});

// ── Step 1: Start the try-on task ─────────────────────────────────────────────
async function startTryOnTask(
  personImageURL: string,   // public Cloudinary URL of the person photo
  garmentImageURL: string,  // public Cloudinary URL of the garment
  apiKey: string
): Promise<string> {
  const response = await axios.post(
    YCE_BASE_URL,
    {
      src_file_url: personImageURL,   // person wearing clothes
      ref_file_url: garmentImageURL,  // reference garment to apply
      garment_category: 'auto',       // let YCE detect dress/top/bottom automatically
    },
    { headers: yceHeaders(apiKey), timeout: 30000 }
  );

  const taskId: string | undefined = response.data?.data?.task_id;
  if (!taskId) {
    throw new Error(`YCE task start failed — no task_id in response: ${JSON.stringify(response.data)}`);
  }
  console.log(`[TryOn] YCE task started: ${taskId}`);
  return taskId;
}

// ── Step 2: Poll until task succeeds, return the result image URL ─────────────
async function pollTryOnResult(taskId: string, apiKey: string): Promise<string> {
  const pollURL = `${YCE_BASE_URL}/${encodeURIComponent(taskId)}`;

  for (let attempt = 1; attempt <= YCE_MAX_POLL_ATTEMPTS; attempt++) {
    await new Promise(resolve => setTimeout(resolve, YCE_POLL_INTERVAL_MS));

    const response = await axios.get(pollURL, {
      headers: yceHeaders(apiKey),
      timeout: 15000,
    });

    const data = response.data?.data;
    const taskStatus: string = data?.task_status ?? '';
    console.log(`[TryOn] Poll attempt ${attempt} — status: ${taskStatus}`);

    if (taskStatus === 'success') {
      // YCE v3 returns: { results: { url: "..." }, task_status: "success" }
      const resultURL: string | undefined =
        data?.results?.url ||
        data?.results?.[0]?.url ||   // fallback in case future versions use array
        data?.result_url;

      if (!resultURL) {
        throw new Error(`YCE succeeded but no result URL found: ${JSON.stringify(data)}`);
      }
      return resultURL;
    }

    if (taskStatus === 'error' || taskStatus === 'failed') {
      throw new Error(`YCE task failed: ${JSON.stringify(data)}`);
    }
    // status is 'pending' / 'running' / 'processing' — keep polling
  }

  throw new Error('YCE try-on timed out after 5 minutes. Please try again.');
}

// ── Main exported function ────────────────────────────────────────────────────
// personImageURL: public Cloudinary URL of the person photo (uploaded by controller)
// productId: used to look up the garment Cloudinary URL from the product record
export const createTryOn = async (
  userId: string,
  productId: string,
  personImageURL: string
) => {
  console.log(`[TryOn] Starting — user: ${userId}, product: ${productId}`);

  // 1. Look up the product garment image (already on Cloudinary from product upload)
  const product = await prisma.product.findUnique({ where: { id: productId } });
  if (!product) throw new Error('Product not found');
  if (!product.imageURLs.length) throw new Error('Product has no images');

  const garmentImageURL = product.imageURLs[0];
  console.log(`[TryOn] Garment URL: ${garmentImageURL}`);

  // 2. Get active API keys from the database
  const activeKeys = await prisma.yceApiKey.findMany({
    where: { isActive: true, credits: { gte: 2 } }
  });

  if (activeKeys.length === 0) {
    throw new Error('No active PerfectCorp API keys available with sufficient credits.');
  }

  // 3. Randomly select an API key
  const selectedKeyRecord = activeKeys[Math.floor(Math.random() * activeKeys.length)];
  const apiKey = selectedKeyRecord.key;
  console.log(`[TryOn] Using API key ID: ${selectedKeyRecord.id}`);

  // 4. Start YCE task — just 1 API call, no file uploads needed
  const taskId = await startTryOnTask(personImageURL, garmentImageURL, apiKey);

  // 4. Poll for the result (typically resolves in ~8–20s)
  const yceResultURL = await pollTryOnResult(taskId, apiKey);
  console.log(`[TryOn] YCE result URL: ${yceResultURL}`);

  // 5. Download the YCE result image and store on our Cloudinary
  //    This ensures the result is persisted on our CDN and not dependent on YCE's transient URLs
  const resultBuffer = await axios
    .get(yceResultURL, { responseType: 'arraybuffer', timeout: 30000 })
    .then(r => Buffer.from(r.data));

  const resultImageURL = await uploadToCloudinary(resultBuffer, 'rentzone/tryon');
  console.log(`[TryOn] Result saved to Cloudinary: ${resultImageURL}`);

  // 6. Deduct credits and deactivate key if needed
  const newCredits = selectedKeyRecord.credits - 2;
  await prisma.yceApiKey.update({
    where: { id: selectedKeyRecord.id },
    data: {
      credits: newCredits,
      isActive: newCredits >= 2, // Deactivate if it falls below 2 credits
    }
  });
  console.log(`[TryOn] Deducted 2 credits from key ${selectedKeyRecord.id}. Remaining: ${newCredits}`);

  // 7. Save to database and return
  return prisma.virtualTryOn.create({
    data: {
      userId,
      productId,
      resultImageURL,
      modelUsed: 'perfectcorp-ycev3-cloth',
    },
    include: { product: { select: { id: true, name: true, imageURLs: true } } },
  });
};

// ── Get all try-ons for a user ────────────────────────────────────────────────
export const getMyTryOns = (userId: string) =>
  prisma.virtualTryOn.findMany({
    where: { userId },
    include: { product: { select: { id: true, name: true, imageURLs: true } } },
    orderBy: { createdAt: 'desc' },
  });
