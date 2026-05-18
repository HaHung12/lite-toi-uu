# Redroid Lite

Custom Redroid Docker image (~308 MB RAM idle) for running Android 13 apps on **Linux x86_64**. Stripped 54 system components from base image while keeping ADB, PackageInstaller, WebView, MediaProvider functional.

## ⚠️ Linux Only

This project **requires Linux** (Ubuntu/Debian/Fedora/Arch with kernel 5.10+). It cannot run on Windows or macOS directly because it depends on:

- Linux kernel module `binder_linux`
- Linux-specific `/dev/binderfs` filesystem
- Linux cgroups + namespaces for Docker

### Windows / macOS users

Choose ONE of these alternatives:

1. **WSL2 (Windows 10/11):** Install Ubuntu in WSL2, then follow this README inside WSL. ⚠️ Binderfs support varies — may not work.
2. **Linux VM:** Install Ubuntu in VirtualBox/VMware. Slower due to nested virtualization.
3. **Dual boot:** Install Linux alongside Windows. Best performance.
4. **Alternative tools:** Use Android Studio Emulator (built-in to Android Studio) — works natively on Windows/macOS without this project.

## Features

- ✓ Headless Android 13 in Docker
- ✓ ARM64 + x86_64 apps support via NDK translation (Houdini)
- ✓ ~308 MB RAM idle (vs 800 MB stock redroid)
- ✓ Auto-mount binderfs via systemd
- ✓ Auto-restart container after host reboot

## NOT Compatible

- ❌ Roblox, PUBG, Genshin, any game with anti-cheat (detect container fingerprint)
- ❌ Apps requiring Google Play Services
- ❌ 3D games (GPU guest mode = software rendering, very slow)
- ❌ Apps requiring real telephony (TelephonyProvider stripped)

## Requirements

- **OS:** Linux x86_64 (Ubuntu 22.04+ recommended)
- **Kernel:** 5.10+ with `CONFIG_ANDROID_BINDERFS=m`
- **RAM:** ≥ 4GB host (container uses ~320MB)
- **Disk:** ~6GB (for Docker images + build cache)
- **Software:** Docker, docker-compose-v2, adb, git

## Verify Your System

Before installing, check kernel supports binderfs:

```bash
# Check kernel config
grep CONFIG_ANDROID_BINDERFS /boot/config-$(uname -r)
# Expect: CONFIG_ANDROID_BINDERFS=m or =y

# Check module
modinfo binder_linux 2>&1 | head -3
# Expect: filename: ...binder_linux.ko
```

If both fail, install kernel extras:

```bash
sudo apt install -y linux-modules-extra-$(uname -r)
sudo modprobe binder_linux
```

## Setup

### 1. Install dependencies

```bash
sudo apt update
sudo apt install -y \
    docker.io docker-compose-v2 adb git \
    linux-modules-extra-$(uname -r)

sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Clone repo

```bash
git clone https://github.com/HaHung12/lite-toi-uu.git
cd lite-toi-uu
```

### 3. Install systemd service (auto-mount binderfs at boot)

```bash
sudo cp systemd/binderfs.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now binderfs.service

# Verify
mount | grep binder
ls /dev/binderfs/
# Expect: binder  binder-control  hwbinder  vndbinder
```

### 4. Build image (~5-10 min)

```bash
cp scripts/strip.sh build/strip.sh
docker build --no-cache -t redroid-lite:13-v3 build/
rm -f build/strip.sh
```

### 5. Start

```bash
./start.sh
```

After ~60s, you'll see `✓ Redroid ready`. Connect:

```bash
adb connect localhost:5555
adb -s localhost:5555 shell
```

## Daily Usage

```bash
./start.sh                              # Start container
./status.sh                             # Check status
./stop.sh                               # Stop

adb -s localhost:5555 shell             # Shell into Android
adb -s localhost:5555 install app.apk   # Install APK
adb -s localhost:5555 logcat            # View logs
```

After host reboot:
- systemd auto-mounts binderfs
- Docker auto-restarts container (`restart: unless-stopped`)
- No manual action needed

## Memory Footprint

| Variant | RAM idle |
|---|---|
| Stock erstt/redroid:13.0.0_ndk_ChromeOS | ~800 MB |
| **redroid-lite:13-v3 (this repo)** | **~308 MB** |

## What's Stripped (54 folders)

**GUI components:**
- SystemUI, Launcher3QuickStep, Settings, Provision, WallpaperCropper

**User apps:**
- Browser2, Calendar, Camera2, DeskClock, Gallery2, Music, PhotoTable, QuickSearchBox, LatinIME

**Telephony (no SIM in container):**
- TeleService, TelephonyProvider, MmsService, BlockedNumberProvider, BluetoothMidiService

**Providers/services:**
- CalendarProvider, ContactsProvider, DocumentsUI, ManagedProvisioning, UserDictionaryProvider, DynamicSystemInstallationService, StatementService, MusicFX, MtpService, SoundPicker

## Kept Components

- **Shell** (required by AOSP framework for BugreportStorageProvider)
- **Telecom** (core telephony framework)
- **PackageInstaller** (install APKs via ADB)
- **NetworkStack** (network connectivity)
- **MediaProviderLegacy, ExternalStorageProvider** (file access)
- **WebView, FusedLocation, SettingsProvider, DownloadProvider, InputDevices**
- **All apex modules** (PermissionController, MediaProvider, ART, etc.)

## File Structure
## Customize Strip List

Want to keep more apps? Edit `scripts/strip.sh` and rebuild:

```bash
nano scripts/strip.sh

