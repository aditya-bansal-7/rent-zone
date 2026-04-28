import { ProductCondition, Prisma } from '@prisma/client';
import prisma from '../../config/db';

interface ProductFilters {
  categoryId?: string;
  size?: string;
  condition?: ProductCondition;
  occasion?: string;
  listedByUserId?: string;
  minPrice?: number;
  maxPrice?: number;
  sort?: 'priceLowToHigh' | 'priceHighToLow' | 'ratingHighToLow' | 'newest';
  page?: number;
  limit?: number;
}

export const getProducts = async (filters: ProductFilters = {}) => {
  const {
    categoryId, size, condition, occasion, listedByUserId,
    minPrice, maxPrice, sort = 'newest',
    page = 1, limit = 20,
  } = filters;

  const where: Prisma.ProductWhereInput = {
    ...(categoryId && { categoryId }),
    ...(size && { size }),
    ...(condition && { condition }),
    ...(occasion && { occasion }),
    ...(listedByUserId && { listedByUserId }),
    ...(minPrice !== undefined || maxPrice !== undefined
      ? { rentPricePerDay: { gte: minPrice, lte: maxPrice } }
      : {}),
  };

  const orderBy: Prisma.ProductOrderByWithRelationInput =
    sort === 'priceLowToHigh' ? { rentPricePerDay: 'asc' }
    : sort === 'priceHighToLow' ? { rentPricePerDay: 'desc' }
    : sort === 'ratingHighToLow' ? { rating: 'desc' }
    : { createdAt: 'desc' };

  const [products, total] = await Promise.all([
    prisma.product.findMany({
      where,
      orderBy,
      skip: (page - 1) * limit,
      take: limit,
      include: {
        category: true,
        listedBy: { select: { id: true, name: true, profileImage: true, isVerified: true } },
        _count: { select: { reviews: true } },
      },
    }),
    prisma.product.count({ where }),
  ]);

  return { products, total, page, limit, totalPages: Math.ceil(total / limit) };
};

export const getProductById = (id: string) =>
  prisma.product.findUnique({
    where: { id },
    include: {
      category: true,
      listedBy: { select: { id: true, name: true, profileImage: true, isVerified: true, location: true } },
      reviews: {
        include: { user: { select: { id: true, name: true, profileImage: true } } },
        orderBy: { createdAt: 'desc' },
      },
    },
  });

export const createProduct = (userId: string, data: Omit<Prisma.ProductCreateInput, 'listedBy'>) =>
  prisma.product.create({
    data: { ...data, listedBy: { connect: { id: userId } } } as Prisma.ProductCreateInput,
    include: { category: true },
  });

export const updateProduct = async (id: string, userId: string, data: Partial<Prisma.ProductUpdateInput>) => {
  const product = await prisma.product.findUnique({ where: { id } });
  if (!product) throw new Error('Product not found');
  if (product.listedByUserId !== userId) throw new Error('Forbidden');
  return prisma.product.update({ where: { id }, data });
};

export const deleteProduct = async (id: string, userId: string) => {
  const product = await prisma.product.findUnique({ where: { id } });
  if (!product) throw new Error('Product not found');
  if (product.listedByUserId !== userId) throw new Error('Forbidden');
  await prisma.product.delete({ where: { id } });
};

export const addProductImages = async (id: string, userId: string, urls: string[]) => {
  const product = await prisma.product.findUnique({ where: { id } });
  if (!product) throw new Error('Product not found');
  if (product.listedByUserId !== userId) throw new Error('Forbidden');
  return prisma.product.update({
    where: { id },
    data: { imageURLs: { push: urls } },
  });
};

export const recalculateRating = async (productId: string) => {
  const agg = await prisma.review.aggregate({ where: { productId }, _avg: { rating: true } });
  await prisma.product.update({
    where: { id: productId },
    data: { rating: agg._avg.rating ?? 0 },
  });
};

export const getBookedDates = async (id: string) => {
  const product = await prisma.product.findUnique({ where: { id }, select: { bookedDates: true } });
  if (!product) throw new Error('Product not found');
  return product.bookedDates;
};

export const toggleFavorite = async (userId: string, productId: string) => {
  const user = await prisma.user.findUnique({ where: { id: userId }, select: { favouriteProductIds: true } });
  if (!user) throw new Error('User not found');

  const favorites = user.favouriteProductIds || [];
  const isFavorited = favorites.includes(productId);

  const updatedUser = await prisma.user.update({
    where: { id: userId },
    data: {
      favouriteProductIds: isFavorited
        ? { set: favorites.filter((id) => id !== productId) }
        : { push: productId },
    },
    select: { favouriteProductIds: true },
  });

  return { isFavorited: !isFavorited, favoriteIds: updatedUser.favouriteProductIds };
};

export const getFavorites = async (userId: string) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { favouriteProductIds: true },
  });

  if (!user) throw new Error('User not found');

  return prisma.product.findMany({
    where: { id: { in: user.favouriteProductIds } },
    include: {
      category: true,
      listedBy: { select: { id: true, name: true, profileImage: true, isVerified: true } },
      _count: { select: { reviews: true } },
    },
  });
};
