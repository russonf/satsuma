import SwiftUI

struct CentreBubble: View {
    @ObservedObject var state = OverlayState.shared
    let diameter: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(.white)
                .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 2)

            if let img = state.thumbnail {
                Image(nsImage: img)
                    .resizable().scaledToFill()
                    .frame(width: diameter - 10, height: diameter - 10)
                    .clipShape(Circle())
            } else {
                Image(systemName: iconForKind(state.kind))
                    .font(.system(size: diameter * 0.32, weight: .semibold))
                    .foregroundStyle(Color(red: 0.95, green: 0.52, blue: 0.17))
            }

            // Size pill on top of thumbnail
            VStack {
                Spacer()
                Text(state.fileSizeLabel.isEmpty ? "—" : state.fileSizeLabel)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(Color.black.opacity(0.65)))
                    .padding(.bottom, 6)
            }

            if let p = state.progress {
                Circle()
                    .trim(from: 0, to: CGFloat(p))
                    .stroke(Color(red: 1, green: 0.6, blue: 0.2), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: diameter - 2, height: diameter - 2)
                    .animation(.linear(duration: 0.15), value: p)
            }
        }
        .frame(width: diameter, height: diameter)
    }

    private func iconForKind(_ k: FileKind) -> String {
        switch k {
        case .image:    return "photo"
        case .video:    return "film"
        case .audio:    return "waveform"
        case .folder:   return "folder"
        case .archive:  return "archivebox"
        case .document: return "doc.richtext"
        case .other:    return "doc"
        }
    }
}
