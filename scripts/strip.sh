#!/bin/bash
set -e

SYSTEM="${1:-/build/system}"
[ ! -d "$SYSTEM" ] && { echo "Error: $SYSTEM not found"; exit 1; }
cd "$SYSTEM"

echo "[+] Before strip: $(du -sh . | cut -f1)"

# Media & fonts (giảm size, không ảnh hưởng boot)
echo "[+] Removing media..."
rm -rf media/audio/* media/bootanimation.zip media/shutdownanimation.zip 2>/dev/null || true
rm -rf wallpaper/* product/wallpaper/* product/media/audio/* 2>/dev/null || true

if [ -d fonts ]; then
    cd fonts
    ls | grep -vE "^(Roboto-Regular|Roboto-Bold|DroidSans-Bold|NotoSansCJK-Regular)\.(ttf|ttc|otf)$" \
       | xargs -I {} rm -f {} 2>/dev/null || true
    cd ..
fi

# /system/app — XÓA CHÍNH XÁC 38 packages của bạn (folder tương ứng)
echo "[+] Stripping /system/app..."
cd app 2>/dev/null && {
    rm -rf \
        BasicDreams \
        BluetoothMidiService \
        BookmarkProvider \
        CaptivePortalLogin \
        KeyChain \
        PrintSpooler \
        SecureElement \
        Traceur \
        SimAppDialog \
        CertInstaller \
        EasterEgg \
        HTMLViewer \
        NfcNci \
        PacProcessor \
        PrintRecommendationService \
        WallpaperBackup \
        CameraExtensionsProxy \
        CtsShimPrebuilt \
        2>/dev/null || true
    cd ..
}

# /system/priv-app — XÓA telephony + một số provider trong list disable
echo "[+] Stripping /system/priv-app..."
cd priv-app 2>/dev/null && {
    rm -rf \
        TeleService \
        TelephonyProvider \
        MmsService \
        CalendarProvider \
        ContactsProvider \
        DocumentsUI \
        ManagedProvisioning \
        LiveWallpapersPicker \
        LocalTransport \
        UserDictionaryProvider \
        DynamicSystemInstallationService \
        StatementService \
        BlockedNumberProvider \
        BuiltInPrintService \
        MusicFX \
        MtpService \
        SoundPicker \
        SharedStorageBackup \
        CtsShimPrivPrebuilt \
        2>/dev/null || true
    cd ..
}

# /system/system_ext/priv-app — XÓA SystemUI, Launcher, Settings
echo "[+] Stripping /system/system_ext/priv-app..."
cd system_ext/priv-app 2>/dev/null && {
    rm -rf \
        SystemUI \
        Launcher3QuickStep \
        Settings \
        WallpaperCropper \
        Provision \
        2>/dev/null || true
    cd ../..
}

# /system/system_ext/app
echo "[+] Stripping /system/system_ext/app..."
rm -rf system_ext/app/WAPPushManager 2>/dev/null || true

# /system/product/app — XÓA các app GUI
echo "[+] Stripping /system/product/app..."
cd product/app 2>/dev/null && {
    rm -rf \
        Browser2 \
        Calendar \
        Camera2 \
        DeskClock \
        Gallery2 \
        LatinIME \
        Music \
        PhotoTable \
        QuickSearchBox \
        2>/dev/null || true
    cd ../..
}

# /system/product/priv-app — XÓA Contacts, OneTimeInitializer (giữ SettingsIntelligence vì init có thể cần)
echo "[+] Stripping /system/product/priv-app..."
cd product/priv-app 2>/dev/null && {
    rm -rf \
        Contacts \
        OneTimeInitializer \
        2>/dev/null || true
    cd ../..
}

echo "[+] After strip: $(du -sh . | cut -f1)"
echo ""
echo "[+] Remaining in /system/app:"
ls app 2>/dev/null | sed 's/^/    /'
echo "[+] Remaining in /system/priv-app:"
ls priv-app 2>/dev/null | sed 's/^/    /'
echo "[+] Remaining in /system/system_ext/priv-app:"
ls system_ext/priv-app 2>/dev/null | sed 's/^/    /'
echo "[+] Remaining in /system/product/app:"
ls product/app 2>/dev/null | sed 's/^/    /'
echo "[+] Remaining in /system/product/priv-app:"
ls product/priv-app 2>/dev/null | sed 's/^/    /'
echo "[+] Done"
