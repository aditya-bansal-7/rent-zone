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

export const searchMyConversations = async (userId: string, query: string) => {
  const conversations = await prisma.chatConversation.findMany({
    where: {
      participants: { some: { userId } },
      OR: [
        {
          participants: {
            some: {
              userId: { not: userId },
              user: { name: { contains: query, mode: 'insensitive' } }
            }
          }
        },
        {
          messages: {
            some: {
              content: { contains: query, mode: 'insensitive' }
            }
          }
        }
      ]
    },
    include: {
      participants: { include: { user: { select: { id: true, name: true, profileImage: true, isVerified: true } } } },
    },
    orderBy: { updatedAt: 'desc' },
  });

  const enrichedConversations = await Promise.all(
    conversations.map(async (conv) => {
      let message = await prisma.chatMessage.findFirst({
        where: {
          conversationId: conv.id,
          content: { contains: query, mode: 'insensitive' }
        },
        orderBy: { createdAt: 'desc' }
      });
      
      if (!message) {
        message = await prisma.chatMessage.findFirst({
          where: { conversationId: conv.id },
          orderBy: { createdAt: 'desc' }
        });
      }
      
      return {
        ...conv,
        messages: message ? [message] : []
      };
    })
  );

  return enrichedConversations;
};

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
    prisma.chatMessage.create({ data: { conversationId, senderId, content, messageType: 'text' } }),
    prisma.chatConversation.update({ where: { id: conversationId }, data: { updatedAt: new Date() } }),
    prisma.chatParticipant.updateMany({
      where: { conversationId, userId: { not: senderId } },
      data: { unreadCount: { increment: 1 } }
    }),
  ]);

  return message;
};

export const sendImageMessage = async (
  conversationId: string,
  senderId: string,
  imageUrl: string
) => {
  const participant = await prisma.chatParticipant.findFirst({
    where: { conversationId, userId: senderId },
  });
  if (!participant) throw new Error('Not a participant in this conversation');

  const [message] = await prisma.$transaction([
    prisma.chatMessage.create({
      data: {
        conversationId,
        senderId,
        content: '📷 Photo',
        messageType: 'image',
        imageUrl,
      },
    }),
    prisma.chatConversation.update({ where: { id: conversationId }, data: { updatedAt: new Date() } }),
    prisma.chatParticipant.updateMany({
      where: { conversationId, userId: { not: senderId } },
      data: { unreadCount: { increment: 1 } }
    }),
  ]);

  return message;
};

export const sendLocationMessage = async (
  conversationId: string,
  senderId: string,
  locationLat: number,
  locationLng: number,
  locationName?: string
) => {
  const participant = await prisma.chatParticipant.findFirst({
    where: { conversationId, userId: senderId },
  });
  if (!participant) throw new Error('Not a participant in this conversation');

  const displayName = locationName || `${locationLat.toFixed(4)}, ${locationLng.toFixed(4)}`;

  const [message] = await prisma.$transaction([
    prisma.chatMessage.create({
      data: {
        conversationId,
        senderId,
        content: `📍 ${displayName}`,
        messageType: 'location',
        locationLat,
        locationLng,
        locationName: displayName,
      },
    }),
    prisma.chatConversation.update({ where: { id: conversationId }, data: { updatedAt: new Date() } }),
    prisma.chatParticipant.updateMany({
      where: { conversationId, userId: { not: senderId } },
      data: { unreadCount: { increment: 1 } }
    }),
  ]);

  return message;
};


export const markConversationAsRead = async (conversationId: string, userId: string) => {
  await prisma.chatParticipant.updateMany({
    where: { conversationId, userId },
    data: { unreadCount: 0 },
  });
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
