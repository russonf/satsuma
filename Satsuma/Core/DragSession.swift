import AppKit

/// Heuristic "drag in progress" detector.
/// macOS has no public global drag-session API. We poll the drag pasteboard
/// and the left mouse-button state; when both say "file + button down" we
/// consider a drag active. Good enough for the overlay HUD.
final class DragSession {
    private let onChange: (Bool) -> Void
    private var tick: Timer?
    private var active = false
    private var lastChangeCount: Int

    init(_ onChange: @escaping (Bool) -> Void) {
        self.onChange = onChange
        self.lastChangeCount = NSPasteboard(name: .drag).changeCount
    }

    func start() {
        tick = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
            self?.poll()
        }
        RunLoop.main.add(tick!, forMode: .common)
    }

    private func poll() {
        let pb = NSPasteboard(name: .drag)
        let mouseDown = (NSEvent.pressedMouseButtons & 1) == 1
        let hasFiles = pb.canReadObject(forClasses: [NSURL.self], options: nil)
        let now = mouseDown && hasFiles
        if now != active {
            active = now
            if active {
                if let urls = pb.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], let first = urls.first {
                    OverlayState.shared.currentFileURL = first
                    OverlayState.shared.fileSizeLabel = Self.sizeString(for: first)
                }
            }
            DispatchQueue.main.async { self.onChange(now) }
        }
    }

    private static func sizeString(for url: URL) -> String {
        let v = try? url.resourceValues(forKeys: [.fileSizeKey])
        let bytes = Int64(v?.fileSize ?? 0)
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}
