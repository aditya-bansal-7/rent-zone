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

  // Check for overlapping rentals
  const overlappingRental = await prisma.rental.findFirst({
    where: {
      productId,
      status: { in: ['approved', 'active'] },
      OR: [
        { startDate: { lte: endDate }, endDate: { gte: startDate } }
      ]
    }
  });

  if (overlappingRental) {
    throw new Error('This product is already booked for the selected dates');
  }

  // Check if any of the dates are in product.bookedDates
  const bookedDates = product.bookedDates.map(d => d.toISOString().split('T')[0]);
  let current = new Date(startDate);
  while (current <= endDate) {
    if (bookedDates.includes(current.toISOString().split('T')[0])) {
      throw new Error('One or more selected dates are already booked');
    }
    current.setDate(current.getDate() + 1);
  }

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
  const newNotif = await prisma.notification.create({
    data: {
      userId: product.listedByUserId,
      title: 'New Rental Request',
      content: `${rental.rentedBy.name} wants to rent "${product.name}"`,
      icon: 'tag.fill',
      type: 'rentalRequest',
      productId,
      fromUserId: rentedByUserId,
      rentalDate: startDate,
      totalPrice,
      productName: product.name,
      productImageName: product.imageURLs[0] ?? '',
      requesterName: rental.rentedBy.name,
      requesterProfileImage: rental.rentedBy.profileImage ?? '',
    },
  });

  const { sendNotificationToUser } = require('../../socket');
  sendNotificationToUser(product.listedByUserId, newNotif);

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

  const updatedRental = await prisma.rental.update({ 
    where: { id }, 
    data: { status },
    include: { product: true }
  });

  // If approved, update product bookedDates
  if (status === 'approved') {
    const start = new Date(updatedRental.startDate);
    const end = new Date(updatedRental.endDate);
    const newDates: Date[] = [];
    let current = new Date(start);
    while (current <= end) {
      newDates.push(new Date(current));
      current.setDate(current.getDate() + 1);
    }

    await prisma.product.update({
      where: { id: updatedRental.productId },
      data: {
        bookedDates: {
          push: newDates
        }
      }
    });
  }

  return updatedRental;
};
