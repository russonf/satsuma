import AppKit
import SwiftUI

final class Toast {
    static let shared = Toast()
    private var window: NSPanel?
    private var dismissWork: DispatchWorkItem?

    func show(_ text: String, symbol: String = "checkmark.circle.fill", resultURL: URL? = nil) {
        DispatchQueue.main.async {
            if let r = resultURL { OverlayState.shared.lastResult = r }
            self.present(text, symbol: symbol, result: resultURL ?? OverlayState.shared.lastResult)
        }
    }

    private func present(_ text: String, symbol: String, result: URL?) {
        let hasResult = result != nil
        let host = NSHostingView(rootView: ToastView(text: text, symbol: symbol, result: result))
        let size = NSSize(width: 360, height: hasResult ? 72 : 56)
        if window == nil {
            let w = NSPanel(contentRect: NSRect(origin: .zero, size: size),
                            styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
            w.isOpaque = false
            w.backgroundColor = .clear
            w.hasShadow = true
            w.level = .popUpMenu
            w.isFloatingPanel = true
            w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window = w
        }
        guard let w = window, let screen = NSScreen.main else { return }
        host.frame = NSRect(origin: .zero, size: size)
        w.contentView = host
        let x = screen.visibleFrame.maxX - size.width - 24
        let y = screen.visibleFrame.maxY - size.height - 24
        w.setFrame(NSRect(x: x, y: y, width: size.width, height: size.height), display: true)
        w.orderFrontRegardless()

        if UserDefaults.standard.object(forKey: "general.haptics") as? Bool ?? true {
            NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            NSSound(named: "Pop")?.play()
        }
        dismissWork?.cancel()
        let dismiss = DispatchWorkItem { w.orderOut(nil) }
        dismissWork = dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + (hasResult ? 5.0 : 1.8), execute: dismiss)
    }
}

private struct ToastView: View {
    let text: String
    let symbol: String
    let result: URL?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 1.0, green: 0.60, blue: 0.20))
            VStack(alignment: .leading, spacing: 2) {
                Text(text).font(.system(size: 13, weight: .medium)).lineLimit(2)
                if result != nil {
                    Text("Drag the icon to another app →")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let url = result {
                DragHandle(url: url)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
        )
        .padding(.horizontal, 2)
    }
}

private struct DragHandle: View {
    let url: URL
    var body: some View {
        Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
            .resizable().scaledToFit()
            .frame(width: 36, height: 36)
            .padding(6)
            .background(RoundedRectangle(cornerRadius: 10).fill(.quaternary))
            .onDrag { NSItemProvider(object: url as NSURL) }
            .help("Drag \(url.lastPathComponent) to another app")
    }
}
