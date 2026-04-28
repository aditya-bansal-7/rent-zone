import { PrismaClient, CategoryType, ProductCondition, AccountProvider } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // ── Clean existing data ────────────────────────────────────────────────────
  await prisma.chatMessage.deleteMany();
  await prisma.chatParticipant.deleteMany();
  await prisma.chatConversation.deleteMany();
  await prisma.virtualTryOn.deleteMany();
  await prisma.report.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.review.deleteMany();
  await prisma.rental.deleteMany();
  await prisma.product.deleteMany();
  await prisma.category.deleteMany();
  await prisma.account.deleteMany();
  await prisma.user.deleteMany();

  console.log('🗑️  Cleared existing data');

  // ── Categories ─────────────────────────────────────────────────────────────
  const categories = await Promise.all([
    // Women
    prisma.category.create({ data: { name: 'Dresses', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.women } }),
    prisma.category.create({ data: { name: 'Saree', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.women } }),
    prisma.category.create({ data: { name: 'Lehenga', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.women } }),
    prisma.category.create({ data: { name: 'Sharara', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.women } }),
    prisma.category.create({ data: { name: 'Suits', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.women } }),
    prisma.category.create({ data: { name: 'Formals', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.women } }),
    // Men
    prisma.category.create({ data: { name: 'Tuxedos', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.men } }),
    prisma.category.create({ data: { name: 'Kurta', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.men } }),
    prisma.category.create({ data: { name: 'Blazers', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.men } }),
    prisma.category.create({ data: { name: 'Jackets', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.men } }),
    prisma.category.create({ data: { name: 'Formals', image: 'https://res.cloudinary.com/demo/image/upload/v1/samples/ecommerce/leather-bag-gray.jpg', type: CategoryType.men } }),
  ]);

  console.log(`✅ Created ${categories.length} categories`);

  const [
    dressescat, sareecat, lehengacat, shararacat, suitsWomencat, formalsWomencat,
    tuxedocat, kurtacat, blazercat, jacketscat, formalsMencat,
  ] = categories;

  // ── Users ─────────────────────────────────────────────────────────────────
  const passwordHash = await bcrypt.hash('Password123!', 10);

  const user1 = await prisma.user.create({
    data: {
      name: 'Payal Singh',
      location: 'Mumbai',
      isVerified: true,
      profileImage: 'https://i.pravatar.cc/150?img=5',
      account: {
        create: {
          provider: AccountProvider.email,
          email: 'payal@rentzone.com',
          passwordHash,
        },
      },
    },
  });

  const user2 = await prisma.user.create({
    data: {
      name: 'Rohan Mehta',
      location: 'Delhi',
      isVerified: true,
      profileImage: 'https://i.pravatar.cc/150?img=12',
      account: {
        create: {
          provider: AccountProvider.email,
          email: 'rohan@rentzone.com',
          passwordHash,
        },
      },
    },
  });

  const user3 = await prisma.user.create({
    data: {
      name: 'Shreya Kapoor',
      location: 'Bangalore',
      isVerified: false,
      profileImage: 'https://i.pravatar.cc/150?img=9',
      account: {
        create: {
          provider: AccountProvider.email,
          email: 'shreya@rentzone.com',
          passwordHash,
        },
      },
    },
  });

  // Demo account for easy login
  const demoUser = await prisma.user.create({
    data: {
      name: 'Demo User',
      location: 'Mumbai',
      isVerified: true,
      profileImage: 'https://i.pravatar.cc/150?img=1',
      account: {
        create: {
          provider: AccountProvider.email,
          email: 'demo@rentzone.com',
          passwordHash: await bcrypt.hash('demo1234', 10),
        },
      },
    },
  });

  console.log(`✅ Created 4 users`);

  // ── Products ───────────────────────────────────────────────────────────────
  const products = await Promise.all([
    // Women - Sharara
    prisma.product.create({
      data: {
        name: 'Rajasthani Poshak',
        rentPricePerDay: 520,
        securityDeposit: 1000,
        condition: ProductCondition.good,
        size: 'M',
        description: {
          fabric: 'Cotton with Mirror Work',
          brand: 'Traditional Rajasthani',
          style: 'Festive Ethnic',
          fitAndComfort: 'Comfortable traditional fit',
        },
        pickupLocation: 'Mumbai',
        imageURLs: [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400&q=80',
          'https://images.unsplash.com/photo-1583391733975-b8b25e1eb13a?w=400&q=80',
        ],
        rating: 4.5,
        occasion: 'Festival',
        listedBy: { connect: { id: user1.id } },
        category: { connect: { id: shararacat.id } },
      },
    }),
    // Women - Sharara
    prisma.product.create({
      data: {
        name: 'Sharara Set',
        rentPricePerDay: 349,
        securityDeposit: 800,
        condition: ProductCondition.likeNew,
        size: 'S',
        description: {
          fabric: 'Georgette with Sequin Work',
          brand: 'W Inspired',
          style: 'Party Wear',
          fitAndComfort: 'Flowy and lightweight',
        },
        pickupLocation: 'Delhi',
        imageURLs: [
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=400&q=80',
        ],
        rating: 4.5,
        occasion: 'Party',
        listedBy: { connect: { id: user2.id } },
        category: { connect: { id: shararacat.id } },
      },
    }),
    // Men - Tuxedo
    prisma.product.create({
      data: {
        name: 'Black Tuxedo',
        rentPricePerDay: 500,
        securityDeposit: 1200,
        condition: ProductCondition.new,
        size: 'L',
        description: {
          fabric: 'Premium Wool Blend',
          brand: 'Raymond Style',
          style: 'Formal Western',
          fitAndComfort: 'Slim fit with stretch',
        },
        pickupLocation: 'Bangalore',
        imageURLs: [
          'yash.png',
        ],
        rating: 4.0,
        occasion: 'Formal',
        listedBy: { connect: { id: user3.id } },
        category: { connect: { id: tuxedocat.id } },
      },
    }),
    // Women - Lehenga
    prisma.product.create({
      data: {
        name: 'Bridal Lehenga',
        rentPricePerDay: 800,
        securityDeposit: 2000,
        condition: ProductCondition.likeNew,
        size: 'M',
        description: {
          fabric: 'Heavy Silk with Zardozi',
          brand: 'Sabyasachi Inspired',
          style: 'Bridal',
          fitAndComfort: 'Custom fitted with train',
        },
        pickupLocation: 'Mumbai',
        imageURLs: [
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&q=80',
          'https://images.unsplash.com/photo-1620289971783-2c8dcd90d48b?w=400&q=80',
        ],
        rating: 5.0,
        occasion: 'Wedding',
        listedBy: { connect: { id: user1.id } },
        category: { connect: { id: lehengacat.id } },
      },
    }),
    // Women - Lehenga
    prisma.product.create({
      data: {
        name: 'Modern Lehenga',
        rentPricePerDay: 249,
        securityDeposit: 700,
        condition: ProductCondition.likeNew,
        size: 'S',
        description: {
          fabric: 'Net with Thread Work',
          brand: 'Meena Bazaar Style',
          style: 'Indo Western',
          fitAndComfort: 'Semi-fitted comfortable drape',
        },
        pickupLocation: 'Pune',
        imageURLs: [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400&q=80',
        ],
        rating: 4.5,
        occasion: 'Party',
        listedBy: { connect: { id: user2.id } },
        category: { connect: { id: lehengacat.id } },
      },
    }),
    // Women - Dresses
    prisma.product.create({
      data: {
        name: 'Garba Chaniya Choli',
        rentPricePerDay: 249,
        securityDeposit: 600,
        condition: ProductCondition.good,
        size: 'M',
        description: {
          fabric: 'Chaniya Choli Cotton',
          brand: 'Gujarati Traditional',
          style: 'Navratri Special',
          fitAndComfort: 'Free-flowing garba-ready comfort',
        },
        pickupLocation: 'Ahmedabad',
        imageURLs: [
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=400&q=80',
        ],
        rating: 4.3,
        occasion: 'Festival',
        listedBy: { connect: { id: user3.id } },
        category: { connect: { id: dressescat.id } },
      },
    }),
    // Men - Kurta
    prisma.product.create({
      data: {
        name: 'Designer Kurta Set',
        rentPricePerDay: 299,
        securityDeposit: 600,
        condition: ProductCondition.good,
        size: 'L',
        description: {
          fabric: 'Cotton Silk',
          brand: 'Manyavar Inspired',
          style: 'Ethnic Casual',
          fitAndComfort: 'Relaxed straight fit',
        },
        pickupLocation: 'Delhi',
        imageURLs: [
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=400&q=80',
        ],
        rating: 4.2,
        occasion: 'Festival',
        listedBy: { connect: { id: user1.id } },
        category: { connect: { id: kurtacat.id } },
      },
    }),
    // Women - Saree
    prisma.product.create({
      data: {
        name: 'Kanjivaram Silk Saree',
        rentPricePerDay: 600,
        securityDeposit: 1500,
        condition: ProductCondition.likeNew,
        size: 'XL',
        description: {
          fabric: 'Pure Kanjivaram Silk',
          brand: 'Tamil Heritage',
          style: 'Traditional South Indian',
          fitAndComfort: 'Rich drape, 6 yards',
        },
        pickupLocation: 'Chennai',
        imageURLs: [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400&q=80',
        ],
        rating: 4.8,
        occasion: 'Wedding',
        listedBy: { connect: { id: user2.id } },
        category: { connect: { id: sareecat.id } },
      },
    }),
    // Men - Blazer
    prisma.product.create({
      data: {
        name: 'Navy Blue Blazer',
        rentPricePerDay: 350,
        securityDeposit: 900,
        condition: ProductCondition.new,
        size: 'M',
        description: {
          fabric: 'Italian Wool Blend',
          brand: 'Blackberry Style',
          style: 'Business Casual',
          fitAndComfort: 'Regular fit, double vent',
        },
        pickupLocation: 'Hyderabad',
        imageURLs: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
        ],
        rating: 4.6,
        occasion: 'Formal',
        listedBy: { connect: { id: user3.id } },
        category: { connect: { id: blazercat.id } },
      },
    }),
    // Women - Suits
    prisma.product.create({
      data: {
        name: 'Embroidered Anarkali Suit',
        rentPricePerDay: 450,
        securityDeposit: 1000,
        condition: ProductCondition.good,
        size: 'L',
        description: {
          fabric: 'Chiffon with Embroidery',
          brand: 'Biba Style',
          style: 'Festive Ethnic',
          fitAndComfort: 'Floor length, elegant flow',
        },
        pickupLocation: 'Jaipur',
        imageURLs: [
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&q=80',
        ],
        rating: 4.4,
        occasion: 'Wedding',
        listedBy: { connect: { id: user1.id } },
        category: { connect: { id: suitsWomencat.id } },
      },
    }),
  ]);

  console.log(`✅ Created ${products.length} products`);

  // ── Reviews ────────────────────────────────────────────────────────────────
  const review1 = await prisma.review.create({
    data: {
      rating: 5,
      content: 'Absolutely stunning! The outfit was exactly as described and fit perfectly.',
      imageURLs: [],
      product: { connect: { id: products[0].id } },
      user: { connect: { id: user2.id } },
    },
  });

  const review2 = await prisma.review.create({
    data: {
      rating: 4,
      content: 'Beautiful outfit, great quality. Would rent again!',
      imageURLs: [],
      product: { connect: { id: products[0].id } },
      user: { connect: { id: user3.id } },
    },
  });

  const review3 = await prisma.review.create({
    data: {
      rating: 5,
      content: 'Perfect for the wedding! Everyone was asking about this lehenga.',
      imageURLs: [],
      product: { connect: { id: products[3].id } },
      user: { connect: { id: user3.id } },
    },
  });

  console.log(`✅ Created 3 reviews`);

  // Update product ratings
  await prisma.product.update({ where: { id: products[0].id }, data: { rating: 4.5 } });
  await prisma.product.update({ where: { id: products[3].id }, data: { rating: 5.0 } });

  console.log('');
  console.log('✅ Seeding complete!');
  console.log('');
  console.log('📧 Demo accounts:');
  console.log('  payal@rentzone.com  / Password123!');
  console.log('  rohan@rentzone.com  / Password123!');
  console.log('  shreya@rentzone.com / Password123!');
  console.log('  demo@rentzone.com   / demo1234');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
