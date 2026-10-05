#!/bin/bash
# OD2 Screen Dangle | 1-Click macOS Command Line Installer
# https://od2.in/screen-dangle
set -e

echo "============================================================"
echo "  OD2 Screen Dangle | macOS Companion Installer"
echo "  Interactive Lucky Talisman for your Screen (Mac & Windows)"
echo "  Website: https://od2.in/screen-dangle"
echo "============================================================"
echo ""
echo "INSTALLATION STEPS:"
echo "  [1/3] Download latest lightweight companion bundle (v1.0.0)"
echo "  [2/3] Extract and install to /Applications/OD2 Screen Dangle.app"
echo "  [3/3] Launch hardware-accelerated screen dangle overlay"
echo ""
echo "HOW TO USE YOUR SCREEN DANGLE:"
echo "  * Drag & Swing : Click and drag the hanging talisman to swing it"
echo "  * Click-Through: Clicks pass directly to apps underneath"
echo "  * Live Sync    : Visit https://od2.in/screen-dangle and click"
echo "                   'Apply to Desktop App' to instantly sync new charms"
echo "  * Exit App     : Click Quit in the menu bar or press Cmd+Q"
echo "============================================================"
echo ""
echo "Downloading latest OD2 Screen Dangle for macOS..."

# Terminate any previously running instances
pkill -9 -f "OD2 Screen Dangle" 2>/dev/null || true
pkill -9 -f "OD2-Screen-Dangle" 2>/dev/null || true
pkill -9 -f "launcher" 2>/dev/null || true
killall -9 "OD2-Screen-Dangle" 2>/dev/null || true
killall -9 "launcher" 2>/dev/null || true
sleep 1

TMP_DIR=$(mktemp -d)
ZIP_PATH="$TMP_DIR/OD2-Screen-Dangle-macOS.zip"

DOWNLOAD_SUCCESS=false

# Auto-detect candidates:
# 1. Explicit parameter passed to bash ($1)
# 2. OD2_BASE_URL environment variable
# 3. Process table detection if curl command is present
# 4. Local LAN development servers (192.168.1.11:3000, localhost:3000)
# 5. Production CDN (https://od2.in)
CANDIDATES=()
if [ -n "$1" ]; then
    CANDIDATES+=("${1%/}")
fi
if [ -n "$OD2_BASE_URL" ]; then
    CANDIDATES+=("${OD2_BASE_URL%/}")
fi

DETECTED_SRC=$(ps -eo args 2>/dev/null | grep -E "https?://[^/]+/screen-dangle/install.sh" | grep -v grep | sed -E 's/.*(https?:\/\/[^\/]+)\/screen-dangle\/install.sh.*/\1/' | head -n 1)
if [ -n "$DETECTED_SRC" ]; then
    CANDIDATES+=("${DETECTED_SRC%/}")
fi

CANDIDATES+=(
    "http://192.168.1.7:3000"
    "http://192.168.1.11:3000"
    "http://localhost:3000"
    "https://od2.in"
)

for CANDIDATE in "${CANDIDATES[@]}"; do
    [ -z "$CANDIDATE" ] && continue
    echo "Checking $CANDIDATE..."
    if curl -fsSL --connect-timeout 2 -A "OD2-ScreenDangle-Installer/1.0" "$CANDIDATE/screen-dangle/v1.0.0/OD2-Screen-Dangle-macOS-v1.0.0.zip" -o "$ZIP_PATH" 2>/dev/null; then
        echo "Successfully downloaded package from $CANDIDATE"
        DOWNLOAD_SUCCESS=true
        break
    elif curl -fsSL --connect-timeout 2 -A "OD2-ScreenDangle-Installer/1.0" "$CANDIDATE/api/screen-dangle/download?platform=mac-zip" -o "$ZIP_PATH" 2>/dev/null; then
        echo "Successfully downloaded package from $CANDIDATE API"
        DOWNLOAD_SUCCESS=true
        break
    fi
done

if [ "$DOWNLOAD_SUCCESS" != "true" ]; then
    echo "Could not download macOS companion package. Please visit https://od2.in/screen-dangle"
    exit 1
fi

echo "Extracting application..."
EXTRACT_DIR="$TMP_DIR/extracted"
mkdir -p "$EXTRACT_DIR"

# Use native macOS ditto if available, or fallback to unzip
if command -v ditto >/dev/null 2>&1; then
    ditto -xk "$ZIP_PATH" "$EXTRACT_DIR"
else
    unzip -q -o "$ZIP_PATH" -d "$EXTRACT_DIR" 2>/dev/null || unzip -o "$ZIP_PATH" -d "$EXTRACT_DIR" || true
fi

