#!/usr/bin/env bash
set -euo pipefail

if [ -z "${API_BASE_URL:-}" ]; then
  echo "ERROR: Set API_BASE_URL in Vercel → Settings → Environment Variables"
  echo "Example: https://shopping-cart-api.onrender.com/api"
  exit 1
fi

if [ "$API_BASE_URL" = "IMAGE_BASE_URL" ] || [ "$API_BASE_URL" = "\${IMAGE_BASE_URL}" ]; then
  echo "ERROR: API_BASE_URL must be your Render API URL, not the literal text IMAGE_BASE_URL"
  echo "Example: https://your-service.onrender.com/api"
  exit 1
fi

case "$API_BASE_URL" in
  http://localhost*|http://127.0.0.1*)
    echo "WARNING: API_BASE_URL is localhost — production builds need your public Render URL"
    ;;
  https://*) ;;
  *)
    echo "ERROR: API_BASE_URL should start with https:// in production (got: $API_BASE_URL)"
    exit 1
    ;;
esac

if ! [[ "$API_BASE_URL" =~ /api$ ]]; then
  echo "ERROR: API_BASE_URL must end with /api (got: $API_BASE_URL)"
  exit 1
fi

FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  echo "Installing Flutter stable..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_HOME"
fi
export PATH="$FLUTTER_HOME/bin:$PATH"

flutter config --enable-web --no-analytics
flutter precache --web
flutter pub get

DART_DEFINES=(--dart-define="API_BASE_URL=${API_BASE_URL}")
if [ -n "${IMAGE_BASE_URL:-}" ]; then
  DART_DEFINES+=(--dart-define="IMAGE_BASE_URL=${IMAGE_BASE_URL}")
fi

flutter build web --release "${DART_DEFINES[@]}"
echo "Flutter web build complete → build/web"
echo "API_BASE_URL baked in: ${API_BASE_URL}"
