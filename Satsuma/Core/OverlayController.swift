import AppKit
import SwiftUI

final class OverlayController {
    private var modifierMonitor: ModifierMonitor?
    private var dragSession: DragSession?

    func start() {
        modifierMonitor = ModifierMonitor { [weak self] mods in
            self?.handleModifiers(mods)
        }
        modifierMonitor?.start()

        dragSession = DragSession { active in
            OverlayState.shared.dragActive = active
            if !active { WheelWindow.shared.hide() }
        }
        dragSession?.start()
    }

    private func handleModifiers(_ mods: NSEvent.ModifierFlags) {
        guard OverlayState.shared.dragActive, !OverlayState.shared.paused else { return }
        let conv = modifierKey("mod.conversion", default: .shift)
        let tool = modifierKey("mod.tools",      default: .command)
        let act  = modifierKey("mod.actions",    default: .control)
        let more = modifierKey("mod.more",       default: .option)

        let newWheel: WheelKind?
        // Combo first — Shift+Option opens Recipes.
        if mods.contains(.shift) && mods.contains(.option) { newWheel = .recipes }
        else if mods.contains(conv) { newWheel = .conversion }
        else if mods.contains(tool) { newWheel = .tools }
        else if mods.contains(act)  { newWheel = .actions }
        else if mods.contains(more) { newWheel = .more }
        else                        { newWheel = nil }

        if let kind = newWheel {
            if OverlayState.shared.wheel == nil {
                WheelWindow.shared.show(kind: kind, at: NSEvent.mouseLocation)
            } else {
                OverlayState.shared.wheel = kind
            }
        } else {
            WheelWindow.shared.hide()
        }
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
    @Published var fileSizeLabel: String = ""
    @Published var currentFileURL: URL? = nil
    @Published var currentURLs: [URL] = []
    @Published var thumbnail: NSImage? = nil
    @Published var paused: Bool = false
    @Published var progress: Double? = nil   // nil = no active job
    @Published var lastResult: URL? = nil

    var kind: FileKind { FileTypeDetector.kindOfSet(currentURLs) }
}

enum WheelKind { case conversion, tools, actions, more, recipes }
