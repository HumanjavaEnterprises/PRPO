#!/bin/sh
# install.sh — install PRPO CLI tools, build the menu-bar app, enable the low-ink checker.
set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$HOME/.local/bin"
AGENTS="$HOME/Library/LaunchAgents"
APPDIR="$HOME/Applications"
mkdir -p "$BIN" "$AGENTS" "$APPDIR" "$HOME/Library/Logs"

echo "==> installing CLI tools to $BIN"
for f in epson-ink-check PRPO PRPO-scan; do
  cp "$REPO/bin/$f" "$BIN/$f"; chmod +x "$BIN/$f"
done

echo "==> building the menu-bar app (swiftc)"
tmp="$(mktemp -d)"
swiftc -O "$REPO/menubar/PrestoReverso.swift" -o "$tmp/PrestoReverso" -framework Cocoa
APP="$APPDIR/PrestoReverso.app"
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS"
cp "$tmp/PrestoReverso" "$APP/Contents/MacOS/PrestoReverso"
cp "$REPO/menubar/Info.plist" "$APP/Contents/Info.plist"
rm -rf "$tmp"
codesign --force -s - "$APP" >/dev/null 2>&1 || true

echo "==> installing launch agents"
for a in com.humanjava.PRPO.inkcheck com.humanjava.PRPO.menubar; do
  sed "s#__HOME__#$HOME#g" "$REPO/launchd/$a.plist" > "$AGENTS/$a.plist"
done

echo "==> enabling the low-ink checker (at login + every 6h)"
launchctl bootout "gui/$(id -u)/com.humanjava.PRPO.inkcheck" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$AGENTS/com.humanjava.PRPO.inkcheck.plist"

case ":$PATH:" in *":$BIN:"*) PATHOK=1 ;; *) PATHOK=0 ;; esac

cat <<EOF

Installed.
$( [ "$PATHOK" = 0 ] && echo "NOTE: add $BIN to your PATH (e.g. in ~/.zshrc)." )

  PRPO status          show ink levels now
  PRPO menubar on      turn the menu-bar indicator ON  (off by default)
  PRPO menubar off     turn it OFF
  PRPO scan out.pdf    driverless flatbed scan to PDF
  (lowercase 'prpo' also works on macOS's case-insensitive filesystem)

The menu-bar indicator can also be toggled in
System Settings > General > Login Items (background item "PrestoReverso").
EOF
