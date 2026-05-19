#!/bin/bash
# Cài + Launch Roblox + Disable PermissionController
# Tổng RAM ~830 MB

APK="$HOME/redroid-lite/roblox-apks/roblox.apk"

if [ ! -f "$APK" ]; then
    echo "✗ $APK không tồn tại"
    echo "  Tải Roblox APK đặt vào ~/redroid-lite/roblox-apks/roblox.apk"
    exit 1
fi

if adb -s localhost:5555 shell pm list packages 2>/dev/null | grep -q roblox; then
    echo "Roblox đã cài, launch lại..."
else
    echo "=== Cài Roblox ==="
    adb -s localhost:5555 install "$APK"
    
    echo ""
    echo "=== Grant permissions ==="
    adb -s localhost:5555 shell pm grant com.roblox.client android.permission.RECORD_AUDIO
    adb -s localhost:5555 shell pm grant com.roblox.client android.permission.CAMERA
    
    echo "=== Disable PermissionController (tiết kiệm ~100MB) ==="
    adb -s localhost:5555 shell pm disable-user com.android.permissioncontroller > /dev/null 2>&1
    adb -s localhost:5555 shell am force-stop com.android.permissioncontroller > /dev/null 2>&1
fi

echo ""
echo "=== Launch Roblox ==="
adb -s localhost:5555 shell am start -n com.roblox.client/.startup.ActivitySplash

echo "Đợi 15s..."
sleep 15

echo ""
echo "=== Status ==="
adb -s localhost:5555 shell "ps -A | grep roblox"
docker stats redroid-lite --no-stream | grep redroid-lite

echo ""
echo "✓ Roblox ready. Chụp ảnh: ./snap.sh"
