import Foundation
import ServiceManagement

enum LaunchAtLogin {
    static var isEnabled: Bool {
        if #available(macOS 13.0, *) { return SMAppService.mainApp.status == .enabled }
        return false
    }

    static func set(_ enabled: Bool) {
        guard #available(macOS 13.0, *) else { return }
        do {
            if enabled { try SMAppService.mainApp.register() }
            else       { try SMAppService.mainApp.unregister() }
        } catch {
            NSLog("Satsuma launch-at-login failed: \(error)")
        }
    }
}
