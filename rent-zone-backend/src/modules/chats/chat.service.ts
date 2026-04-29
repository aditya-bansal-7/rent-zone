import prisma from '../../config/db';

export const getMyConversations = (userId: string) =>
  prisma.chatConversation.findMany({
    where: { participants: { some: { userId } } },
    include: {
      participants: { include: { user: { select: { id: true, name: true, profileImage: true, isVerified: true } } } },
      messages: { orderBy: { createdAt: 'desc' }, take: 1 },
    },
    orderBy: { updatedAt: 'desc' },
  });

export const getOrCreateConversation = async (
  userId: string,
  otherUserId: string,
  productId?: string
) => {
  const existing = await prisma.chatConversation.findFirst({
    where: {
      ...(productId ? { productId } : {}),
      AND: [
        { participants: { some: { userId } } },
        { participants: { some: { userId: otherUserId } } },
      ],
    },
    include: {
      participants: { include: { user: { select: { id: true, name: true, profileImage: true } } } },
      messages: { orderBy: { createdAt: 'asc' } },
    },
  });

  if (existing) return existing;

  return prisma.chatConversation.create({
    data: {
      productId,
      participants: {
        create: [{ userId }, { userId: otherUserId }],
      },
    },
    include: {
      participants: { include: { user: { select: { id: true, name: true, profileImage: true } } } },
      messages: true,
    },
  });
};

export const getMessages = (conversationId: string) =>
  prisma.chatMessage.findMany({
    where: { conversationId },
    orderBy: { createdAt: 'asc' },
  });

export const sendMessage = async (
  conversationId: string,
  senderId: string,
  content: string
) => {
  const participant = await prisma.chatParticipant.findFirst({
    where: { conversationId, userId: senderId },
  });
  if (!participant) throw new Error('Not a participant in this conversation');

  const [message] = await prisma.$transaction([
    prisma.chatMessage.create({ data: { conversationId, senderId, content } }),
    prisma.chatConversation.update({ where: { id: conversationId }, data: { updatedAt: new Date() } }),
  ]);

  return message;
};

export const deleteConversation = async (
  conversationId: string,
  userId: string
) => {
  // Verify the user is a participant
  const participant = await prisma.chatParticipant.findFirst({
    where: { conversationId, userId },
  });
  if (!participant) throw new Error('Not a participant in this conversation');

  // Cascade delete: messages → participants → conversation
  await prisma.$transaction([
    prisma.chatMessage.deleteMany({ where: { conversationId } }),
    prisma.chatParticipant.deleteMany({ where: { conversationId } }),
    prisma.chatConversation.delete({ where: { id: conversationId } }),
  ]);
};
