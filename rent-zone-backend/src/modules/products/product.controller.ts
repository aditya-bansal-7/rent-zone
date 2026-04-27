import { Request, Response } from 'express';
import { z } from 'zod';
import { ProductCondition } from '@prisma/client';
import * as productService from './product.service';
import { uploadToCloudinary } from '../../utils/cloudinary.utils';
import { sendSuccess, sendError } from '../../utils/response.utils';

const createSchema = z.object({
  name: z.string().min(2),
  rentPricePerDay: z.coerce.number().positive(),
  securityDeposit: z.coerce.number().min(0),
  condition: z.nativeEnum(ProductCondition),
  size: z.string(),
  categoryId: z.string(),
  pickupLocation: z.string(),
  occasion: z.string().optional(),
  description: z.record(z.string()).optional(),
});

export const listProducts = async (req: Request, res: Response) => {
  try {
    const { categoryId, size, condition, occasion, listedByUserId, minPrice, maxPrice, sort, page, limit } = req.query;
    const result = await productService.getProducts({
      categoryId: categoryId as string,
      size: size as string,
      condition: condition as ProductCondition,
      occasion: occasion as string,
      listedByUserId: listedByUserId as string,
      minPrice: minPrice ? Number(minPrice) : undefined,
      maxPrice: maxPrice ? Number(maxPrice) : undefined,
      sort: sort as any,
      page: page ? Number(page) : 1,
      limit: limit ? Number(limit) : 20,
    });
    sendSuccess(res, result);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getMyProducts = async (req: Request, res: Response) => {
  try {
    const result = await productService.getProducts({
      listedByUserId: req.user!.userId,
      limit: 100,
    });
    sendSuccess(res, result.products);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getProduct = async (req: Request, res: Response) => {
  try {
    const product = await productService.getProductById(req.params.id);
    if (!product) return sendError(res, 'Product not found', 404);
    sendSuccess(res, product);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const createProduct = async (req: Request, res: Response) => {
  try {
    const data = createSchema.parse(req.body);
    const product = await productService.createProduct(req.user!.userId, {
      name: data.name,
      rentPricePerDay: data.rentPricePerDay,
      securityDeposit: data.securityDeposit,
      condition: data.condition,
      size: data.size,
      pickupLocation: data.pickupLocation,
      occasion: data.occasion,
      description: data.description ?? {},
      imageURLs: [],
      category: { connect: { id: data.categoryId } },
    });
    sendSuccess(res, product, 201, 'Product created');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const updateProduct = async (req: Request, res: Response) => {
  try {
    const product = await productService.updateProduct(req.params.id, req.user!.userId, req.body);
    sendSuccess(res, product);
  } catch (err: any) {
    const status = err.message === 'Forbidden' ? 403 : err.message === 'Product not found' ? 404 : 400;
    sendError(res, err.message, status);
  }
};

export const deleteProduct = async (req: Request, res: Response) => {
  try {
    await productService.deleteProduct(req.params.id, req.user!.userId);
    sendSuccess(res, {}, 200, 'Product deleted');
  } catch (err: any) {
    const status = err.message === 'Forbidden' ? 403 : err.message === 'Product not found' ? 404 : 400;
    sendError(res, err.message, status);
  }
};

export const uploadImages = async (req: Request, res: Response) => {
  try {
    const files = req.files as Express.Multer.File[];
    if (!files?.length) return sendError(res, 'No files uploaded', 400);
    const urls = await Promise.all(
      files.map((f) => uploadToCloudinary(f.buffer, 'rentzone/products'))
    );
    const product = await productService.addProductImages(req.params.id, req.user!.userId, urls);
    sendSuccess(res, product, 200, 'Images uploaded');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getBookedDates = async (req: Request, res: Response) => {
  try {
    const dates = await productService.getBookedDates(req.params.id);
    sendSuccess(res, dates);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const toggleFavorite = async (req: Request, res: Response) => {
  try {
    const result = await productService.toggleFavorite(req.user!.userId, req.params.id);
    sendSuccess(res, result);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getFavorites = async (req: Request, res: Response) => {
  try {
    const products = await productService.getFavorites(req.user!.userId);
    sendSuccess(res, products);
  } catch (err: any) {
    sendError(res, err.message);
  }
};
