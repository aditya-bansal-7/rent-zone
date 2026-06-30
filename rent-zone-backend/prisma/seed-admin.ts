import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function seedAdmin() {
  const email = 'admin@rentzone.com';
  const password = 'admin123';

  const existing = await prisma.account.findUnique({ where: { email } });
  if (existing) {
    // Update to admin if exists
    await prisma.account.update({ where: { email }, data: { isAdmin: true } });
    console.log('✅ Existing account updated to admin:', email);
    return;
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await prisma.user.create({
    data: {
      name: 'Super Admin',
      location: 'Mumbai, IN',
      status: 'active',
      account: {
        create: {
          provider: 'email',
          email,
          passwordHash,
          isAdmin: true,
        },
      },
    },
  });

  console.log('✅ Admin user created:', { id: user.id, email });
}

seedAdmin()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
