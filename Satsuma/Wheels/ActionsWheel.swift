import SwiftUI

struct ActionsWheel: View {
    var body: some View {
        RadialMenu(segments: [
            .init(label: "COMPRESS", systemImage: "arrow.down.circle") { FileActions.compress() },
            .init(label: "METADATA", systemImage: "tag") { FileActions.metadata() },
            .init(label: "EDIT",     systemImage: "slider.horizontal.3") { FileActions.edit() },
            .init(label: "ANNOTATE", systemImage: "pencil.tip") { FileActions.annotate() },
            .init(label: "ADD BG",   systemImage: "photo") { FileActions.addBackground() },
            .init(label: "CROP",     systemImage: "crop") { FileActions.crop() },
            .init(label: "REDACT",   systemImage: "eye.slash") { FileActions.redact() },
        ])
    }
}
