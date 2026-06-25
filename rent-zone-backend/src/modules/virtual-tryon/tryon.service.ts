import prisma from '../../config/db';
import { uploadToCloudinary } from '../../utils/cloudinary.utils';
import axios from 'axios';

const OPENROUTER_API_URL = 'https://openrouter.ai/api/v1/chat/completions';

export const createTryOn = async (userId: string, productId: string, personImageBuffer: Buffer) => {
  console.log(`[TryOn] Starting createTryOn for user: ${userId}, product: ${productId}`);
  // 1. Fetch the product to get its clothing image
  const product = await prisma.product.findUnique({ where: { id: productId } });
  if (!product) throw new Error('Product not found');
  if (!product.imageURLs.length) throw new Error('Product has no images');

  console.log(product)
  const clothingImageUrl = product.imageURLs[1];

  // 2. Convert person image buffer to base64 data URL
  const personBase64 = personImageBuffer.toString('base64');
  const personDataUrl = `data:image/jpeg;base64,${personBase64}`;

  // 3. Call OpenRouter API
  console.log(`[TryOn] Preparing to call OpenRouter API...`);
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey || apiKey === 'your_openrouter_api_key_here') {
    throw new Error('OpenRouter API key is not configured. Please set OPENROUTER_API_KEY in your .env file.');
  }

  let openRouterResponse;
  try {
    openRouterResponse = await axios.post(
      OPENROUTER_API_URL,
      {
        model: 'google/gemini-2.5-flash-image',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: `Virtual try-on task.

Image 1 = person (full body photo)
Image 2 = clothing item

Replace the person's current clothing with the garment from image 2.
Keep face, pose, body shape, lighting and background unchanged.`
              },
              {
                type: 'image_url',
                image_url: { url: personDataUrl }
              },
              {
                type: 'image_url',
                image_url: { url: clothingImageUrl }
              }
            ]
          }
        ]
      },
      {
        headers: {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://rentzone.app',
          'X-Title': 'RentZone Virtual Try-On'
        },
        timeout: 120000 // 2 minute timeout for image generation
      }
    );
  } catch (err: any) {
    const msg = err.response?.data?.error?.message || err.message || 'OpenRouter API call failed';
    console.error('[TryOn] OpenRouter API error:', msg);
    throw new Error(`AI processing failed: ${msg}`);
  }

  // 4. Extract response
  const fs = require('fs');
  const path = require('path');
  const debugPath = path.join(process.cwd(), 'openrouter-response.json');
  fs.writeFileSync(debugPath, JSON.stringify(openRouterResponse.data, null, 2));
  console.log(`[TryOn] OpenRouter API raw response saved to: ${debugPath}`);
  
  // Log truncated version to terminal
  const logData = JSON.parse(JSON.stringify(openRouterResponse.data));
  const logMessage = logData?.choices?.[0]?.message;
  if (logMessage) {
    if (logMessage.content) {
      logMessage.content = logMessage.content.substring(0, 100) + (logMessage.content.length > 100 ? '... [TRUNCATED]' : '');
    }
    if (logMessage.images?.[0]?.image_url?.url) {
      logMessage.images[0].image_url.url = logMessage.images[0].image_url.url.substring(0, 50) + '... [TRUNCATED BASE64]';
    }
  }
  console.log(`[TryOn] OpenRouter API response structure:`, JSON.stringify(logData, null, 2));

  const choice = openRouterResponse.data?.choices?.[0];
  const modelUsed = openRouterResponse.data?.model || 'unknown';
  console.log(`[TryOn] Model used: ${modelUsed}`);

  const message = choice?.message;
  if (!message) {
    throw new Error('AI returned an empty response. Please try again.');
  }

  let resultImageURL: string;
  const content = message.content || '';
  const imageUrlObj = message.images?.[0]?.image_url?.url;
  
  let base64String = '';
  let plainImageURL = '';

  if (imageUrlObj) {
    if (imageUrlObj.startsWith('data:image')) {
      const match = imageUrlObj.match(/data:image\/[^;]+;base64,([A-Za-z0-9+/=]+)/);
      if (match) base64String = match[1];
    } else {
      plainImageURL = imageUrlObj;
    }
  } else if (content) {
    const match = content.match(/data:image\/[^;]+;base64,([A-Za-z0-9+/=]+)/);
    if (match) base64String = match[1];
  }

  const markdownImageMatch = content.match(/!\[.*?\]\((https?:\/\/[^\s)]+)\)/);
  const plainUrlMatch = content.match(/(https?:\/\/\S+\.(?:png|jpg|jpeg|webp|gif))/i);

  console.log(`[TryOn] AI response content preview:`, content.substring(0, 200));

  if (base64String) {
    // Response contains a base64 image — upload to Cloudinary
    const imageBuffer = Buffer.from(base64String, 'base64');
    resultImageURL = await uploadToCloudinary(imageBuffer, 'rentzone/tryon');
  } else if (plainImageURL) {
    resultImageURL = plainImageURL;
  } else if (markdownImageMatch) {
    // Response contains a markdown image URL
    resultImageURL = markdownImageMatch[1];
  } else if (plainUrlMatch) {
    // Response contains a plain image URL
    resultImageURL = plainUrlMatch[1];
  } else {
    // The model returned text only — no image generated
    console.warn(`[TryOn] Model ${modelUsed} returned text instead of image:`, content.substring(0, 200));
    throw new Error(
      'The AI model could not generate a try-on image. This may happen with auto-routing. Please try again.'
    );
  }

  // 5. Save to database
  return prisma.virtualTryOn.create({
    data: { userId, productId, resultImageURL, modelUsed },
    include: { product: { select: { id: true, name: true, imageURLs: true } } },
  });
};

export const getMyTryOns = (userId: string) =>
  prisma.virtualTryOn.findMany({
    where: { userId },
    include: { product: { select: { id: true, name: true, imageURLs: true } } },
    orderBy: { createdAt: 'desc' },
  });
