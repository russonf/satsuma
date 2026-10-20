import AppKit

enum ToolActions {
    private static var url: URL? { OverlayState.shared.currentFileURL }

    static func airdrop() {
        guard let u = url else { return }
        DispatchQueue.main.async {
            let service = NSSharingService(named: .sendViaAirDrop)
            service?.perform(withItems: [u])
        }
    }

    static func float() {
        guard let u = url else { return }
        DispatchQueue.main.async { FloatController.shared.add(u) }
    }

    static func copy() {
        guard let u = url else { return }
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.prompt = "Copy Here"
            panel.message = "Choose destination for \(u.lastPathComponent)"
            if panel.runModal() == .OK, let dest = panel.url {
                let target = dest.appendingPathComponent(u.lastPathComponent)
                try? FileManager.default.copyItem(at: u, to: target)
            }
        }
    }

    static func move() {
        guard let u = url else { return }
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.prompt = "Move Here"
            panel.message = "Choose destination for \(u.lastPathComponent)"
            if panel.runModal() == .OK, let dest = panel.url {
                let target = dest.appendingPathComponent(u.lastPathComponent)
                try? FileManager.default.moveItem(at: u, to: target)
            }
        }
    }

    static func copyPath() {
        guard let u = url else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(u.path, forType: .string)
    }

    static func copyFile() {
        guard let u = url else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([u as NSURL])
    }

    static func openInTerminal() {
        guard let u = url else { return }
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
