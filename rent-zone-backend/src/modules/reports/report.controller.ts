import { Request, Response } from 'express';
import { z } from 'zod';
import * as reportService from './report.service';
import { sendSuccess, sendError } from '../../utils/response.utils';

const schema = z.object({
  reportedUserId: z.string(),
  reason: z.string().min(1),
  description: z.string().min(1),
});

export const createReport = async (req: Request, res: Response) => {
  try {
    const data = schema.parse(req.body);
    const report = await reportService.fileReport(
      req.user!.userId, data.reportedUserId, data.reason, data.description
    );
    sendSuccess(res, report, 201, 'Report submitted');
  } catch (err: any) {
    sendError(res, err.message);
  }
};
