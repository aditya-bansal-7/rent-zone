import { Request, Response } from 'express';
import { CategoryType } from '@prisma/client';
import * as categoryService from './category.service';
import { sendSuccess, sendError } from '../../utils/response.utils';

export const listCategories = async (req: Request, res: Response) => {
  try {
    const { type } = req.query;
    const categories = await categoryService.getCategories(type as CategoryType);
    sendSuccess(res, categories);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const createCategory = async (req: Request, res: Response) => {
  try {
    const { name, image, type } = req.body;
    if (!name || !image || !type) return sendError(res, 'name, image, and type are required', 400);
    const category = await categoryService.createCategory(name, image, type as CategoryType);
    sendSuccess(res, category, 201, 'Category created');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getCategoryProducts = async (req: Request, res: Response) => {
  try {
    const products = await categoryService.getProductsByCategory(req.params.id);
    sendSuccess(res, products);
  } catch (err: any) {
    sendError(res, err.message);
  }
};
