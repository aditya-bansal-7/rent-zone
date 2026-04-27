import bcrypt from 'bcryptjs';
import { AccountProvider } from '@prisma/client';
import prisma from '../../config/db';
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
  JwtPayload,
} from '../../utils/jwt.utils';

// ── Register ──────────────────────────────────────────────────────────────────
export const registerUser = async (
  name: string,
  email: string,
  password: string,
  location: string,
  university?: string,
  phoneNumber?: string,
  preferredCategory?: CategoryType
) => {
  const existing = await prisma.account.findUnique({ where: { email } });
  if (existing) throw new Error('Email already in use');

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await prisma.user.create({
    data: {
      name,
      location,
      university,
      phoneNumber,
      preferredCategory,
      account: { create: { provider: 'email', email, passwordHash } },
    },
    include: { account: { select: { provider: true, email: true } } },
  });

  const payload: JwtPayload = { userId: user.id, email };
  const accessToken = signAccessToken(payload);
  const refreshToken = signRefreshToken(payload);

  await prisma.account.update({ where: { userId: user.id }, data: { refreshToken } });

  const { account, ...userWithoutAccount } = user;
  return { user: { ...userWithoutAccount, provider: account?.provider, email: account?.email }, accessToken, refreshToken };
};

// ── Login ─────────────────────────────────────────────────────────────────────
export const loginUser = async (email: string, password: string) => {
  const account = await prisma.account.findUnique({
    where: { email },
    include: { user: true },
  });

  if (!account || !account.passwordHash) throw new Error('Invalid credentials');

  const isValid = await bcrypt.compare(password, account.passwordHash);
  if (!isValid) throw new Error('Invalid credentials');

  const payload: JwtPayload = { userId: account.userId, email };
  const accessToken = signAccessToken(payload);
  const refreshToken = signRefreshToken(payload);

  await prisma.account.update({ where: { id: account.id }, data: { refreshToken } });

  return { user: account.user, accessToken, refreshToken };
};

// ── OAuth Login ───────────────────────────────────────────────────────────────
export const oauthLogin = async (
  name: string,
  email: string,
  provider: AccountProvider,
  location = ''
) => {
  let account = await prisma.account.findUnique({
    where: { email },
    include: { user: true },
  });

  if (!account) {
    await prisma.user.create({
      data: {
        name,
        location,
        account: { create: { provider, email } },
      },
    });
    account = await prisma.account.findUnique({
      where: { email },
      include: { user: true },
    });
  }

  if (!account) throw new Error('Failed to create or find account');

  const payload: JwtPayload = { userId: account.userId, email };
  const accessToken = signAccessToken(payload);
  const refreshToken = signRefreshToken(payload);

  await prisma.account.update({ where: { email }, data: { refreshToken } });

  return { user: (account as any).user, accessToken, refreshToken };
};

// ── Refresh Tokens ────────────────────────────────────────────────────────────
export const refreshTokens = async (token: string) => {
  const payload = verifyRefreshToken(token);

  const account = await prisma.account.findFirst({
    where: { userId: payload.userId, refreshToken: token },
  });
  if (!account) throw new Error('Invalid refresh token');

  const newPayload: JwtPayload = { userId: payload.userId, email: payload.email };
  const accessToken = signAccessToken(newPayload);
  const refreshToken = signRefreshToken(newPayload);

  await prisma.account.update({ where: { id: account.id }, data: { refreshToken } });

  return { accessToken, refreshToken };
};

// ── Logout ────────────────────────────────────────────────────────────────────
export const logoutUser = async (userId: string) => {
  await prisma.account.update({ where: { userId }, data: { refreshToken: null } });
};

// ── Get Current User ──────────────────────────────────────────────────────────
export const getCurrentUser = async (userId: string) => {
  return prisma.user.findUnique({
    where: { id: userId },
    include: { account: { select: { provider: true, email: true } } },
  });
};
