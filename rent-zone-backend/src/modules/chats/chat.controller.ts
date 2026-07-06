import { Request, Response } from 'express';
import * as chatService from './chat.service';
import { sendSuccess, sendError } from '../../utils/response.utils';
import { uploadToCloudinary } from '../../utils/cloudinary.utils';
import multer from 'multer';

export const upload = multer({ storage: multer.memoryStorage() });

export const getConversations = async (req: Request, res: Response) => {
  try {
    const conversations = await chatService.getMyConversations(req.user!.userId);
    sendSuccess(res, conversations);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const startConversation = async (req: Request, res: Response) => {
  try {
    const { otherUserId, productId } = req.body;
    if (!otherUserId) return sendError(res, 'otherUserId is required', 400);
    const conversation = await chatService.getOrCreateConversation(
      req.user!.userId, otherUserId, productId
    );
    sendSuccess(res, conversation, 200, 'Conversation ready');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getMessages = async (req: Request, res: Response) => {
  try {
    const messages = await chatService.getMessages(req.params.id);
    sendSuccess(res, messages);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const sendMessage = async (req: Request, res: Response) => {
  try {
    const { content } = req.body;
    if (!content) return sendError(res, 'content is required', 400);
    const message = await chatService.sendMessage(req.params.id, req.user!.userId, content);
    sendSuccess(res, message, 201, 'Message sent');
  } catch (err: any) {
    const code = err.message === 'Not a participant in this conversation' ? 403 : 400;
    sendError(res, err.message, code);
  }
};

// POST /:id/messages/image — multipart image upload
export const sendImageMessage = async (req: Request, res: Response) => {
  try {
    const file = req.file;
    if (!file) return sendError(res, 'No image provided', 400);

    const imageUrl = await uploadToCloudinary(file.buffer, 'rentzone/chat');
    const message = await chatService.sendImageMessage(
      req.params.id,
      req.user!.userId,
      imageUrl
    );
    sendSuccess(res, message, 201, 'Image message sent');
  } catch (err: any) {
    const code = err.message === 'Not a participant in this conversation' ? 403 : 400;
    sendError(res, err.message, code);
  }
};

// POST /:id/messages/location — send location message
export const sendLocationMessage = async (req: Request, res: Response) => {
  try {
    const { latitude, longitude, locationName } = req.body;
    if (latitude === undefined || longitude === undefined) {
      return sendError(res, 'latitude and longitude are required', 400);
    }
    const message = await chatService.sendLocationMessage(
      req.params.id,
      req.user!.userId,
      parseFloat(latitude),
      parseFloat(longitude),
      locationName
    );
    sendSuccess(res, message, 201, 'Location message sent');
  } catch (err: any) {
    const code = err.message === 'Not a participant in this conversation' ? 403 : 400;
    sendError(res, err.message, code);
  }
};

export const deleteConversation = async (req: Request, res: Response) => {
  try {
    await chatService.deleteConversation(req.params.id, req.user!.userId);
    sendSuccess(res, null, 200, 'Conversation deleted');
  } catch (err: any) {
    const code = err.message === 'Not a participant in this conversation' ? 403 : 400;
    sendError(res, err.message, code);
  }
};

export const searchConversations = async (req: Request, res: Response) => {
  try {
    const { q } = req.query;
    if (!q || typeof q !== 'string') {
      return sendError(res, 'Query parameter q is required', 400);
    }
    const conversations = await chatService.searchMyConversations(req.user!.userId, q);
    sendSuccess(res, conversations);
  } catch (err: any) {
    sendError(res, err.message);
  }
};
