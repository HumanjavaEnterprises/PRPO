#!/bin/sh
# remove-epson-software.sh — remove the Epson application suite and go fully native.
#
# Run with sudo:   sudo sh scripts/remove-epson-software.sh
#
# What this removes:
#   - /Applications/Epson Software (Low Ink Reminder, Scan 2, ScanSmart, Software
#     Updater, Event Manager, Photo+, Connect/Remote utilities, EpsonNet, ...)
#   - the Epson Image Capture scanner plug-in
#   - Epson launch agents / daemons, caches, app-support, and package receipts
#   - per-user Epson preferences/caches for the invoking user
#
# What this KEEPS (so nothing breaks):
#   - your CUPS print queue (keeps printing via AirPrint/IPP)
#   - native driverless scanning via eSCL/AirScan (Image Capture, Preview, prpo scan)
#
# It is safe to re-run; missing items are skipped.

if [ "$(id -u)" != "0" ]; then echo "Please run with sudo."; exit 1; fi
USERHOME=$(eval echo "~${SUDO_USER:-$USER}")

say() { printf '  %s\n' "$1"; }

echo "==> stopping Epson background agents"
launchctl list 2>/dev/null | awk '/epson/{print $3}' | while read -r l; do
  [ -n "$l" ] && launchctl bootout "system/$l" 2>/dev/null || true
done

echo "==> removing application suite & system components"
for p in \
  "/Applications/Epson Software" \
  "/Library/Image Capture/Devices/EPSON ES0220.app" \
  "/Library/Application Support/Epson" \
  "/Library/Application Support/epson" \
  "/Library/Caches/com.epson."* \
  "/Library/Printers/EPSON/InkjetPrinter2/Utilities" \
  /Library/LaunchAgents/*epson* \
  /Library/LaunchAgents/*Epson* \
  /Library/LaunchDaemons/*epson* \
  /Library/LaunchDaemons/*Epson* ; do
  if [ -e "$p" ]; then rm -rf "$p" && say "removed $p"; fi
done

echo "==> forgetting package receipts"
pkgutil --pkgs 2>/dev/null | grep -iE 'epson' | while read -r r; do
  pkgutil --forget "$r" >/dev/null 2>&1 && say "forgot $r"
done

echo "==> removing per-user Epson files for ${SUDO_USER:-$USER}"
for p in \
  "$USERHOME/Library/Preferences/com.epson."* \
  "$USERHOME/Library/Caches/com.epson."* \
  "$USERHOME/Library/Application Support/Epson"* \
  "$USERHOME/Library/Application Support/epson"* ; do
  if [ -e "$p" ]; then rm -rf "$p" && say "removed $p"; fi
done

echo "==> done. Printing stays via AirPrint; scan with Image Capture / 'prpo scan'."
