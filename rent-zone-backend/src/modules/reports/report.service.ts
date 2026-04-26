import prisma from '../../config/db';

export const fileReport = (reportedByUserId: string, reportedUserId: string, reason: string, description: string) => {
  if (reportedByUserId === reportedUserId) throw new Error('Cannot report yourself');
  return prisma.report.create({ data: { reportedByUserId, reportedUserId, reason, description } });
};
