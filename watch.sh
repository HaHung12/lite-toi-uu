#!/bin/bash
# Chụp ảnh mỗi 10s, lưu /tmp/redroid-latest.png
# Ctrl+C để dừng
# Tip: feh --reload 10 /tmp/redroid-latest.png &

echo "Watching Redroid (10s interval)"
echo "View: feh --reload 10 /tmp/redroid-latest.png &"
echo "Press Ctrl+C to stop"
echo ""

while true; do
    adb -s localhost:5555 exec-out screencap -p > /tmp/redroid-latest.png 2>/dev/null
    echo "[$(date +%H:%M:%S)] Captured ($(ls -lh /tmp/redroid-latest.png | awk '{print $5}'))"
    sleep 10
done
