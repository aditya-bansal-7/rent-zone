import { Server as HttpServer } from 'http';
import { WebSocketServer, WebSocket } from 'ws';
import * as chatService from './modules/chats/chat.service';
import jwt from 'jsonwebtoken';
import prisma from './config/db';

export interface CustomWebSocket extends WebSocket {
  userId?: string;
}

export const wsClients = new Map<string, CustomWebSocket>();

export const sendNotificationToUser = (userId: string, notification: any) => {
  const ws = wsClients.get(userId);
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({ action: 'newNotification', notification }));
  }
};

export const setupWebSocket = (server: HttpServer) => {
  const wss = new WebSocketServer({ server });

  wss.on('connection', (ws: CustomWebSocket, req) => {
    // Expected URL format: ws://localhost:3000/?token=...
    const url = new URL(req.url || '', `http://${req.headers.host}`);
    const token = url.searchParams.get('token');

    if (!token) {
      ws.close(1008, 'Token required');
      return;
    }

    try {
      const ACCESS_SECRET = process.env.JWT_ACCESS_SECRET || 'access_secret_change_me';
      const decoded = jwt.verify(token, ACCESS_SECRET) as { userId: string };
      ws.userId = decoded.userId;
      wsClients.set(ws.userId, ws);
      console.log(`User ${ws.userId} connected to WS`);
    } catch (err) {
      ws.close(1008, 'Invalid token');
      return;
    }

    ws.on('message', async (data) => {
      try {
        const payload = JSON.parse(data.toString());
        
        if (payload.action === 'sendMessage') {
          const { conversationId, content } = payload;
          if (!conversationId || !content) return;

          // Save message to DB
          const message = await chatService.sendMessage(conversationId, ws.userId!, content);

          // Find participants to broadcast
          const conversation = await prisma.chatConversation.findUnique({
            where: { id: conversationId },
            include: { participants: true },
          });

          if (conversation) {
            const broadcastPayload = JSON.stringify({
              action: 'newMessage',
              message,
            });

            conversation.participants.forEach((p) => {
              const clientWs = wsClients.get(p.userId);
              if (clientWs && clientWs.readyState === WebSocket.OPEN) {
                clientWs.send(broadcastPayload);
              }
            });
          }
        }
      } catch (error) {
        console.error('WS message error:', error);
      }
    });

    ws.on('close', () => {
      if (ws.userId) {
        wsClients.delete(ws.userId);
        console.log(`User ${ws.userId} disconnected from WS`);
      }
    });
  });

  return wss;
};
