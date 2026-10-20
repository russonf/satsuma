import AppKit
import SwiftUI

enum AddBackgroundWindow {
    static func show(for url: URL) {
        let host = NSHostingController(rootView: AddBackgroundView(url: url))
        let w = NSWindow(contentViewController: host)
        w.title = "Add Background — \(url.lastPathComponent)"
        w.setContentSize(NSSize(width: 640, height: 520))
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct AddBackgroundView: View {
    let url: URL
    @State private var image: NSImage?
    @State private var bg: Color = .white
    @State private var padding: CGFloat = 48

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ColorPicker("Background", selection: $bg).labelsHidden()
                ForEach([Color.white, .black, Color(red: 1, green: 0.95, blue: 0.9),
                         Color(red: 0.1, green: 0.1, blue: 0.12),
                         Color(red: 1, green: 0.6, blue: 0.2)], id: \.self) { c in
                    Button {
                        bg = c
                    } label: {
                        Circle().fill(c).frame(width: 22, height: 22)
                            .overlay(Circle().stroke(.separator))
                    }.buttonStyle(.plain)
                }
                Text("Padding")
                Slider(value: $padding, in: 0...200).frame(width: 160)
                Text("\(Int(padding))px").font(.caption).foregroundStyle(.secondary).frame(width: 50)
                Spacer()
                Button("Save") { save() }.keyboardShortcut(.defaultAction)
            }.padding(10)
            Divider()
            ZStack {
                bg
                if let img = image {
                    Image(nsImage: img).resizable().scaledToFit().padding(padding)
                }
            }
        }
        .onAppear { image = NSImage(contentsOf: url) }
    }

    private func save() {
        guard let img = image else { return }
        let size = img.size
        let out = NSImage(size: CGSize(width: size.width + padding * 2, height: size.height + padding * 2))
        out.lockFocus()
        NSColor(bg).setFill()
        NSRect(origin: .zero, size: out.size).fill()
        img.draw(in: NSRect(x: padding, y: padding, width: size.width, height: size.height))
        out.unlockFocus()
        let dest = url.deletingPathExtension().appendingPathExtension("bg.png")
        if let tiff = out.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff),
           let data = rep.representation(using: .png, properties: [:]) {
            try? data.write(to: dest)
            Toast.shared.show("Saved → \(dest.lastPathComponent)")
            NSApp.keyWindow?.close()
        }
    }
}
