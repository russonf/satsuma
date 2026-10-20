import AppKit

final class ModifierMonitor {
    private var monitor: Any?
    private let onChange: (NSEvent.ModifierFlags) -> Void

    init(_ onChange: @escaping (NSEvent.ModifierFlags) -> Void) {
        self.onChange = onChange
    }

    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown]) { [weak self] event in
            if event.type == .flagsChanged {
                self?.onChange(event.modifierFlags)
            } else if event.type == .keyDown, event.keyCode == 53 /* Escape */ {
                DispatchQueue.main.async { WheelWindow.shared.hide() }
            }
        }
    }

    deinit {
        if let m = monitor { NSEvent.removeMonitor(m) }
    }
}
