# presto-reverso-print-o (PRPO)

**Run your Epson printer/scanner natively on Apple-silicon macOS — and bin the Intel-era bloatware.**

macOS now warns that bundled vendor apps built for Intel "will not work with a
future release of macOS." For Epson all-in-ones, the worst offender is the
**Epson Low Ink Reminder** — a tiny background app that, on inspection, is still
`x86_64 / i386 / ppc7400` with **no arm64 slice at all**. It only runs under
Rosetta, purely to tell you an ink is low.

But the printer already hands that data out over standard **IPP**, and modern
Epsons scan over Apple's driverless **eSCL / AirScan**. So you don't need any of
it. PRPO replaces the one app worth keeping (the low-ink reminder) with a few
kilobytes of native shell + a tiny Swift menu-bar app, and documents how to drop
the rest.

> Named for pulling the magic *back out* of the vendor stack: **presto-reverso-print-o**.

## What's in the box

| Piece | What it does |
|---|---|
| `epson-ink-check` | Reads ink levels over IPP; notifies when any cartridge is low. Pure `ipptool` + `osascript`. |
| `PRPO` | Small control CLI — `status`, `check`, `menubar on/off`, `scan`. |
| `PRPO-scan` | Driverless flatbed → PDF via eSCL. No Epson software. |
| **PrestoReverso.app** | Optional native menu-bar indicator (Swift/Cocoa, `LSUIElement`). Toggle any time. |
| `scripts/remove-epson-software.sh` | Removes the Epson app suite to go fully native (keeps printing + scanning working). |

Everything is arm64-native and dependency-free (system `ipptool`, `curl`,
`osascript`, `swiftc`). No Homebrew, no Electron, no telemetry.

## Install

```sh
git clone https://github.com/HumanjavaEnterprises/PRPO.git
cd PRPO
sh scripts/install.sh
```

This installs the CLI to `~/.local/bin`, builds the menu-bar app into
`~/Applications`, and enables the low-ink checker (at login + every 6h).
Make sure `~/.local/bin` is on your `PATH`.

## Use

```sh
PRPO status          # ink readout right now
PRPO menubar on      # show the menu-bar indicator (off by default)
PRPO menubar off     # hide it
PRPO scan out.pdf    # driverless flatbed scan
```

Example readout:

```
Epson ink levels  (ipps://EPSONxxxx.local:631/ipp/print)
Black         83%  (low at 15%)
Cyan          19%  (low at 15%)
Magenta        7%  (low at 15%)  <-- LOW
Yellow        17%  (low at 15%)
LOW: Magenta 7%
```

The menu-bar indicator shows 🖨️ (or 🖨️❗ when something's low) and lists each
cartridge. It's a background LaunchAgent, so you can also turn it on/off in
**System Settings ▸ General ▸ Login Items**.

## Go fully native (optional)

Native macOS already prints (AirPrint) and scans (eSCL/AirScan) this device, so
the whole Epson suite can go:

```sh
sudo sh scripts/remove-epson-software.sh
```

This removes the Epson apps, scanner plug-in, agents, caches, and receipts, while
**keeping your print queue and scanning intact**. See
[`docs/native-scanning.md`](docs/native-scanning.md).

## Other Epson models

The printer is auto-detected from your configured CUPS queues. To point at a
specific device:

```sh
export EPSON_IPP_URI="ipps://YOUR-PRINTER.local:631/ipp/print"
```

Any Epson that reports `marker-levels` over IPP works for ink monitoring; any
that answers `/eSCL/ScannerCapabilities` works for `PRPO scan`.

## License

MIT © Vergel Evans. See [LICENSE](LICENSE). Security policy: [SECURITY.md](SECURITY.md).