docker compose down
docker rmi redroid-lite:13-v3
cp scripts/strip.sh build/strip.sh
docker build --no-cache -t redroid-lite:13-v3 build/
rm -f build/strip.sh
./start.sh
```

⚠️ **Don't remove `Shell` from priv-app** — AOSP framework references `com.android.shell.BugreportStorageProvider`. Removing it causes system_server boot loop with `IllegalArgumentException`.

## Troubleshooting

### Container exits with code 129

```bash
# Check binderfs
mount | grep binder

# If empty
sudo systemctl restart binderfs.service
sudo modprobe binder_linux
mount | grep binder
```

### Boot loop / system_server crash

```bash
# View crash log
adb -s localhost:5555 logcat -b crash | head -30

# Common cause: stripped too much
# Restore the missing package in scripts/strip.sh and rebuild
```

### ADB not connecting

```bash
adb kill-server
adb start-server
adb connect localhost:5555
adb devices
```

### Permission denied on /dev/binderfs

```bash
# Container needs --privileged
# Already set in docker-compose.yml, but verify:
grep privileged docker-compose.yml
```

## Build Architecture

Multi-stage Docker build using Ubuntu builder + scratch final:
cd ~/redroid-lite

# Verify changes
echo "=== Diff README ==="
git diff README.md | head -50

# Commit + push
git add README.md
git commit -m "docs: clarify Linux-only requirement and add WSL/VM notes for Windows/macOS users"
git push









cd ~/redroid-lite

cat > README.md << 'README_EOF'
# Redroid Lite

Custom Redroid Docker image (~308 MB RAM idle) for running Android 13 apps on **Linux x86_64**. Stripped 54 system components from base image while keeping ADB, PackageInstaller, WebView, MediaProvider functional.

## ⚠️ Linux Only

This project **requires Linux** (Ubuntu/Debian/Fedora/Arch with kernel 5.10+). It cannot run on Windows or macOS directly because it depends on:

- Linux kernel module `binder_linux`
- Linux-specific `/dev/binderfs` filesystem
- Linux cgroups + namespaces for Docker

### Windows / macOS users

Choose ONE of these alternatives:

1. **WSL2 (Windows 10/11):** Install Ubuntu in WSL2, then follow this README inside WSL. ⚠️ Binderfs support varies — may not work.
2. **Linux VM:** Install Ubuntu in VirtualBox/VMware. Slower due to nested virtualization.
3. **Dual boot:** Install Linux alongside Windows. Best performance.
4. **Alternative tools:** Use Android Studio Emulator (built-in to Android Studio) — works natively on Windows/macOS without this project.

## Features

- ✓ Headless Android 13 in Docker
- ✓ ARM64 + x86_64 apps support via NDK translation (Houdini)
- ✓ ~308 MB RAM idle (vs 800 MB stock redroid)
- ✓ Auto-mount binderfs via systemd
- ✓ Auto-restart container after host reboot

## NOT Compatible

- ❌ Roblox, PUBG, Genshin, any game with anti-cheat (detect container fingerprint)
- ❌ Apps requiring Google Play Services
- ❌ 3D games (GPU guest mode = software rendering, very slow)
- ❌ Apps requiring real telephony (TelephonyProvider stripped)

## Requirements

- **OS:** Linux x86_64 (Ubuntu 22.04+ recommended)
- **Kernel:** 5.10+ with `CONFIG_ANDROID_BINDERFS=m`
- **RAM:** ≥ 4GB host (container uses ~320MB)
- **Disk:** ~6GB (for Docker images + build cache)
- **Software:** Docker, docker-compose-v2, adb, git

## Verify Your System

Before installing, check kernel supports binderfs:

```bash
# Check kernel config
grep CONFIG_ANDROID_BINDERFS /boot/config-$(uname -r)
# Expect: CONFIG_ANDROID_BINDERFS=m or =y

