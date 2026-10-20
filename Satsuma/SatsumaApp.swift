import SwiftUI
import AppKit

@main
struct SatsumaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // No visible scene; menu-bar app opens its settings via SettingsWindowController.
        Settings { EmptyView() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlay: OverlayController?
    private var statusItem: NSStatusItem?
    private var pauseItem: NSMenuItem?
    private lazy var iconActive: NSImage? = {
        let cfg = NSImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let img = NSImage(systemSymbolName: "circle.hexagongrid.fill", accessibilityDescription: "Satsuma")?.withSymbolConfiguration(cfg)
        img?.isTemplate = true
        return img
    }()
    private lazy var iconPaused: NSImage? = {
        let cfg = NSImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let img = NSImage(systemSymbolName: "pause.circle", accessibilityDescription: "Satsuma (paused)")?.withSymbolConfiguration(cfg)
        img?.isTemplate = true
        return img
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        overlay = OverlayController()
        overlay?.start()
        installStatusItem()
        Onboarding.showIfNeeded()
    }

    private func installStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            refreshStatusIcon(button: button)
        }
        let menu = NSMenu()

        let pause = NSMenuItem(title: "Pause Satsuma", action: #selector(togglePause), keyEquivalent: "p")
        pause.target = self
        menu.addItem(pause)
        pauseItem = pause

        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Settings…", action: #selector(openSettings), keyEquivalent: ",").target = self
        menu.addItem(withTitle: "Welcome…", action: #selector(showOnboarding), keyEquivalent: "").target = self
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit Satsuma", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = menu
        statusItem = item
    }

    private func refreshStatusIcon(button: NSStatusBarButton) {
        button.image = OverlayState.shared.paused ? iconPaused : iconActive
    }

    @objc private func togglePause() {
        OverlayState.shared.paused.toggle()
        pauseItem?.title = OverlayState.shared.paused ? "Resume Satsuma" : "Pause Satsuma"
        if let b = statusItem?.button { refreshStatusIcon(button: b) }
        if OverlayState.shared.paused { WheelWindow.shared.hide() }
    }

    @objc private func showOnboarding() { Onboarding.present() }

    @objc private func openSettings() { SettingsWindowController.shared.show() }
}
