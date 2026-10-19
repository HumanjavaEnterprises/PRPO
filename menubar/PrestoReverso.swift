// PrestoReverso — tiny native menu-bar indicator for Epson ink levels.
// Pure Cocoa, arm64/universal, no dependencies. Shells out to `epson-ink-check --show`
// (single source of truth) and renders the result as a status-bar menu.
//
// Build:   swiftc -O PrestoReverso.swift -o PrestoReverso -framework Cocoa
// Runs as an accessory (LSUIElement) — no Dock icon.

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var timer: Timer?

    func applicationDidFinishLaunching(_ note: Notification) {
        statusItem.button?.title = "🖨"
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
        refresh()
        // periodic refresh every 2h; menu also refreshes on open
        timer = Timer.scheduledTimer(withTimeInterval: 7200, repeats: true) { [weak self] _ in self?.refresh() }
    }

    private func helperPath() -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let p = home + "/.local/bin/epson-ink-check"
        return FileManager.default.isExecutableFile(atPath: p) ? p : "epson-ink-check"
    }

    private func runHelper() -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-lc", "\(helperPath()) --show"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        do { try task.run() } catch { return "" }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        return String(data: data, encoding: .utf8) ?? ""
    }

    private func firstPercent(_ s: String) -> Int? {
        for tok in s.split(whereSeparator: { $0 == " " || $0 == "\t" }) {
            if tok.hasSuffix("%"), let n = Int(tok.dropLast()) { return n }
        }
        return nil
    }

    @objc func refresh() {
        let out = runHelper()
        let menu = NSMenu()
        menu.delegate = self
        var anyLow = false

        for raw in out.split(separator: "\n") {
            let line = String(raw)
            guard line.contains("%"), firstPercent(line) != nil else { continue }
            let isLow = line.contains("LOW")
            let title = line.replacingOccurrences(of: "  <-- LOW", with: "")
                            .trimmingCharacters(in: .whitespaces)
            let item = NSMenuItem(title: (isLow ? "⚠️ " : "   ") + title, action: nil, keyEquivalent: "")
            menu.addItem(item)
            if isLow { anyLow = true }
        }
        if menu.items.isEmpty {
            menu.addItem(NSMenuItem(title: "Printer unavailable", action: nil, keyEquivalent: ""))
        }

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Refresh now", action: #selector(refresh), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Quit PrestoReverso", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        statusItem.button?.title = anyLow ? "🖨️❗" : "🖨️"
        statusItem.button?.toolTip = anyLow ? "Epson — ink low" : "Epson — ink OK"
    }

    func menuWillOpen(_ menu: NSMenu) { refresh() }

    @objc func quit() { NSApp.terminate(nil) }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
