import Foundation
import AppKit

enum FileActions {
    private static var url: URL? { OverlayState.shared.currentFileURL }

    static func compress() {
        guard let u = url else { return }
        DispatchQueue.global().async {
            let dest = u.deletingPathExtension().appendingPathExtension("zip")
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
            proc.arguments = ["-c", "-k", "--sequesterRsrc", "--keepParent", u.path, dest.path]
            try? proc.run()
            proc.waitUntilExit()
            NSLog("Satsuma: compressed -> \(dest.path)")
        }
    }

    static func metadata() {
        guard let u = url else { return }
        DispatchQueue.main.async { MetadataWindow.show(for: u) }
    }

    static func edit()     { openInPreview() }
    static func annotate() { openInPreview() }
    static func addBackground() { openInPreview() }
    static func crop()     { openInPreview() }
    static func redact()   { openInPreview() }

    private static func openInPreview() {
        guard let u = url else { return }
        let preview = URL(fileURLWithPath: "/System/Applications/Preview.app")
        NSWorkspace.shared.open([u], withApplicationAt: preview, configuration: NSWorkspace.OpenConfiguration())
    }
}
