import prisma from '../../config/db';
import { recalculateRating } from '../products/product.service';

export const createReview = async (
  userId: string,
  productId: string,
  rating: number,
  content: string,
  imageURLs: string[] = []
) => {
  const exists = await prisma.review.findFirst({ where: { userId, productId } });
  if (exists) throw new Error('You have already reviewed this product');

  const review = await prisma.review.create({
    data: { userId, productId, rating, content, imageURLs },
    include: { user: { select: { id: true, name: true, profileImage: true } } },
  });

  await recalculateRating(productId);
  return review;
};

export const getProductReviews = (productId: string) =>
  prisma.review.findMany({
    where: { productId },
    include: { user: { select: { id: true, name: true, profileImage: true } } },
    orderBy: { createdAt: 'desc' },
  });

export const deleteReview = async (id: string, userId: string) => {
  const review = await prisma.review.findUnique({ where: { id } });
  if (!review) throw new Error('Review not found');
  if (review.userId !== userId) throw new Error('Forbidden');
  await prisma.review.delete({ where: { id } });
  await recalculateRating(review.productId);
};
