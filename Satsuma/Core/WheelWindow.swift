import AppKit
import SwiftUI

/// Small borderless window that hosts the active wheel. We move the whole
/// window to the cursor so there is zero coordinate math on the SwiftUI side.
final class WheelWindow {
    static let shared = WheelWindow()

    private var window: NSPanel?
    private let size: CGFloat = 340

    func show(kind: WheelKind, at cursor: CGPoint) {
        if window == nil { build() }
        guard let w = window else { return }
        let origin = NSPoint(x: cursor.x - size / 2, y: cursor.y - size / 2)
        w.setFrame(NSRect(origin: origin, size: NSSize(width: size, height: size)), display: true)
        OverlayState.shared.wheel = kind
        w.orderFrontRegardless()
    }

    func hide() {
        OverlayState.shared.wheel = nil
        window?.orderOut(nil)
    }

    private func build() {
        let w = NSPanel(contentRect: NSRect(x: 0, y: 0, width: size, height: size),
                        styleMask: [.borderless, .nonactivatingPanel],
                        backing: .buffered, defer: false)
        w.isOpaque = false
        w.backgroundColor = .clear
        w.hasShadow = false
        w.level = .popUpMenu
        w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        w.isFloatingPanel = true
        let host = NSHostingView(rootView: WheelContainer())
        host.frame = NSRect(x: 0, y: 0, width: size, height: size)
        host.autoresizingMask = [.width, .height]
        w.contentView = host
        window = w
    }
}

struct WheelContainer: View {
    @ObservedObject var state = OverlayState.shared
    var body: some View {
        ZStack {
            if let kind = state.wheel {
                WheelHost(kind: kind)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.22, dampingFraction: 0.72), value: state.wheel)
    }
}
