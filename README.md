# Redroid Lite v5

Lightweight Android-in-Docker for Roblox login + screencap on Linux.

## Performance

| Metric | Value |
|---|---|
| Image size | ~1.2 GB |
| RAM idle | **~338 MB** |
| RAM with Roblox | **~830 MB** |
| Boot time | ~90 sec |

## Specs

- Android 13 + NDK x86_64 translation (ChromeOS variant)
- GPU host mode (Mesa Intel passthrough)
- Resolution 1024x600 @ 240dpi
- Tested on Ubuntu 22.04 + Intel Iris Xe

## Requirements

- Linux (Ubuntu 22.04+ recommended)
- Docker + binderfs kernel module
- ~3 GB free disk
- Intel/AMD GPU with Mesa driver

## Setup

### 1. Build image (lần đầu)

```bash
### 2. Daily workflow

```bash
### 3. Tải Roblox APK

```bash
cd ~/redroid-lite

cat > README.md << 'EOF'
# Redroid Lite v5

Lightweight Android-in-Docker for Roblox login + screencap on Linux.

## Performance

| Metric | Value |
|---|---|
| Image size | ~1.2 GB |
| RAM idle | **~338 MB** |
| RAM with Roblox | **~830 MB** |
| Boot time | ~90 sec |

## Specs

- Android 13 + NDK x86_64 translation (ChromeOS variant)
- GPU host mode (Mesa Intel passthrough)
- Resolution 1024x600 @ 240dpi
- Tested on Ubuntu 22.04 + Intel Iris Xe

## Requirements

- Linux (Ubuntu 22.04+ recommended)
- Docker + binderfs kernel module
- ~3 GB free disk
- Intel/AMD GPU with Mesa driver

## Setup

### 1. Build image (lần đầu)

```bash
docker build -t redroid-lite:13-v5 build/
```

### 2. Daily workflow

```bash
cd ~/redroid-lite

./start.sh              # Boot container
sleep 90                # Wait Android boot
./optimize.sh           # Apply RAM optimizations → ~338 MB

./install-roblox.sh     # Install + launch Roblox → ~830 MB

./snap.sh               # One-shot screenshot
./watch.sh &            # Continuous capture (10s/frame)
feh --reload 10 /tmp/redroid-latest.png &   # Auto-reload viewer

./stop.sh               # Stop container when done
```

### 3. Tải Roblox APK

```bash
mkdir -p ~/redroid-lite/roblox-apks
# Tải file APK từ apkcombo.com / uptodown.com
# Lưu vào ~/redroid-lite/roblox-apks/roblox.apk
```

## Optimizations

### Image-level (strip.sh)

Removed from `/system/`:
- `Launcher3QuickStep` (~170 MB)
- 52 apps/services không cần (Camera, Calendar, DeskClock, ...)
- Bootanimation, wallpapers, extra fonts

### Runtime-level (optimize.sh)

Disabled (verified safe with Roblox):
- ExtServices, SettingsIntelligence
- MediaProvider, DownloadProviderUi
- IntentResolver, ProxyHandler, VpnDialogs
- BackupRestoreConfirmation, FusedLocation
- CompanionDeviceManager
- PermissionController (after pre-grant Roblox permissions)
- Init services: statsd, incidentd

### Critical packages KEPT

- **WebView** — Roblox crashes without (CookieManager)
- **SystemUI** — Roblox needs system insets to render
- **Shell, Telecom** — AOSP framework dependencies

## Known limitations

- **scrcpy NOT working** — MediaCodec encoder issue in this image variant
- Use screencap (`./snap.sh` or `./watch.sh`) instead of real-time stream
- Designed for **login + account check**, not real-time gameplay
- No Google Play Services (no in-app purchases via Google)

## Troubleshooting

### Roblox không launch

```bash
adb -s localhost:5555 logcat -d | grep -E "FATAL|roblox.*Error"
```

Nếu có `MissingWebViewPackageException` → rollback enable WebView:
```bash
adb -s localhost:5555 shell pm enable com.android.webview
```

### Memory cao bất thường

```bash
./optimize.sh   # Apply optimization lại
```

### Container không boot

```bash
docker logs redroid-lite | tail -50
```

Check binderfs:
```bash
ls /dev/binderfs
sudo systemctl status binderfs
```

## Future versions

- **v6** (planned): Remove SystemUI entirely → target ~180 MB idle (risk: Roblox UI broken)
