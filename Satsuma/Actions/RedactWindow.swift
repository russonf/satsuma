import AppKit
import SwiftUI

enum RedactWindow {
    static func show(for url: URL) {
        let host = NSHostingController(rootView: RedactView(url: url))
        let w = NSWindow(contentViewController: host)
        w.title = "Redact — \(url.lastPathComponent)"
        w.setContentSize(NSSize(width: 720, height: 540))
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct RedactView: View {
    let url: URL
    @State private var image: NSImage?
    @State private var marks: [CGRect] = []
    @State private var start: CGPoint = .zero
    @State private var current: CGPoint = .zero
    @State private var drawing = false

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    if let img = image {
                        Image(nsImage: img).resizable().scaledToFit()
                    }
                    ForEach(0..<marks.count, id: \.self) { i in
                        Rectangle().path(in: marks[i]).fill(.black)
                    }
                    if drawing {
                        Rectangle().path(in: liveRect).fill(.black.opacity(0.7))
                    }
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 2)
                    .onChanged { v in
                        if !drawing { start = v.startLocation; drawing = true }
                        current = v.location
                    }
                    .onEnded { v in
                        current = v.location
                        if liveRect.width > 3 && liveRect.height > 3 { marks.append(liveRect) }
                        drawing = false
                    }
                )
            }
            Divider()
            HStack {
                Button("Undo") { if !marks.isEmpty { marks.removeLast() } }
                Button("Clear") { marks.removeAll() }
                Spacer()
                Button("Save Redacted") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(marks.isEmpty)
            }.padding(8)
        }
        .onAppear { image = NSImage(contentsOf: url) }
    }

    private var liveRect: CGRect {
        CGRect(x: min(start.x, current.x), y: min(start.y, current.y),
               width: abs(current.x - start.x), height: abs(current.y - start.y))
    }

    private func save() {
        guard let img = image, let window = NSApp.keyWindow, let content = window.contentView else { return }
        let actual = img.size
        let fitted = aspectFit(image: actual, in: content.bounds.size)
        let origin = CGPoint(
            x: (content.bounds.width - fitted.width) / 2,
            y: (content.bounds.height - fitted.height) / 2 - 20
        )
        let scale = actual.width / fitted.width

        let rendered = NSImage(size: actual)
        rendered.lockFocus()
        img.draw(in: NSRect(origin: .zero, size: actual))
        NSColor.black.setFill()
        for r in marks {
            let imageRect = CGRect(
                x: (r.minX - origin.x) * scale,
                y: (fitted.height - (r.maxY - origin.y)) * scale,
                width: r.width * scale,
                height: r.height * scale
            )
            imageRect.fill()
        }
        rendered.unlockFocus()

        let dest = url.deletingPathExtension().appendingPathExtension("redacted.png")
        if let tiff = rendered.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff),
           let data = rep.representation(using: .png, properties: [:]) {
            try? data.write(to: dest)
            Toast.shared.show("Redacted → \(dest.lastPathComponent)")
            NSApp.keyWindow?.close()
        }
    }

    private func aspectFit(image: CGSize, in box: CGSize) -> CGSize {
        let scale = min(box.width / image.width, (box.height - 40) / image.height)
        return CGSize(width: image.width * scale, height: image.height * scale)
    }
}