# Locate the .app bundle
APP_SRC=""
if [ -d "$EXTRACT_DIR/OD2 Screen Dangle.app" ]; then
    APP_SRC="$EXTRACT_DIR/OD2 Screen Dangle.app"
elif [ -d "$TMP_DIR/OD2 Screen Dangle.app" ]; then
    APP_SRC="$TMP_DIR/OD2 Screen Dangle.app"
else
    APP_SRC=$(find "$TMP_DIR" -name "*Screen*Dangle*.app" -maxdepth 3 2>/dev/null | head -n 1)
fi

if [ -n "$APP_SRC" ] && [ -d "$APP_SRC" ]; then
    echo "Installing to /Applications..."
    rm -rf "/Applications/OD2 Screen Dangle.app" 2>/dev/null || true
    rm -rf "/Applications/OD2 Screen Charm.app" 2>/dev/null || true
    cp -R "$APP_SRC" /Applications/

    # Ensure launcher has executable permissions
    if [ -f "/Applications/OD2 Screen Dangle.app/Contents/MacOS/launcher" ]; then
        chmod +x "/Applications/OD2 Screen Dangle.app/Contents/MacOS/launcher" 2>/dev/null || true
    fi

    # Pre-compile native Swift binary if swiftc is available on this Mac
    if command -v swiftc >/dev/null 2>&1; then
        echo "Compiling native macOS overlay companion (Swift + Cocoa)..."
        SRC="/Applications/OD2 Screen Dangle.app/Contents/Resources/OverlayApp.swift"
        BIN="/Applications/OD2 Screen Dangle.app/Contents/MacOS/OD2-Screen-Dangle"
        if [ -f "$SRC" ]; then
            swiftc "$SRC" -o "$BIN" -framework Cocoa 2>&1 || {
                echo "  [INFO] Swift compile finished. Launcher fallback enabled."
            }
            chmod +x "$BIN" 2>/dev/null || true
        fi
    fi

    # Clear macOS quarantine attributes
    xattr -cr "/Applications/OD2 Screen Dangle.app" 2>/dev/null || xattr -dr com.apple.quarantine "/Applications/OD2 Screen Dangle.app" 2>/dev/null || true

    # Force macOS LaunchServices to register LSUIElement background agent status
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u "/Applications/OD2 Screen Dangle.app" 2>/dev/null || true
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R "/Applications/OD2 Screen Dangle.app" 2>/dev/null || true
    killall Dock 2>/dev/null || true

    # Configure auto-start at Mac login / restart (LaunchAgent)
    LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
    mkdir -p "$LAUNCH_AGENT_DIR"
    cat << 'EOF' > "$LAUNCH_AGENT_DIR/in.od2.app.screendangle.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>in.od2.app.screendangle</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/open</string>
        <string>/Applications/OD2 Screen Dangle.app</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF
    # Activate LaunchAgent immediately so it runs across reboots
    launchctl unload "$LAUNCH_AGENT_DIR/in.od2.app.screendangle.plist" 2>/dev/null || true
    launchctl load -w "$LAUNCH_AGENT_DIR/in.od2.app.screendangle.plist" 2>/dev/null || true
    echo "  [SUCCESS] OD2 Screen Dangle v1.0.0 installed to /Applications!"
    echo "============================================================"
    echo "  Location : /Applications/OD2 Screen Dangle.app"
    echo ""
    echo "QUICK START & CONTROLS:"
    echo "  * Drag Dangle  : Left-click and drag with your mouse"
    echo "  * Cmd + D      : Toggle show / hide screen overlay"
    echo "  * Cmd + S      : Bless charm with gentle air sway"
    echo "  * Auto-Start   : Toggle 'Launch at Mac Login' from menu bar"
    echo "  * Web Studio   : Open https://od2.in/screen-dangle to customize"
    echo "  * Exit App     : Quit from macOS menu bar or press Cmd+Q"
    echo "============================================================"
    open "/Applications/OD2 Screen Dangle.app" 2>/dev/null || true

    # Silent background install telemetry ping
    ARCH_NAME=$(uname -m 2>/dev/null || echo "arm64")
    OS_VER=$(sw_vers -productVersion 2>/dev/null || echo "")
    curl -s --connect-timeout 2 -X POST "https://od2.in/api/screen-dangle/telemetry" \
        -H "Content-Type: application/json" \
        -d "{\"platform\":\"macos\",\"action\":\"install\",\"arch\":\"$ARCH_NAME\",\"osVersion\":\"macOS $OS_VER\",\"appType\":\"native-macos\",\"presetId\":\"nazar\"}" >/dev/null 2>&1 &
else
    echo "Failed to extract application bundle."
    rm -rf "$TMP_DIR" 2>/dev/null || true
    exit 1
fi

rm -rf "$TMP_DIR" 2>/dev/null || true
