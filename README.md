# Redroid Lite

Custom Redroid image (~308 MB RAM idle) for running ARM64 Android apps on x86_64 Linux. Based on Android 13.

## Requirements

- Ubuntu 22.04+ (or kernel 5.x+ with `CONFIG_ANDROID_BINDERFS=m`)
- Docker + docker-compose
- adb
- `binder_linux` kernel module

## Features

- Headless Android 13 in Docker
- ARM64 + x86_64 apps support (via NDK translation)
- ~308 MB RAM idle (vs 800 MB stock)
- Auto-mount binderfs via systemd
- Auto-restart container after host reboot

## NOT Compatible

- Roblox / games with Hyperion anti-cheat (detect container)
- Apps requiring Google Play Services
- 3D games (GPU guest mode = software rendering)

## Setup

### 1. Install dependencies

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2 android-sdk-libsparse-utils \
    e2fsprogs adb linux-modules-extra-$(uname -r)
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Install systemd service

```bash
sudo cp systemd/binderfs.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now binderfs.service
mount | grep binder
```

### 3. Build image

```bash
cp scripts/strip.sh build/strip.sh
docker build --no-cache -t redroid-lite:13-v3 build/
rm -f build/strip.sh
```

Build time: ~5 minutes.

### 4. Start

```bash
./start.sh
```

## Usage

```bash
./start.sh                              # Start
./status.sh                             # Check status
./stop.sh                               # Stop

adb connect localhost:5555
adb -s localhost:5555 shell
adb -s localhost:5555 install app.apk
```

## Memory Footprint

| Variant | RAM |
|---|---|
| Stock erstt/redroid:13.0.0_ndk_ChromeOS | ~800 MB |
| **redroid-lite:13-v3** | **~308 MB** |

## File Structure
cd ~/redroid-lite

cat > README.md << 'README_EOF'
# Redroid Lite

Custom Redroid image (~308 MB RAM idle) for running ARM64 Android apps on x86_64 Linux. Based on Android 13.

## Requirements

- Ubuntu 22.04+ (or kernel 5.x+ with `CONFIG_ANDROID_BINDERFS=m`)
- Docker + docker-compose
- adb
- `binder_linux` kernel module

## Features

- Headless Android 13 in Docker
- ARM64 + x86_64 apps support (via NDK translation)
- ~308 MB RAM idle (vs 800 MB stock)
- Auto-mount binderfs via systemd
- Auto-restart container after host reboot

## NOT Compatible

- Roblox / games with Hyperion anti-cheat (detect container)
- Apps requiring Google Play Services
- 3D games (GPU guest mode = software rendering)

## Setup

### 1. Install dependencies

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2 android-sdk-libsparse-utils \
    e2fsprogs adb linux-modules-extra-$(uname -r)
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Install systemd service

```bash
sudo cp systemd/binderfs.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now binderfs.service
mount | grep binder
```

### 3. Build image

```bash
cp scripts/strip.sh build/strip.sh
docker build --no-cache -t redroid-lite:13-v3 build/
rm -f build/strip.sh
```

Build time: ~5 minutes.

### 4. Start

```bash
./start.sh
```

## Usage

```bash
./start.sh                              # Start
./status.sh                             # Check status
./stop.sh                               # Stop

adb connect localhost:5555
adb -s localhost:5555 shell
adb -s localhost:5555 install app.apk
```

## Memory Footprint

| Variant | RAM |
|---|---|
| Stock erstt/redroid:13.0.0_ndk_ChromeOS | ~800 MB |
| **redroid-lite:13-v3** | **~308 MB** |

## File Structure
## Troubleshooting

**Container exits with code 129:**

```bash
mount | grep binder
sudo systemctl restart binderfs.service
```

**Boot loop / system_server crash:**

```bash
adb logcat -b crash | head -20
```

Common cause: stripped too much. Restore missing package in `scripts/strip.sh` and rebuild.

## License

Apache 2.0 (inherits from upstream redroid).

## Credits

- [remote-android/redroid](https://github.com/remote-android/redroid-doc)
- [ERSTT/redroid](https://github.com/ERSTT/redroid)

