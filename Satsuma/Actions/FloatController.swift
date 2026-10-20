import AppKit
import SwiftUI

final class FloatStore: ObservableObject {
    @Published var urls: [URL] = []
}

final class FloatController {
    static let shared = FloatController()
    private var windows: [(NSWindow, FloatStore)] = []

    func add(_ url: URL) {
        let behaviour = UserDefaults.standard.string(forKey: "float.behaviour") ?? "new"
        if behaviour == "existing", let last = windows.last {
            last.1.urls.append(url)
            last.0.makeKeyAndOrderFront(nil)
            return
        }
        let store = FloatStore()
        store.urls = [url]
        let host = NSHostingView(rootView: FloatPanel(store: store))
        let w = NSPanel(contentRect: NSRect(x: 200, y: 200, width: 240, height: 300),
                        styleMask: [.titled, .closable, .utilityWindow, .nonactivatingPanel, .resizable],
                        backing: .buffered, defer: false)
        w.title = "Float"
        w.isFloatingPanel = true
        w.level = .floating
        w.contentView = host
        w.makeKeyAndOrderFront(nil)
        windows.append((w, store))
    }
}

struct FloatPanel: View {
    @ObservedObject var store: FloatStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(store.urls, id: \.self) { u in
                    HStack {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: u.path))
                            .resizable().frame(width: 24, height: 24)
                        Text(u.lastPathComponent).lineLimit(1).truncationMode(.middle)
                        Spacer()
                    }
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(6)
                    .onDrag { NSItemProvider(object: u as NSURL) }
                }
            }
            .padding(6)
        }
    }
}
