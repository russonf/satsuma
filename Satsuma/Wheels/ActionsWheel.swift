import SwiftUI

struct ActionsWheel: View {
    var body: some View {
        RadialMenu(segments: [
            .init(label: "COMPRESS", systemImage: "arrow.down.circle") { _ in FileActions.compress() },
            .init(label: "RESIZE",   systemImage: "arrow.up.left.and.arrow.down.right") { _ in FileActions.resize() },
            .init(label: "METADATA", systemImage: "tag") { _ in FileActions.metadata() },
            .init(label: "EDIT",     systemImage: "slider.horizontal.3") { _ in FileActions.edit() },
            .init(label: "ANNOTATE", systemImage: "pencil.tip") { _ in FileActions.annotate() },
            .init(label: "ADD BG",   systemImage: "photo") { _ in FileActions.addBackground() },
            .init(label: "CROP",     systemImage: "crop") { _ in FileActions.crop() },
            .init(label: "REDACT",   systemImage: "eye.slash") { _ in FileActions.redact() },
        ])
    }
}
