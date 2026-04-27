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
