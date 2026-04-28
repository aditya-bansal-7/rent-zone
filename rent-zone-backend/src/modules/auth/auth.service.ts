import bcrypt from 'bcryptjs';
import { OAuth2Client } from 'google-auth-library';
import appleSignin from 'apple-signin-auth';
import { AccountProvider, CategoryType } from '@prisma/client';
import prisma from '../../config/db';
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
  JwtPayload,
} from '../../utils/jwt.utils';
import { sendOtpEmail } from '../../utils/mailer.utils';

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


const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

async function verifyGoogleToken(idToken: string) {
  const ticket = await googleClient.verifyIdToken({
    idToken,
    audience: process.env.GOOGLE_CLIENT_ID,
  });
  return ticket.getPayload();
}

async function verifyAppleToken(identityToken: string) {
  return appleSignin.verifyIdToken(identityToken, {
    audience: process.env.APPLE_BUNDLE_ID,
  });
}

// ── OAuth Login ───────────────────────────────────────────────────────────────
export const oauthLogin = async (
  provider: AccountProvider,
  idToken: string,
  name?: string, // Fallback if not in token
  location = ''
) => {
  let email: string | undefined;
  let verifiedName: string | undefined = name;

  if (provider === 'google') {
    const payload = await verifyGoogleToken(idToken);
    email = payload?.email;
    verifiedName = payload?.name || name;
  } else if (provider === 'apple') {
    const payload = await verifyAppleToken(idToken);
    email = payload.email;
    // Apple only sends name on first login, so we might need the fallback
  }

  if (!email) throw new Error('Invalid token: email not found');

  let isNewUser = false;
  let account = await prisma.account.findUnique({
    where: { email },
    include: { user: true },
  });

  if (!account) {
    isNewUser = true;
    await prisma.user.create({
      data: {
        name: verifiedName || 'User',
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

  return { user: (account as any).user, accessToken, refreshToken, isNewUser };
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

export const updateProfile = async (
  userId: string,
  data: {
    name?: string;
    location?: string;
    university?: string;
    phoneNumber?: string;
    profileImage?: string;
    preferredCategory?: CategoryType;
  }
) => {
  return prisma.user.update({
    where: { id: userId },
    data,
    include: { account: { select: { provider: true, email: true } } },
  });
};
// ── OTP Logic ───────────────────────────────────────────────────────────────
export const sendOtp = async (email: string) => {
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

  await prisma.oTP.upsert({
    where: { email },
    update: { code: otp, expiresAt },
    create: { email, code: otp, expiresAt },
  });

  await sendOtpEmail(email, otp);
};

export const verifyOtp = async (email: string, code: string) => {
  const otpEntry = await prisma.oTP.findUnique({ where: { email } });

  if (!otpEntry || otpEntry.code !== code) {
    throw new Error('Invalid verification code');
  }

  if (new Date() > otpEntry.expiresAt) {
    throw new Error('Verification code has expired');
  }

  // Delete the OTP after successful verification
  await prisma.oTP.delete({ where: { email } });

  // Check if user already exists
  const account = await prisma.account.findUnique({
    where: { email },
    include: { user: true },
  });

  if (account) {
    const payload: JwtPayload = { userId: account.userId, email };
    const accessToken = signAccessToken(payload);
    const refreshToken = signRefreshToken(payload);
    await prisma.account.update({ where: { id: account.id }, data: { refreshToken } });
    return { user: account.user, accessToken, refreshToken, isNewUser: false };
  }

  return { email, isNewUser: true };
};
