#!/bin/sh
# uninstall.sh — remove PRPO (does NOT touch your printer or Epson software).
BIN="$HOME/.local/bin"; AGENTS="$HOME/Library/LaunchAgents"
for a in com.humanjava.prpo.inkcheck com.humanjava.prpo.menubar; do
  launchctl bootout "gui/$(id -u)/$a" 2>/dev/null || true
  rm -f "$AGENTS/$a.plist"
done
rm -f "$BIN/epson-ink-check" "$BIN/prpo" "$BIN/prpo-scan"
rm -rf "$HOME/Applications/PrestoReverso.app"
rm -f "$HOME/Library/Logs/prpo-inkcheck.log"
echo "PRPO removed."
