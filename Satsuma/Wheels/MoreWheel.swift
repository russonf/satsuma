import SwiftUI

struct MoreWheel: View {
    var body: some View {
        RadialMenu(segments: [
            .init(label: "OCR",    systemImage: "text.viewfinder") { _ in MoreActions.ocr() },
            .init(label: "HASH",   systemImage: "number")          { _ in MoreActions.hash() },
            .init(label: "RENAME", systemImage: "pencil")          { _ in MoreActions.rename() },
            .init(label: "SHARE",  systemImage: "square.and.arrow.up") { _ in MoreActions.share() },
            .init(label: "ICLOUD", systemImage: "icloud.and.arrow.up") { _ in MoreActions.iCloud() },
            .init(label: "REVEAL", systemImage: "folder.badge.gearshape") { _ in MoreActions.reveal() },
        ])
    }
}
