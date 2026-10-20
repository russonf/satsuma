import SwiftUI

struct CompatibilityTab: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("What Satsuma can convert")
                    .font(.headline)
                Text("Live from the code — row is the input, column is the output. Satsuma can do everything with a ✓, nothing with a —.")
                    .font(.caption).foregroundStyle(.secondary)
                ForEach(CompatibilityCatalog.sections.indices, id: \.self) { i in
                    MatrixCard(section: CompatibilityCatalog.sections[i])
                }
            }
            .padding(16)
        }
    }
}

private struct MatrixCard: View {
    let section: CompatibilityCatalog.Section
    private let colWidth: CGFloat = 44
    private let rowLabelWidth: CGFloat = 100

    var body: some View {
        GroupBox(section.title) {
            Grid(horizontalSpacing: 2, verticalSpacing: 4) {
                GridRow {
                    Text("").frame(width: rowLabelWidth)
                    ForEach(section.cols, id: \.self) { c in
                        Text(c).font(.caption).bold().frame(width: colWidth)
                    }
                }
                Divider()
                ForEach(section.rows, id: \.self) { r in
                    GridRow {
                        Text(r).font(.caption).bold()
                            .frame(width: rowLabelWidth, alignment: .leading)
                        ForEach(section.cols, id: \.self) { c in
                            cell(r, c)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func cell(_ r: String, _ c: String) -> some View {
        let supported = section.supports(r, c)
        Text(supported ? "✓" : "—")
            .font(.caption)
            .foregroundStyle(supported ? Color(red: 0.95, green: 0.52, blue: 0.17) : .secondary.opacity(0.5))
            .frame(width: colWidth, height: 20)
    }
}
