#!/usr/bin/env bash
set -euo pipefail

if [ -z "${API_BASE_URL:-}" ]; then
  echo "ERROR: Set API_BASE_URL in Vercel → Settings → Environment Variables"
  echo "Example: https://shopping-cart-api.onrender.com/api"
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
