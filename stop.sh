#!/bin/bash
cd "$(dirname "$(readlink -f "$0")")"
echo "[+] Stopping Redroid..."
docker compose down
echo "[+] Stopped"
