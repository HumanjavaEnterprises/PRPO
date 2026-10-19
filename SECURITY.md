# Security Policy

## Design stance

PRPO is deliberately small and local:

- **No network egress beyond your LAN.** It only talks to your printer over IPP
  (`ipps://…:631`) and eSCL (`https://<printer>/eSCL/…`). It contacts no other
  hosts and phones nothing home.
- **No telemetry, analytics, or accounts.** Nothing is collected or transmitted.
- **No credentials handled.** Ink queries and scans are unauthenticated LAN calls.
- **Native, auditable code.** Shell + a single Swift file; no bundled binaries,
  no third-party dependencies, no package manager.

### TLS note

Printer eSCL/IPPS endpoints use the device's **self-signed** certificate, so
`curl -k` is used for those LAN calls. This is standard for AirScan/AirPrint and
is scoped to the local printer only. If your threat model includes a hostile
device on your LAN impersonating the printer, pin the printer's certificate.

### The `sudo` script

`scripts/remove-epson-software.sh` requires `sudo` because it deletes
vendor software under `/Applications` and `/Library`. It:

- removes **only** paths matching Epson's own bundles, agents, caches, and receipts;
- never touches unrelated system files;
- prints each path as it removes it, and is safe to re-run.

Read it before running it. It is the only component that needs elevated rights.

## Supported versions

Latest `main` is supported. This is a small single-maintainer project; fixes land
on `main`.

## Reporting a vulnerability

Please report privately rather than opening a public issue:

- Use **GitHub Security Advisories** ("Report a vulnerability" on the repo's
  Security tab), or
- email **vergel@humanjava.com** with details and reproduction steps.

You'll get an acknowledgement within a few days. Please allow reasonable time for
a fix before any public disclosure.
