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

1. Push this repo to GitHub (`tintwym/shopping-cart-flutter`).
2. Import the project in [Vercel](https://vercel.com/new).
3. **Root directory:** repository root (this folder).
4. **Environment variables** (required for production builds):

   | Variable | Example |
   |----------|---------|
   | `API_BASE_URL` | `https://shopping-cart-api.onrender.com/api` |
   | `IMAGE_BASE_URL` | `https://shopping-cart-api.onrender.com/images/products` (optional; derived from API URL if omitted) |

5. Deploy. Vercel runs `scripts/vercel-build.sh` (installs Flutter stable, builds web).

### After deploy — backend (Render)

On your Render API service, set:

- `APP_FRONTEND_BASE_URL` → your Vercel URL (e.g. `https://shopping-cart-flutter.vercel.app`)
- Add the same origin to CORS in `FilterConfig.java` / `WebConfig.java` if not already allowed

Stripe checkout success redirect uses `APP_FRONTEND_BASE_URL/payment/success?session_id=...`.

## Tech stack

- Flutter 3.x, Provider, GoRouter, Dio
- Targets: Web (Vercel), Android, iOS
