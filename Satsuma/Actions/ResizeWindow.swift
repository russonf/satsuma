import AppKit
import SwiftUI
import ImageIO
import UniformTypeIdentifiers

enum ResizeWindow {
    static func show(for url: URL) {
        let host = NSHostingController(rootView: ResizeView(url: url))
        let w = NSWindow(contentViewController: host)
        w.title = "Resize — \(url.lastPathComponent)"
        w.setContentSize(NSSize(width: 420, height: 340))
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct ResizeView: View {
    let url: URL
    @State private var width: String = ""
    @State private var height: String = ""
    @State private var lockAspect = true
    @State private var originalSize: CGSize = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if originalSize != .zero {
                Text("Original: \(Int(originalSize.width)) × \(Int(originalSize.height)) px")
                    .font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Text("Width"); TextField("px", text: $width).frame(width: 80)
                    .onChange(of: width) { _, new in if lockAspect { autoHeight(from: new) } }
                Text("Height"); TextField("px", text: $height).frame(width: 80)
                    .onChange(of: height) { _, new in if lockAspect { autoWidth(from: new) } }
            }
            Toggle("Keep aspect ratio", isOn: $lockAspect)
            Divider()
            Text("Quick presets").font(.caption).foregroundStyle(.secondary)
            HStack {
                ForEach([480, 720, 1080, 1440, 2160], id: \.self) { h in
                    Button("\(h)") { height = "\(h)"; if lockAspect { autoWidth(from: "\(h)") } }
                }
            }
            Spacer()
            HStack {
                Spacer()
                Button("Cancel") { NSApp.keyWindow?.close() }
                Button("Resize") { save() }.keyboardShortcut(.defaultAction)
                    .disabled(Int(width) == nil && Int(height) == nil)
            }
        }
        .padding(16)
        .onAppear { loadSize() }
    }

    private func loadSize() {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any],
              let w = props[kCGImagePropertyPixelWidth] as? Int,
              let h = props[kCGImagePropertyPixelHeight] as? Int else { return }
        originalSize = CGSize(width: w, height: h)
        width = "\(w)"; height = "\(h)"
    }

    private func autoHeight(from newWidth: String) {
        guard let w = Double(newWidth), originalSize.width > 0 else { return }
        height = "\(Int(w * originalSize.height / originalSize.width))"
    }
    private func autoWidth(from newHeight: String) {
        guard let h = Double(newHeight), originalSize.height > 0 else { return }
        width = "\(Int(h * originalSize.width / originalSize.height))"
    }

    private func save() {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return }
        let targetW = CGFloat(Int(width) ?? Int(originalSize.width))
        let targetH = CGFloat(Int(height) ?? Int(originalSize.height))
        let maxDim = max(targetW, targetH)
        let opts: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDim
        ]
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, opts as CFDictionary) else {
            Toast.shared.show("Resize failed", symbol: "xmark.octagon.fill"); return
        }
        let dest = url.deletingPathExtension()
            .appendingPathExtension("resized.\(url.pathExtension.isEmpty ? "png" : url.pathExtension)")
        let type = (UTType(filenameExtension: url.pathExtension)?.identifier ?? UTType.png.identifier) as CFString
        guard let destRef = CGImageDestinationCreateWithURL(dest as CFURL, type, 1, nil) else {
            Toast.shared.show("Resize failed", symbol: "xmark.octagon.fill"); return
        }
        CGImageDestinationAddImage(destRef, cg, nil)
        if CGImageDestinationFinalize(destRef) {
            Toast.shared.show("Resized → \(dest.lastPathComponent)")
            NSApp.keyWindow?.close()
        } else {
            Toast.shared.show("Resize failed", symbol: "xmark.octagon.fill")
        }
    }
}
