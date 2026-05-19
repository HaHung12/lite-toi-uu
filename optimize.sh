#!/bin/bash
# Tối ưu RAM v5 sau khi container boot
# Target: ~338 MB idle, ~830 MB với Roblox
# Usage: ./optimize.sh (sau khi ./start.sh)

if [ "$(adb -s localhost:5555 shell getprop sys.boot_completed 2>/dev/null)" != "1" ]; then
    echo "✗ Container chưa boot. Chạy ./start.sh trước, đợi 90s"
    exit 1
fi

echo "=== Memory before ==="
docker stats redroid-lite --no-stream | grep redroid-lite

# Skip Provision
adb -s localhost:5555 shell settings put global device_provisioned 1 > /dev/null 2>&1
adb -s localhost:5555 shell settings put secure user_setup_complete 1 > /dev/null 2>&1

# Disable packages (verified safe with Roblox)
for pkg in \
    android.ext.services \
    com.android.settings.intelligence \
    com.android.providers.media.module \
    com.android.providers.downloads.ui \
    com.android.intentresolver \
    com.android.proxyhandler \
    com.android.vpndialogs \
    com.android.backupconfirm \
    com.android.location.fused \
    com.android.companiondevicemanager
do
    adb -s localhost:5555 shell pm disable-user $pkg > /dev/null 2>&1 || true
done

# Force-stop respawning processes
for proc in \
    com.android.provision \
    com.android.networkstack \
    com.android.packageinstaller \
    android.process.media \
    com.android.systemui \
    android.ext.services \
    com.android.settings.intelligence \
    com.android.providers.media.module
do
    adb -s localhost:5555 shell am force-stop $proc > /dev/null 2>&1 || true
done

# Stop init services
adb -s localhost:5555 shell setprop ctl.stop statsd > /dev/null 2>&1 || true
adb -s localhost:5555 shell setprop ctl.stop incidentd > /dev/null 2>&1 || true

# Kill all idle
adb -s localhost:5555 shell am kill-all > /dev/null 2>&1 || true

sleep 5

echo ""
echo "=== Memory after ==="
docker stats redroid-lite --no-stream | grep redroid-lite

echo ""
echo "✓ Optimize done. Next: ./install-roblox.sh"
