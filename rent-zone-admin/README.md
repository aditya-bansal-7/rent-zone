# Rent Zone Marketplace Studio

The Rent Zone admin web app is the operations workspace for the Rent Zone fashion rental marketplace. It connects to the Express API in `rent-zone-backend` for sign-in, authorization, dashboard data, and marketplace management.

## Run locally

1. Start the backend from `rent-zone-backend` and make sure its environment and database are configured. By default, the API runs at `http://localhost:3000`.
2. In this directory, copy `.env.example` to `.env.local` and set `NEXT_PUBLIC_API_URL` if the backend is hosted somewhere other than the default.
3. Install dependencies and start the web app:

   ```bash
   pnpm install
   pnpm dev
   ```

4. Open the URL printed by Next.js. If the API already occupies port 3000, Next.js will choose another available port.

Sign-in uses the backend `POST /api/auth/login` endpoint and checks administrator access through `GET /api/admin/me`. Admin-only API routes remain protected by the backend; the web app's route proxy is only a navigation convenience.

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `NEXT_PUBLIC_API_URL` | `http://localhost:3000/api` | Base URL for the Rent Zone backend API |

Set this variable to the backend's public API URL in deployed environments. The API URL is public browser configuration and must not contain credentials or secrets.
