#!/bin/bash
set -e

TARGET_TAG="${1:-redroid-lite:13}"

cd "$(dirname "$(readlink -f "$0")")/.."

echo "[+] Copying strip.sh into build context..."
cp scripts/strip.sh build/strip.sh

echo "[+] Building image (multi-stage)..."
echo "[+] This will pull ubuntu:22.04 and use cached redroid base"
echo ""

# Bỏ --progress, dùng plain docker build
docker build \
    --tag "$TARGET_TAG" \
    build/ 2>&1 | tee /tmp/build.log

BUILD_EXIT=${PIPESTATUS[0]}

# Cleanup
rm -f build/strip.sh

if [ "$BUILD_EXIT" -ne 0 ]; then
    echo ""
    echo "[!] Build failed. See /tmp/build.log for details."
    exit 1
fi

echo ""
echo "[+] === Build complete ==="
docker images "$TARGET_TAG"
echo ""
echo "[+] Compare with base:"
docker images | grep -E "REPOSITORY|redroid-lite|erstt/redroid"
