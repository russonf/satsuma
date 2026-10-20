import AppKit
import SwiftUI

final class OverlayController {
    private var window: NSWindow?
    private var modifierMonitor: ModifierMonitor?
    private var dragSession: DragSession?

    func start() {
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        let w = NSWindow(contentRect: screenFrame,
                         styleMask: [.borderless],
                         backing: .buffered,
                         defer: false)
        w.isOpaque = false
        w.backgroundColor = .clear
        w.level = .screenSaver
        w.ignoresMouseEvents = true
        w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        w.hasShadow = false

        let host = NSHostingView(rootView: OverlayRoot(state: OverlayState.shared))
        host.frame = w.contentView?.bounds ?? .zero
        host.autoresizingMask = [.width, .height]
        w.contentView?.addSubview(host)
        w.orderFrontRegardless()
        self.window = w

        modifierMonitor = ModifierMonitor { [weak self] mods in
            self?.handleModifiers(mods)
        }
        modifierMonitor?.start()

        dragSession = DragSession { active in
            OverlayState.shared.dragActive = active
            if !active { OverlayState.shared.wheel = nil }
        }
        dragSession?.start()
    }

    private func handleModifiers(_ mods: NSEvent.ModifierFlags) {
        guard OverlayState.shared.dragActive else { return }
        let conv = modifierKey("mod.conversion", default: .shift)
        let tool = modifierKey("mod.tools",      default: .command)
        let act  = modifierKey("mod.actions",    default: .control)
        if mods.contains(conv)      { OverlayState.shared.wheel = .conversion }
        else if mods.contains(tool) { OverlayState.shared.wheel = .tools }
        else if mods.contains(act)  { OverlayState.shared.wheel = .actions }
        else { OverlayState.shared.wheel = nil }
    }

    private func modifierKey(_ key: String, default def: NSEvent.ModifierFlags) -> NSEvent.ModifierFlags {
        switch UserDefaults.standard.string(forKey: key) ?? "" {
        case "shift":   return .shift
        case "command": return .command
        case "control": return .control
        case "option":  return .option
        default:        return def
        }
    }
}

final class OverlayState: ObservableObject {
    static let shared = OverlayState()
    @Published var dragActive: Bool = false
    @Published var wheel: WheelKind? = nil
    @Published var cursor: CGPoint = .zero
    @Published var fileSizeLabel: String = ""
    @Published var currentFileURL: URL? = nil
}

enum WheelKind { case conversion, tools, actions }

struct OverlayRoot: View {
    @ObservedObject var state: OverlayState

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let wheel = state.wheel {
                    WheelHost(kind: wheel)
                        .position(screenToView(state.cursor, in: geo))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: state.wheel)
        }
        .ignoresSafeArea()
    }

    /// Convert global (bottom-left-origin) screen coords to the hosting
    /// view's local (top-left-origin) coords, accounting for the overlay's
    /// window origin.
    private func screenToView(_ p: CGPoint, in geo: GeometryProxy) -> CGPoint {
        let frame = NSScreen.main?.frame ?? .zero
        return CGPoint(x: p.x - frame.origin.x,
                       y: frame.height - (p.y - frame.origin.y))
    }
}
