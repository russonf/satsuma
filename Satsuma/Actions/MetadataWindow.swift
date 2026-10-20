import AppKit
import SwiftUI
import ImageIO

enum MetadataWindow {
    static func show(for url: URL) {
        let host = NSHostingController(rootView: MetadataView(url: url))
        let w = NSWindow(contentViewController: host)
        w.title = "Metadata — \(url.lastPathComponent)"
        w.setContentSize(NSSize(width: 460, height: 480))
        w.makeKeyAndOrderFront(nil)
    }
}

struct MetadataView: View {
    let url: URL
    @State private var attrs: [(String, String)] = []

    var body: some View {
        List(attrs, id: \.0) { k, v in
            HStack(alignment: .top) {
                Text(k).font(.caption).foregroundStyle(.secondary).frame(width: 180, alignment: .leading)
                Text(v).font(.caption).textSelection(.enabled)
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        var out: [(String, String)] = []
        if let v = try? url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey, .typeIdentifierKey]) {
            if let s = v.fileSize { out.append(("Size", ByteCountFormatter.string(fromByteCount: Int64(s), countStyle: .file))) }
            if let d = v.creationDate { out.append(("Created", d.formatted())) }
            if let d = v.contentModificationDate { out.append(("Modified", d.formatted())) }
            if let t = v.typeIdentifier { out.append(("UTI", t)) }
        }
        out.append(("Path", url.path))

        if let src = CGImageSourceCreateWithURL(url as CFURL, nil),
           let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [String: Any] {
            flatten(props, prefix: "", into: &out)
        }
        attrs = out
    }

    private func flatten(_ dict: [String: Any], prefix: String, into out: inout [(String, String)]) {
        for (k, v) in dict.sorted(by: { $0.key < $1.key }) {
            let key = prefix.isEmpty ? k : "\(prefix).\(k)"
            if let sub = v as? [String: Any] {
                flatten(sub, prefix: key, into: &out)
            } else {
                out.append((key, String(describing: v)))
            }
        }
    }
}
