# Native scanning on modern macOS (no Epson software)

Modern Epson all-in-ones (e.g. the WorkForce WF-3820) speak **eSCL / AirScan**,
Apple's driverless scanning protocol. macOS has a built-in client, so you can
scan with zero vendor software — and it's fully Apple-silicon native.

## Scan with built-in apps

- **Image Capture** (`/System/Applications/Image Capture.app`) — pick the
  scanner in the sidebar, choose flatbed or document feeder, scan.
- **Preview** → File ▸ Import from Scanner.
- **System Settings ▸ Printers & Scanners** → your printer → **Scan**.

If the scanner doesn't appear, add it in Printers & Scanners; macOS selects the
**AirPrint / "Secure AirPrint"** driver automatically — that's the driverless path.

## Scan from the command line

```
PRPO scan                      # flatbed -> ~/Desktop/scan-<timestamp>.pdf
PRPO scan ~/Documents/x.pdf    # choose the output path
PRPO_SCAN_DPI=600 PRPO scan    # change resolution
PRPO_SCAN_COLOR=Grayscale8 PRPO scan
```

`PRPO scan` talks straight to the printer's eSCL endpoint
(`https://<printer>/eSCL/ScanJobs`) — the same protocol the system apps use.

## What the device advertises (WF-3820, example)

- Flatbed (platen): up to **1200 dpi**, Color / Grayscale / B&W, PDF or JPEG
- ADF (document feeder): **60 sheets**, up to **600 dpi**, auto paper detection
- Intents: Document, TextAndGraphic, Photo, Preview

Confirm any device yourself:

```
curl -sk https://<printer>.local/eSCL/ScannerCapabilities
```

A `200` with `<pwg:MakeAndModel>` means driverless scanning is supported.
