import SwiftUI
import UniformTypeIdentifiers

struct WheelSegment: Identifiable {
    let id = UUID()
    let label: String
    let systemImage: String?
    let action: (URL) -> Void
}

private enum Palette {
    static let segmentIdle   = Color(red: 0.96, green: 0.53, blue: 0.18)
    static let segmentHover  = Color(red: 1.00, green: 0.72, blue: 0.30)
    static let segmentStroke = Color.white.opacity(0.35)
    static let centreFill    = Color.white
    static let centreText    = Color(red: 0.35, green: 0.18, blue: 0.05)
    static let idleText      = Color.white
    static let hoverText     = Color(red: 0.30, green: 0.14, blue: 0.03)
}

struct RadialMenu: View {
    let segments: [WheelSegment]
    var innerRadius: CGFloat = 56
    var ringRadius: CGFloat = 108
    var tileSize: CGFloat = 72

    @State private var hoveredIndex: Int?

    var body: some View {
        let overall = (ringRadius + tileSize / 2) * 2 + 8
        ZStack {
            ForEach(Array(segments.enumerated()), id: \.1.id) { idx, seg in
                segmentView(idx: idx, seg: seg)
                    .frame(width: tileSize, height: tileSize)
                    .offset(tileOffset(idx))
            }
            centreBubble.allowsHitTesting(false)
        }
        .frame(width: overall, height: overall)
    }

    private func tileOffset(_ idx: Int) -> CGSize {
        let n = Double(segments.count)
        let angle = Angle(degrees: Double(idx) / n * 360 - 90)
        return CGSize(width: cos(angle.radians) * ringRadius,
                      height: sin(angle.radians) * ringRadius)
    }

    private func segmentView(idx: Int, seg: WheelSegment) -> some View {
        let isHovered = hoveredIndex == idx
        return VStack(spacing: 4) {
            if let img = seg.systemImage {
                Image(systemName: img).font(.system(size: 17, weight: .semibold))
            }
            Text(seg.label).font(.system(size: 10.5, weight: .bold)).kerning(0.3).lineLimit(1)
        }
        .foregroundStyle(isHovered ? Palette.hoverText : Palette.idleText)
        .frame(width: tileSize, height: tileSize)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isHovered ? Palette.segmentHover : Palette.segmentIdle)
                .shadow(color: isHovered ? Palette.segmentHover.opacity(0.55) : .black.opacity(0.22),
                        radius: isHovered ? 14 : 6, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Palette.segmentStroke, lineWidth: isHovered ? 1.5 : 1)
        )
        .scaleEffect(isHovered ? 1.10 : 1.0)
        .animation(.spring(response: 0.18, dampingFraction: 0.7), value: isHovered)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onDrop(of: [UTType.fileURL], isTargeted: Binding(
            get: { hoveredIndex == idx },
            set: { newVal in
                if newVal { hoveredIndex = idx }
                else if hoveredIndex == idx { hoveredIndex = nil }
            }
        )) { providers in
            handleDrop(providers: providers, action: seg.action)
        }
    }

    private func handleDrop(providers: [NSItemProvider], action: @escaping (URL) -> Void) -> Bool {
        guard let p = providers.first else { return false }
        p.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            var url: URL?
            if let u = item as? URL { url = u }
            else if let data = item as? Data { url = URL(dataRepresentation: data, relativeTo: nil) }
            guard let u = url else { return }
            DispatchQueue.main.async {
                OverlayState.shared.currentFileURL = u
                action(u)
                WheelWindow.shared.hide()
            }
        }
        return true
    }

    private var centreBubble: some View {
        CentreBubble(diameter: innerRadius * 2 - 8)
    }
}

struct WheelHost: View {
    let kind: WheelKind
    var body: some View {
        switch kind {
        case .conversion: ConversionWheel()
        case .tools:      ToolsWheel()
        case .actions:    ActionsWheel()
        case .more:       MoreWheel()
        case .recipes:    RecipesWheel()
        }
    }
}
