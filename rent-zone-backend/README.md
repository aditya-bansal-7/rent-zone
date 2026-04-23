# Rent Zone Backend

Node.js · TypeScript · Express · Prisma · MongoDB · Cloudinary

## Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Copy env and fill in your values
cp .env.example .env

# 3. Push schema to MongoDB & generate Prisma client
npm run prisma:push
npm run prisma:generate

# 4. Start dev server
npm run dev
```

Server runs at `http://localhost:3000`  
Health check: `GET /health`

---

## Auth API

| Method | Endpoint | Auth | Body |
|--------|----------|------|------|
| POST | `/api/auth/register` | — | `{ name, email, password, location }` |
| POST | `/api/auth/login` | — | `{ email, password }` |
| POST | `/api/auth/oauth` | — | `{ name, email, provider, location }` |
| POST | `/api/auth/refresh` | — | `{ refreshToken }` |
| POST | `/api/auth/logout` | Bearer | — |
| GET | `/api/auth/me` | Bearer | — |

All protected routes require `Authorization: Bearer <accessToken>` header.

---

## Modules & Routes

### Users `/api/users`
| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/:id` | — |
| PATCH | `/me` | ✅ |
| POST | `/me/avatar` | ✅ `multipart/form-data` field: `avatar` |
| GET | `/me/favourites` | ✅ |
| POST | `/me/favourites/:productId` | ✅ |
| DELETE | `/me/favourites/:productId` | ✅ |

### Products `/api/products`
| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/` | — | Query: `categoryId, size, condition, occasion, minPrice, maxPrice, sort, page, limit` |
| GET | `/:id` | — |
| GET | `/:id/booked-dates` | — |
| POST | `/` | ✅ |
| PATCH | `/:id` | ✅ owner only |
| DELETE | `/:id` | ✅ owner only |
| POST | `/:id/images` | ✅ `multipart/form-data` field: `images` (up to 10) |

### Categories `/api/categories`
| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/` | — | Query: `type=men\|women` |
| POST | `/` | ✅ |
| GET | `/:id/products` | — |

### Rentals `/api/rentals` (all protected)
| Method | Endpoint |
|--------|----------|
| POST | `/` |
| GET | `/me?role=renter\|owner` |
| GET | `/:id` |
| PATCH | `/:id/status` — body: `{ status }` |

### Reviews `/api/reviews`
| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/product/:productId` | — |
| POST | `/` | ✅ `multipart/form-data` fields: `productId, rating, content, images` |
| DELETE | `/:id` | ✅ owner only |

### Chats `/api/chats` (all protected)
| Method | Endpoint |
|--------|----------|
| GET | `/` |
| POST | `/` — body: `{ otherUserId, productId? }` |
| GET | `/:id/messages` |
| POST | `/:id/messages` — body: `{ content }` |

### Notifications `/api/notifications` (all protected)
| Method | Endpoint |
|--------|----------|
| GET | `/` |
| PATCH | `/:id/read` |
| PATCH | `/read-all` |

### Reports `/api/reports`
| POST | `/` | ✅ body: `{ reportedUserId, reason, description }` |

### Virtual Try-On `/api/tryon` (all protected)
| Method | Endpoint |
|--------|----------|
| POST | `/` — `multipart/form-data` fields: `productId, image` |
| GET | `/me` |

---

## Environment Variables

See `.env.example` for all required variables.
