import AppKit
import SwiftUI

final class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    func show() {
        if window == nil {
            let host = NSHostingController(rootView: SettingsRoot())
            let w = NSWindow(contentViewController: host)
            w.title = "Satsuma Settings"
            w.setContentSize(NSSize(width: 720, height: 600))
            w.minSize = NSSize(width: 600, height: 500)
            w.styleMask = [.titled, .closable, .resizable, .fullSizeContentView]
            w.titlebarAppearsTransparent = true
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
