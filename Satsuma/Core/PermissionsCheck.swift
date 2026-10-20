import AppKit
import ApplicationServices

enum PermissionsCheck {
    @discardableResult
    static func ensureAccessibility() -> Bool {
        let opts: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(opts)
    }
}
