#!/bin/bash
# Tối ưu RAM sau khi container boot xong
# Chạy sau ./start.sh

echo "=== Đợi boot hoàn tất ==="
sleep 90

adb disconnect 2>/dev/null
adb connect localhost:5555
sleep 3

if [ "$(adb -s localhost:5555 shell getprop sys.boot_completed)" != "1" ]; then
    echo "✗ Boot chưa xong"
    exit 1
fi

echo "✓ Boot OK"
echo ""

# Skip Provision
adb -s localhost:5555 shell settings put global device_provisioned 1
adb -s localhost:5555 shell settings put secure user_setup_complete 1
adb -s localhost:5555 shell am force-stop com.android.provision 2>/dev/null

# Disable ExtServices
adb -s localhost:5555 shell pm disable-user android.ext.services 2>/dev/null
adb -s localhost:5555 shell am force-stop android.ext.services 2>/dev/null

# Clean processes
adb -s localhost:5555 shell am kill-all

sleep 3

echo ""
echo "=== Memory sau optimize ==="
docker stats redroid-lite --no-stream
