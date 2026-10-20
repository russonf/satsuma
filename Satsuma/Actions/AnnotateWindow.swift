import AppKit
import SwiftUI

enum AnnotateWindow {
    static func show(for url: URL) {
        let host = NSHostingController(rootView: AnnotateView(url: url))
        let w = NSWindow(contentViewController: host)
        w.title = "Annotate — \(url.lastPathComponent)"
        w.setContentSize(NSSize(width: 820, height: 600))
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

private struct Stroke: Identifiable { let id = UUID(); var points: [CGPoint]; var color: Color; var width: CGFloat }
private struct Label2: Identifiable { let id = UUID(); var position: CGPoint; var text: String; var color: Color }

struct AnnotateView: View {
    let url: URL
    @State private var image: NSImage?
    @State private var strokes: [Stroke] = []
    @State private var labels: [Label2]  = []
    @State private var current: Stroke?
    @State private var color: Color = Color(red: 1, green: 0.6, blue: 0.2)
    @State private var width: CGFloat = 4
    @State private var tool: Tool = .pen
    @State private var newLabelText = ""

    enum Tool { case pen, text }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            GeometryReader { geo in
                ZStack {
                    if let img = image { Image(nsImage: img).resizable().scaledToFit() }
                    Canvas { ctx, size in
                        for s in strokes { draw(s, in: ctx) }
                        if let c = current { draw(c, in: ctx) }
                    }
                    ForEach(labels) { l in
                        Text(l.text)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(l.color)
                            .padding(4)
                            .background(.white.opacity(0.9))
                            .cornerRadius(6)
                            .position(l.position)
                    }
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        guard tool == .pen else { return }
                        if current == nil { current = Stroke(points: [v.startLocation], color: color, width: width) }
                        current?.points.append(v.location)
                    }
                    .onEnded { _ in
                        if tool == .pen, let s = current { strokes.append(s) }
                        current = nil
                    }
                )
                .onTapGesture { pos in
                    guard tool == .text, !newLabelText.isEmpty else { return }
                    labels.append(Label2(position: pos, text: newLabelText, color: color))
                    newLabelText = ""
                }
            }
        }
        .onAppear { image = NSImage(contentsOf: url) }
    }

    private var toolbar: some View {
        HStack(spacing: 10) {
            Picker("", selection: $tool) {
                Text("Pen").tag(Tool.pen); Text("Text").tag(Tool.text)
            }.pickerStyle(.segmented).frame(width: 160)
            ColorPicker("", selection: $color).labelsHidden()
            Slider(value: $width, in: 1...20).frame(width: 100)
            if tool == .text {
                TextField("label", text: $newLabelText).frame(width: 120)
                Text("tap on image to place").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button("Undo") { if !strokes.isEmpty { strokes.removeLast() } else if !labels.isEmpty { labels.removeLast() } }
            Button("Save") { save() }.keyboardShortcut(.defaultAction)
        }.padding(10)
    }

    private func draw(_ s: Stroke, in ctx: GraphicsContext) {
        var path = Path()
        if let first = s.points.first {
            path.move(to: first)
            for p in s.points.dropFirst() { path.addLine(to: p) }
        }
        ctx.stroke(path, with: .color(s.color), style: StrokeStyle(lineWidth: s.width, lineCap: .round, lineJoin: .round))
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

        let out = NSImage(size: actual)
        out.lockFocus()
        img.draw(in: NSRect(origin: .zero, size: actual))
        let ctx = NSGraphicsContext.current?.cgContext
        for s in strokes {
            ctx?.setLineCap(.round); ctx?.setLineJoin(.round)
            ctx?.setLineWidth(s.width * scale)
            if let cg = NSColor(s.color).cgColor as CGColor? { ctx?.setStrokeColor(cg) }
            ctx?.beginPath()
            for (i, p) in s.points.enumerated() {
                let imgP = CGPoint(x: (p.x - origin.x) * scale,
                                   y: (fitted.height - (p.y - origin.y)) * scale)
                if i == 0 { ctx?.move(to: imgP) } else { ctx?.addLine(to: imgP) }
            }
            ctx?.strokePath()
        }
        for l in labels {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 18 * scale),
                .foregroundColor: NSColor(l.color)
            ]
            let str = NSAttributedString(string: l.text, attributes: attrs)
            let p = CGPoint(x: (l.position.x - origin.x) * scale,
                            y: (fitted.height - (l.position.y - origin.y)) * scale)
            str.draw(at: p)
        }
        out.unlockFocus()

        let dest = url.deletingPathExtension().appendingPathExtension("annotated.png")
        if let tiff = out.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff),
           let data = rep.representation(using: .png, properties: [:]) {
            try? data.write(to: dest)
            Toast.shared.show("Annotated → \(dest.lastPathComponent)")
            NSApp.keyWindow?.close()
        }
    }

    private func aspectFit(image: CGSize, in box: CGSize) -> CGSize {
        let scale = min(box.width / image.width, (box.height - 40) / image.height)
        return CGSize(width: image.width * scale, height: image.height * scale)
    }
}
