import prisma from '../../config/db';

export const getMyNotifications = (userId: string) =>
  prisma.notification.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
  });

export const markAsRead = async (id: string, userId: string) => {
  const notif = await prisma.notification.findUnique({ where: { id } });
  if (!notif) throw new Error('Notification not found');
  if (notif.userId !== userId) throw new Error('Forbidden');
  return prisma.notification.update({ where: { id }, data: { isRead: true } });
};

export const markAllAsRead = (userId: string) =>
  prisma.notification.updateMany({ where: { userId, isRead: false }, data: { isRead: true } });

export const respondToRequest = async (notificationId: string, userId: string, accept: boolean) => {
  const notif = await prisma.notification.findUnique({ where: { id: notificationId } });
  if (!notif) throw new Error('Notification not found');
  if (notif.userId !== userId) throw new Error('Forbidden');
  if (notif.type !== 'rentalRequest') throw new Error('Not a rental request');

  const status = accept ? 'accepted' : 'rejected';
  
  // Update notification status
  await prisma.notification.update({
    where: { id: notificationId },
    data: { status, isRead: true },
  });

  // Find corresponding rental and update it
  if (notif.productId && notif.fromUserId) {
    const rental = await prisma.rental.findFirst({
      where: {
        productId: notif.productId,
        rentedByUserId: notif.fromUserId,
        rentedFromUserId: userId,
        status: 'requested'
      }
    });

    if (rental) {
      await prisma.rental.update({
        where: { id: rental.id },
        data: { status: accept ? 'approved' : 'cancelled' }
      });
      
      const product = await prisma.product.findUnique({ where: { id: notif.productId }});
      const owner = await prisma.user.findUnique({ where: { id: userId }, select: { name: true, profileImage: true } });

      // Send notification back to renter
      const newNotif = await prisma.notification.create({
        data: {
          userId: rental.rentedByUserId,
          title: `Rental Request ${accept ? 'Accepted' : 'Declined'}`,
          content: `Your request to rent "${product?.name || 'an item'}" has been ${accept ? 'accepted' : 'declined'}.`,
          icon: accept ? 'checkmark.circle.fill' : 'xmark.circle.fill',
          type: 'general',
          status: accept ? 'accepted' : 'rejected',
          productId: notif.productId,
          productName: product?.name,
          productImageName: product?.imageURLs[0],
          fromUserId: userId,
          requesterName: owner?.name ?? 'Owner',
          requesterProfileImage: owner?.profileImage ?? '',
          rentalDate: notif.rentalDate,
          totalPrice: notif.totalPrice,
        }
      });
      
      // Import sendNotificationToUser dynamically or at top. Let's do a require to avoid circular deps if any, or just import at top.
      const { sendNotificationToUser } = require('../../socket');
      sendNotificationToUser(rental.rentedByUserId, newNotif);
    }
  }
};
