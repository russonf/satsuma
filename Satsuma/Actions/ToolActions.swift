import AppKit

enum ToolActions {
    private static var urls: [URL] { OverlayState.shared.currentURLs }

    static func airdrop() {
        guard !urls.isEmpty else { return }
        DispatchQueue.main.async {
            NSSharingService(named: .sendViaAirDrop)?.perform(withItems: urls)
            Toast.shared.show("AirDrop opened")
        }
    }

    static func float() {
        guard !urls.isEmpty else { return }
        DispatchQueue.main.async {
            urls.forEach { FloatController.shared.add($0) }
            Toast.shared.show("\(urls.count) in Float")
        }
    }

    static func copyFile() {
        guard !urls.isEmpty else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects(urls.map { $0 as NSURL })
        Toast.shared.show("\(urls.count) → clipboard")
    }

    static func move() {
        guard !urls.isEmpty else { return }
        DispatchQueue.main.async {
            let favourites = Favourites.destinations
            if favourites.isEmpty {
                moveWithPicker(); return
            }
            let menu = NSMenu()
            for (idx, fav) in favourites.enumerated() {
                let title = "Move to \(fav.lastPathComponent)"
                let item = NSMenuItem(title: title, action: #selector(MoveTargetProxy.pick(_:)), keyEquivalent: "")
                item.target = MoveTargetProxy.shared
                item.representedObject = fav
                item.keyEquivalent = "\(idx + 1)"
                menu.addItem(item)
            }
            menu.addItem(NSMenuItem.separator())
            let choose = NSMenuItem(title: "Choose folder…", action: #selector(MoveTargetProxy.pickOther), keyEquivalent: "")
            choose.target = MoveTargetProxy.shared
            menu.addItem(choose)
            if let screen = NSScreen.main {
                let pt = NSEvent.mouseLocation
                menu.popUp(positioning: nil, at: NSPoint(x: pt.x, y: pt.y), in: nil)
                _ = screen
            }
        }
    }

    fileprivate static func moveWithPicker() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.prompt = "Move Here"
        if panel.runModal() == .OK, let dest = panel.url {
            performMove(to: dest, remember: true)
        }
    }

    fileprivate static func performMove(to dest: URL, remember: Bool) {
        var ok = 0
        for u in urls {
            let target = dest.appendingPathComponent(u.lastPathComponent)
            do { try FileManager.default.moveItem(at: u, to: target); ok += 1 } catch { NSLog("move: \(error)") }
        }
        if remember { Favourites.add(dest) }
        Toast.shared.show("\(ok)/\(urls.count) moved to \(dest.lastPathComponent)")
    }

    static func copyPath() {
        guard !urls.isEmpty else { return }
        let paths = urls.map(\.path).joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(paths, forType: .string)
        Toast.shared.show("Path\(urls.count > 1 ? "s" : "") copied")
    }

    @objc final class MoveTargetProxy: NSObject {
        static let shared = MoveTargetProxy()
        @objc func pick(_ sender: NSMenuItem) {
            guard let dest = sender.representedObject as? URL else { return }
            ToolActions.performMove(to: dest, remember: false)
        }
        @objc func pickOther() {
            ToolActions.moveWithPicker()
        }
    }

    static func openInTerminal() {
        guard let u = urls.first else { return }
        let dir = u.deletingLastPathComponent()
        let app = UserDefaults.standard.string(forKey: "terminal.app") ?? "Terminal"
        let path: String
        switch app {
        case "iTerm":   path = "/Applications/iTerm.app"
        case "Ghostty": path = "/Applications/Ghostty.app"
        default:        path = "/System/Applications/Utilities/Terminal.app"
        }
        let appURL = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: appURL.path) {
            NSWorkspace.shared.open([dir], withApplicationAt: appURL, configuration: NSWorkspace.OpenConfiguration())
        } else {
            NSWorkspace.shared.open(dir)
        }
    }
}
