# Shopping Cart — Flutter client

Flutter web and mobile client for the [shopping-cart-backend](https://github.com/tintwym/shopping-cart-backend) API.

## Local development

```bash
flutter pub get
flutter run -d chrome --web-port 8081
```

Backend must be running at `http://localhost:8080`. API URL defaults to `http://localhost:8080/api` on web.

Override at build/run time:

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=https://your-api.onrender.com/api
```

## Deploy to Vercel (web)

See **[DEPLOY.md](../DEPLOY.md)** for the full production checklist (Render + Vercel + Stripe webhook + admin).

1. Push this repo to GitHub.
2. Import the project in [Vercel](https://vercel.com/new).
3. **Root directory:** repository root (this folder).
4. **Environment variables** (required for production builds):

   | Variable | Example |
   |----------|---------|
   | `API_BASE_URL` | `https://your-api.onrender.com/api` |

   Must be your **public Render API URL** ending in `/api`. Do not use `IMAGE_BASE_URL` or localhost.

5. Deploy. Vercel runs `scripts/vercel-build.sh` (validates `API_BASE_URL`, installs Flutter stable, builds web).

### After deploy — backend (Render)

On your Render API service, set `APP_FRONTEND_BASE_URL` to your Vercel URL. Full variable list is in [DEPLOY.md](../DEPLOY.md).

Stripe checkout success redirect uses `APP_FRONTEND_BASE_URL/payment/success?session_id=...`.

## Tech stack

- Flutter 3.x, Provider, GoRouter, Dio
- Targets: Web (Vercel), Android, iOS
