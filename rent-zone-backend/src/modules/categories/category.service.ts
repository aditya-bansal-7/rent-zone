import { CategoryType } from '@prisma/client';
import prisma from '../../config/db';

export const getCategories = (type?: CategoryType) =>
  prisma.category.findMany({
    where: type ? { type } : undefined,
    include: { _count: { select: { products: true } } },
  });

export const createCategory = (name: string, image: string, type: CategoryType) =>
  prisma.category.create({ data: { name, image, type } });

export const getProductsByCategory = (id: string) =>
  prisma.product.findMany({
    where: { categoryId: id },
    include: {
      listedBy: { select: { id: true, name: true, profileImage: true } },
      _count: { select: { reviews: true } },
    },
    orderBy: { createdAt: 'desc' },
  });
