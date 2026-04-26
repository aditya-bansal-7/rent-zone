import prisma from '../../config/db';

export const getUserById = (id: string) =>
  prisma.user.findUnique({
    where: { id },
    select: {
      id: true,
      name: true,
      location: true,
      isVerified: true,
      profileImage: true,
      createdAt: true,
      _count: { select: { products: true, reviews: true } },
    },
  });

export const updateUser = (userId: string, data: { name?: string; location?: string; profileImage?: string }) =>
  prisma.user.update({ where: { id: userId }, data });

export const getFavourites = async (userId: string) => {
  const user = await prisma.user.findUnique({ where: { id: userId }, select: { favouriteProductIds: true } });
  if (!user) throw new Error('User not found');
  return prisma.product.findMany({
    where: { id: { in: user.favouriteProductIds } },
    include: { category: true, listedBy: { select: { id: true, name: true, profileImage: true } } },
  });
};

export const addFavourite = async (userId: string, productId: string) => {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw new Error('User not found');
  if (user.favouriteProductIds.includes(productId)) return user;
  return prisma.user.update({ where: { id: userId }, data: { favouriteProductIds: { push: productId } } });
};

export const removeFavourite = async (userId: string, productId: string) => {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw new Error('User not found');
  return prisma.user.update({
    where: { id: userId },
    data: { favouriteProductIds: user.favouriteProductIds.filter((id) => id !== productId) },
  });
};
