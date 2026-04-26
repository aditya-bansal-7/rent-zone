import { RentalStatus } from '@prisma/client';
import prisma from '../../config/db';

export const createRental = async (
  rentedByUserId: string,
  productId: string,
  startDate: Date,
  endDate: Date,
  totalPrice: number
) => {
  const product = await prisma.product.findUnique({ where: { id: productId } });
  if (!product) throw new Error('Product not found');
  if (product.listedByUserId === rentedByUserId) throw new Error('Cannot rent your own product');

  const rental = await prisma.rental.create({
    data: {
      productId,
      rentedByUserId,
      rentedFromUserId: product.listedByUserId,
      startDate,
      endDate,
      totalPrice,
      status: 'requested',
    },
    include: { product: true, rentedBy: { select: { id: true, name: true, profileImage: true } } },
  });

  // Notify owner
  await prisma.notification.create({
    data: {
      userId: product.listedByUserId,
      title: 'New Rental Request',
      content: `Someone wants to rent "${product.name}"`,
      icon: 'tag.fill',
      type: 'rentalRequest',
      productId,
      fromUserId: rentedByUserId,
      rentalDate: startDate,
      totalPrice,
      productName: product.name,
      productImageName: product.imageURLs[0] ?? '',
    },
  });

  return rental;
};

export const getMyRentals = (userId: string, role: 'renter' | 'owner') =>
  prisma.rental.findMany({
    where: role === 'renter' ? { rentedByUserId: userId } : { rentedFromUserId: userId },
    include: {
      product: { select: { id: true, name: true, imageURLs: true, rentPricePerDay: true } },
      rentedBy: { select: { id: true, name: true, profileImage: true } },
      rentedFrom: { select: { id: true, name: true, profileImage: true } },
    },
    orderBy: { createdAt: 'desc' },
  });

export const getRentalById = (id: string) =>
  prisma.rental.findUnique({
    where: { id },
    include: {
      product: true,
      rentedBy: { select: { id: true, name: true, profileImage: true } },
      rentedFrom: { select: { id: true, name: true, profileImage: true } },
    },
  });

export const updateRentalStatus = async (id: string, userId: string, status: RentalStatus) => {
  const rental = await prisma.rental.findUnique({ where: { id } });
  if (!rental) throw new Error('Rental not found');

  const isOwner = rental.rentedFromUserId === userId;
  const isRenter = rental.rentedByUserId === userId;

  if (status === 'approved' || status === 'active') {
    if (!isOwner) throw new Error('Only the owner can approve rentals');
  }
  if (status === 'cancelled') {
    if (!isOwner && !isRenter) throw new Error('Forbidden');
  }
  if (status === 'returned') {
    if (!isOwner) throw new Error('Only the owner can mark as returned');
  }

  return prisma.rental.update({ where: { id }, data: { status } });
};
