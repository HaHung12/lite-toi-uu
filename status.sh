#!/bin/bash
cd "$(dirname "$(readlink -f "$0")")"

echo "=== Binderfs ==="
mountpoint -q /dev/binderfs && echo "✓ Mounted" || echo "✗ NOT mounted"

echo ""
echo "=== Container ==="
docker compose ps

echo ""
echo "=== Memory ==="
docker stats redroid-lite --no-stream 2>/dev/null || echo "Container not running"

echo ""
echo "=== ADB ==="
adb connect localhost:5555 2>&1
adb -s localhost:5555 shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' | xargs -I{} echo "Boot: {}"
