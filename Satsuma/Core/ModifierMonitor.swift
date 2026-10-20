import AppKit

final class ModifierMonitor {
    private var monitor: Any?
    private let onChange: (NSEvent.ModifierFlags) -> Void

    init(_ onChange: @escaping (NSEvent.ModifierFlags) -> Void) {
        self.onChange = onChange
    }

    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .mouseMoved]) { [weak self] event in
            if event.type == .flagsChanged {
                self?.onChange(event.modifierFlags)
            }
            if event.type == .mouseMoved {
                OverlayState.shared.cursor = NSEvent.mouseLocation
            }
        }
    }

    deinit {
        if let m = monitor { NSEvent.removeMonitor(m) }
    }
}
