import AppKit

/// Heuristic "drag in progress" detector.
final class DragSession {
    private let onChange: (Bool) -> Void
    private var tick: Timer?
    private var active = false

    init(_ onChange: @escaping (Bool) -> Void) {
        self.onChange = onChange
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
                if let urls = pb.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty {
                    OverlayState.shared.currentURLs = urls
                    OverlayState.shared.currentFileURL = urls.first
                    OverlayState.shared.fileSizeLabel = Self.sizeString(for: urls)
                    OverlayState.shared.thumbnail = nil
                    if let first = urls.first {
                        ThumbnailProvider.request(for: first, size: CGSize(width: 96, height: 96)) { img in
                            OverlayState.shared.thumbnail = img
                        }
                    }
                }
            }
            DispatchQueue.main.async { self.onChange(now) }
        }
    }

    private static func sizeString(for urls: [URL]) -> String {
        let bytes = urls.reduce(Int64(0)) { acc, u in
            let v = try? u.resourceValues(forKeys: [.fileSizeKey])
            return acc + Int64(v?.fileSize ?? 0)
        }
        let total = ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
        return urls.count > 1 ? "\(urls.count) · \(total)" : total
    }
}
