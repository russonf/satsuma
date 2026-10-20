import SwiftUI

struct WheelSegment: Identifiable {
    let id = UUID()
    let label: String
    let systemImage: String?
    let action: () -> Void
}

struct RadialMenu: View {
    let segments: [WheelSegment]
    var innerRadius: CGFloat = 42
    var outerRadius: CGFloat = 110

    var body: some View {
        ZStack {
            ForEach(Array(segments.enumerated()), id: \.1.id) { idx, seg in
                let angle = Angle(degrees: Double(idx) / Double(segments.count) * 360 - 90)
                segmentView(seg)
                    .offset(x: cos(angle.radians) * (innerRadius + (outerRadius - innerRadius) / 2),
                            y: sin(angle.radians) * (innerRadius + (outerRadius - innerRadius) / 2))
            }
            centerBubble
        }
        .frame(width: outerRadius * 2, height: outerRadius * 2)
    }

    private func segmentView(_ seg: WheelSegment) -> some View {
        VStack(spacing: 2) {
            if let img = seg.systemImage {
                Image(systemName: img).font(.system(size: 14, weight: .medium))
            }
            Text(seg.label).font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(.white)
        .frame(width: 60, height: 60)
        .background(Circle().fill(Color.black.opacity(0.78)))
    }

    private var centerBubble: some View {
        Text(OverlayState.shared.fileSizeLabel.isEmpty ? "—" : OverlayState.shared.fileSizeLabel)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: innerRadius * 2, height: innerRadius * 2)
            .background(Circle().fill(Color.black.opacity(0.6)))
    }
}

struct WheelHost: View {
    let kind: WheelKind

    var body: some View {
        switch kind {
        case .conversion: ConversionWheel()
        case .tools:      ToolsWheel()
        case .actions:    ActionsWheel()
        }
    }
}
