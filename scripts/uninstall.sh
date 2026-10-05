#!/bin/bash
# OD2 Screen Dangle | 1-Click macOS Uninstaller
# https://od2.in/screen-dangle
set -e

echo "============================================================"
echo "  OD2 Screen Dangle | macOS Companion Uninstaller"
echo "  Website: https://od2.in/screen-dangle"
echo "============================================================"
echo ""
echo "Terminating running OD2 Screen Dangle processes..."
pkill -f "OD2 Screen Dangle" 2>/dev/null || true
pkill -f "OD2-Screen-Dangle" 2>/dev/null || true

echo "Removing application bundle from /Applications..."
rm -rf "/Applications/OD2 Screen Dangle.app" 2>/dev/null || true
rm -rf "/Applications/OD2 Screen Charm.app" 2>/dev/null || true

echo "Removing auto-start login items..."
rm -f "$HOME/Library/LaunchAgents/in.od2.app.screendangle.plist" 2>/dev/null || true
osascript -e 'tell application "System Events" to delete (every login item whose name is "OD2 Screen Dangle")' 2>/dev/null || true

echo "Cleaning application caches..."
rm -rf "$HOME/Library/Application Support/OD2ScreenDangle" 2>/dev/null || true
rm -rf "$HOME/Library/Caches/in.od2.screendangle" 2>/dev/null || true
killall Dock 2>/dev/null || true

echo ""
echo "============================================================"
echo "  [SUCCESS] OD2 Screen Dangle has been completely removed."
echo "============================================================"
echo "All companion files, login items, and caches have been cleaned."
echo ""
