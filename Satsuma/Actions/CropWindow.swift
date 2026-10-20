import AppKit
import SwiftUI

enum CropWindow {
    static func show(for url: URL) {
        let host = NSHostingController(rootView: CropView(url: url))
        let w = NSWindow(contentViewController: host)
        w.title = "Crop — \(url.lastPathComponent)"
        w.setContentSize(NSSize(width: 720, height: 540))
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct CropView: View {
    let url: URL
    @State private var image: NSImage?
    @State private var start: CGPoint = .zero
    @State private var end:   CGPoint = .zero
    @State private var dragging = false
    @State private var imgRect: CGRect = .zero

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    if let img = image {
                        Image(nsImage: img)
                            .resizable().scaledToFit()
                            .background(GeometryReader { g in
                                Color.clear.onAppear { imgRect = g.frame(in: .local) }
                            })
                    }
                    if dragging {
                        Rectangle()
                            .path(in: selectionRect)
                            .stroke(Color(red: 1, green: 0.6, blue: 0.2), lineWidth: 2)
                        Rectangle()
                            .path(in: selectionRect)
                            .fill(Color(red: 1, green: 0.6, blue: 0.2).opacity(0.15))
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { v in
                            if !dragging { start = v.startLocation; dragging = true }
                            end = v.location
                        }
                        .onEnded { v in end = v.location }
                )
            }
            Divider()
            HStack {
                Button("Reset") { dragging = false }
                Spacer()
                Button("Save Crop") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!dragging)
            }.padding(8)
        }
        .onAppear { image = NSImage(contentsOf: url) }
    }

    private var selectionRect: CGRect {
        CGRect(x: min(start.x, end.x), y: min(start.y, end.y),
               width: abs(end.x - start.x), height: abs(end.y - start.y))
    }

    private func save() {
        guard let img = image else { return }
        let actual = img.size
        guard let window = NSApp.keyWindow, let contentView = window.contentView else { return }
        let fittedSize = aspectFit(image: actual, in: contentView.bounds.size)
        let imageOrigin = CGPoint(
            x: (contentView.bounds.width  - fittedSize.width)  / 2,
            y: (contentView.bounds.height - fittedSize.height) / 2 - 20 // minus toolbar
        )
        let scale = actual.width / fittedSize.width
        let crop = CGRect(
            x: (selectionRect.minX - imageOrigin.x) * scale,
            y: (fittedSize.height - (selectionRect.maxY - imageOrigin.y)) * scale,
            width: selectionRect.width * scale,
            height: selectionRect.height * scale
        ).intersection(CGRect(origin: .zero, size: actual))

        guard let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil)?.cropping(to: crop) else {
            Toast.shared.show("Crop failed", symbol: "xmark.octagon.fill"); return
        }
        let rep = NSBitmapImageRep(cgImage: cg)
        let data = rep.representation(using: .png, properties: [:])
        let dest = url.deletingPathExtension().appendingPathExtension("cropped.\(url.pathExtension.isEmpty ? "png" : url.pathExtension)")
        try? data?.write(to: dest)
        Toast.shared.show("Cropped → \(dest.lastPathComponent)")
        NSApp.keyWindow?.close()
    }

    private func aspectFit(image: CGSize, in box: CGSize) -> CGSize {
        let scale = min(box.width / image.width, (box.height - 40) / image.height)
        return CGSize(width: image.width * scale, height: image.height * scale)
    }
}