# Check module
modinfo binder_linux 2>&1 | head -3
# Expect: filename: ...binder_linux.ko
```

If both fail, install kernel extras:

```bash
sudo apt install -y linux-modules-extra-$(uname -r)
sudo modprobe binder_linux
```

## Setup

### 1. Install dependencies

```bash
sudo apt update
sudo apt install -y \
    docker.io docker-compose-v2 adb git \
    linux-modules-extra-$(uname -r)

sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Clone repo

```bash
git clone https://github.com/HaHung12/lite-toi-uu.git
cd lite-toi-uu
```

### 3. Install systemd service (auto-mount binderfs at boot)

```bash
sudo cp systemd/binderfs.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now binderfs.service

# Verify
mount | grep binder
ls /dev/binderfs/
# Expect: binder  binder-control  hwbinder  vndbinder
```

### 4. Build image (~5-10 min)

```bash
cp scripts/strip.sh build/strip.sh
docker build --no-cache -t redroid-lite:13-v3 build/
rm -f build/strip.sh
```

### 5. Start

```bash
./start.sh
```

After ~60s, you'll see `✓ Redroid ready`. Connect:

```bash
adb connect localhost:5555
adb -s localhost:5555 shell
```

## Daily Usage

```bash
./start.sh                              # Start container
./status.sh                             # Check status
./stop.sh                               # Stop

adb -s localhost:5555 shell             # Shell into Android
adb -s localhost:5555 install app.apk   # Install APK
adb -s localhost:5555 logcat            # View logs
```

After host reboot:
- systemd auto-mounts binderfs
- Docker auto-restarts container (`restart: unless-stopped`)
- No manual action needed

## Memory Footprint

| Variant | RAM idle |
|---|---|
| Stock erstt/redroid:13.0.0_ndk_ChromeOS | ~800 MB |
| **redroid-lite:13-v3 (this repo)** | **~308 MB** |

## What's Stripped (54 folders)

**GUI components:**
- SystemUI, Launcher3QuickStep, Settings, Provision, WallpaperCropper

**User apps:**
- Browser2, Calendar, Camera2, DeskClock, Gallery2, Music, PhotoTable, QuickSearchBox, LatinIME

**Telephony (no SIM in container):**
- TeleService, TelephonyProvider, MmsService, BlockedNumberProvider, BluetoothMidiService

**Providers/services:**
- CalendarProvider, ContactsProvider, DocumentsUI, ManagedProvisioning, UserDictionaryProvider, DynamicSystemInstallationService, StatementService, MusicFX, MtpService, SoundPicker

## Kept Components

- **Shell** (required by AOSP framework for BugreportStorageProvider)
- **Telecom** (core telephony framework)
- **PackageInstaller** (install APKs via ADB)
- **NetworkStack** (network connectivity)
- **MediaProviderLegacy, ExternalStorageProvider** (file access)
- **WebView, FusedLocation, SettingsProvider, DownloadProvider, InputDevices**
- **All apex modules** (PermissionController, MediaProvider, ART, etc.)

## File Structure
## Customize Strip List

Want to keep more apps? Edit `scripts/strip.sh` and rebuild:

```bash
nano scripts/strip.sh

docker compose down
docker rmi redroid-lite:13-v3
cp scripts/strip.sh build/strip.sh
docker build --no-cache -t redroid-lite:13-v3 build/
rm -f build/strip.sh
./start.sh
```

⚠️ **Don't remove `Shell` from priv-app** — AOSP framework references `com.android.shell.BugreportStorageProvider`. Removing it causes system_server boot loop with `IllegalArgumentException`.

## Troubleshooting

### Container exits with code 129

```bash
# Check binderfs
mount | grep binder

# If empty
sudo systemctl restart binderfs.service
sudo modprobe binder_linux
mount | grep binder
```

### Boot loop / system_server crash

```bash
# View crash log
adb -s localhost:5555 logcat -b crash | head -30

# Common cause: stripped too much
# Restore the missing package in scripts/strip.sh and rebuild
```

### ADB not connecting

```bash
adb kill-server
adb start-server
adb connect localhost:5555
adb devices
```

### Permission denied on /dev/binderfs

```bash
# Container needs --privileged
# Already set in docker-compose.yml, but verify:
grep privileged docker-compose.yml
```

## Build Architecture

Multi-stage Docker build using Ubuntu builder + scratch final:
Why scratch? Docker `COPY` doesn't remove files from base layers. Building `FROM scratch` and copying only stripped content is the only way to actually shrink the image.

## License

Apache 2.0 (inherits from upstream [remote-android/redroid](https://github.com/remote-android/redroid-doc)).

## Credits

- [remote-android/redroid](https://github.com/remote-android/redroid-doc) — Base Redroid project
- [ERSTT/redroid](https://github.com/ERSTT/redroid) — ndk_ChromeOS variant with Houdini ARM translation
