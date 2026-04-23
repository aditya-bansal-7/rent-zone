import prisma from '../../config/db';
import { uploadToCloudinary } from '../../utils/cloudinary.utils';

export const createTryOn = async (userId: string, productId: string, buffer: Buffer) => {
  const product = await prisma.product.findUnique({ where: { id: productId } });
  if (!product) throw new Error('Product not found');

  const resultImageURL = await uploadToCloudinary(buffer, 'rentzone/tryon');
  return prisma.virtualTryOn.create({
    data: { userId, productId, resultImageURL },
    include: { product: { select: { id: true, name: true, imageURLs: true } } },
  });
};

export const getMyTryOns = (userId: string) =>
  prisma.virtualTryOn.findMany({
    where: { userId },
    include: { product: { select: { id: true, name: true, imageURLs: true } } },
    orderBy: { createdAt: 'desc' },
  });
