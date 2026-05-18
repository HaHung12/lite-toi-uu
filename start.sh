#!/bin/bash
# Quick start Redroid lite
set -e
cd "$(dirname "$(readlink -f "$0")")"

# Check binderfs mounted
if ! mountpoint -q /dev/binderfs 2>/dev/null; then
    echo "[!] Binderfs not mounted, starting service..."
    sudo systemctl start binderfs.service
    sleep 2
fi

# Start container
echo "[+] Starting Redroid..."
docker compose up -d

# Wait boot
echo "[+] Waiting 60s for boot..."
sleep 60

# Connect adb
adb disconnect 2>/dev/null
adb connect localhost:5555

# Check
BOOT=$(adb -s localhost:5555 shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
if [ "$BOOT" = "1" ]; then
    echo ""
    echo "[+] ✓ Redroid ready"
    echo "    Memory: $(docker stats redroid-lite --no-stream --format '{{.MemUsage}}')"
    echo ""
    echo "    Connect: adb -s localhost:5555 shell"
    echo "    Install: adb -s localhost:5555 install your-app.apk"
    echo "    Stop:    ./stop.sh"
    echo "    Status:  ./status.sh"
else
    echo ""
    echo "[!] Boot not complete after 60s. Check logs:"
    echo "    docker compose logs"
fi
