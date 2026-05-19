#!/bin/bash
# Chụp screenshot Redroid
OUT="/tmp/redroid-$(date +%H%M%S).png"
adb -s localhost:5555 exec-out screencap -p > "$OUT"
SIZE=$(ls -lh "$OUT" | awk '{print $5}')
echo "✓ $OUT ($SIZE)"
xdg-open "$OUT" 2>/dev/null &
