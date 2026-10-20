import SwiftUI

struct ToolsWheel: View {
    var body: some View {
        RadialMenu(segments: [
            .init(label: "AIRDROP",   systemImage: "dot.radiowaves.left.and.right") { _ in ToolActions.airdrop() },
            .init(label: "FLOAT",     systemImage: "square.3.layers.3d") { _ in ToolActions.float() },
            .init(label: "COPY",      systemImage: "doc.on.doc") { _ in ToolActions.copyFile() },
            .init(label: "MOVE",      systemImage: "folder") { _ in ToolActions.move() },
            .init(label: "COPY PATH", systemImage: "link") { _ in ToolActions.copyPath() },
            .init(label: "TERMINAL",  systemImage: "terminal") { _ in ToolActions.openInTerminal() },
        ])
    }
}
