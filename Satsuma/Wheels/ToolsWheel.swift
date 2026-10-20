import SwiftUI

struct ToolsWheel: View {
    var body: some View {
        RadialMenu(segments: [
            .init(label: "AIRDROP",   systemImage: "dot.radiowaves.left.and.right") { ToolActions.airdrop() },
            .init(label: "FLOAT",     systemImage: "square.3.layers.3d") { ToolActions.float() },
            .init(label: "COPY",      systemImage: "doc.on.doc") { ToolActions.copy() },
            .init(label: "MOVE",      systemImage: "folder") { ToolActions.move() },
            .init(label: "COPY PATH", systemImage: "link") { ToolActions.copyPath() },
            .init(label: "TERMINAL",  systemImage: "terminal") { ToolActions.openInTerminal() },
        ])
    }
}
