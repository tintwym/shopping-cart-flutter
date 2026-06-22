#!/usr/bin/env bash
set -euo pipefail

DEFAULT_API_URL="https://shopping-cart-backend-slwz.onrender.com/api"
API_BASE_URL="${API_BASE_URL:-$DEFAULT_API_URL}"

if [ "$API_BASE_URL" = "IMAGE_BASE_URL" ] || [ "$API_BASE_URL" = "\${IMAGE_BASE_URL}" ]; then
  echo "WARNING: API_BASE_URL was IMAGE_BASE_URL — using default: $DEFAULT_API_URL"
  API_BASE_URL="$DEFAULT_API_URL"
fi

case "$API_BASE_URL" in
  http://localhost*|http://127.0.0.1*)
    echo "WARNING: API_BASE_URL is localhost — production should use your Render URL"
    ;;
  https://*) ;;
  http://*)
    echo "WARNING: API_BASE_URL should use https in production (got: $API_BASE_URL)"
    ;;
  *)
    echo "ERROR: API_BASE_URL must be a full https URL ending in /api (got: $API_BASE_URL)"
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

META_TAG="<meta name=\"api-base-url\" content=\"${API_BASE_URL}\">"
INDEX=web/index.html
if grep -q 'VERCEL_API_BASE_URL' "$INDEX"; then
  if sed --version 2>/dev/null | grep -q GNU; then
    sed -i "s|<!--VERCEL_API_BASE_URL-->|${META_TAG}|" "$INDEX"
  else
    sed -i '' "s|<!--VERCEL_API_BASE_URL-->|${META_TAG}|" "$INDEX"
  fi
elif grep -q 'name="api-base-url"' "$INDEX"; then
  if sed --version 2>/dev/null | grep -q GNU; then
    sed -i "s|<meta name=\"api-base-url\" content=\"[^\"]*\">|${META_TAG}|" "$INDEX"
  else
    sed -i '' "s|<meta name=\"api-base-url\" content=\"[^\"]*\">|${META_TAG}|" "$INDEX"
  fi
else
  echo "WARNING: Could not inject api-base-url meta into $INDEX"
fi

DART_DEFINES=(--dart-define="API_BASE_URL=${API_BASE_URL}")
if [ -n "${IMAGE_BASE_URL:-}" ] && [ "$IMAGE_BASE_URL" != "IMAGE_BASE_URL" ]; then
  DART_DEFINES+=(--dart-define="IMAGE_BASE_URL=${IMAGE_BASE_URL}")
fi

flutter build web --release --no-wasm-dry-run "${DART_DEFINES[@]}"
echo "Flutter web build complete → build/web"
echo "API_BASE_URL baked in: ${API_BASE_URL}"
