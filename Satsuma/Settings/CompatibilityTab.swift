import SwiftUI

struct CompatibilityTab: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Format Compatibility").font(.headline)
                MatrixView(title: "Images",
                           rows: ["JPG","PNG","WEBP","HEIC","TIFF","SVG","AVIF","BMP"],
                           cols: ["JPG","PNG","WEBP","HEIC","TIFF","AVIF","BMP","PDF"])
                MatrixView(title: "Documents",
                           rows: ["PDF","DOCX","PAGES","PPT","PPTX","TXT","MD","RTF","RTFD"],
                           cols: ["PDF","DOCX","PAGES","PPTX","TXT","MD","HTML","EPUB","JPG","PNG","XLSX"])
            }.padding()
        }
    }
}

private struct MatrixView: View {
    let title: String
    let rows: [String]
    let cols: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).bold()
            Grid(horizontalSpacing: 6, verticalSpacing: 4) {
                GridRow {
                    Text("").frame(width: 56)
                    ForEach(cols, id: \.self) { Text($0).font(.caption).frame(width: 36) }
                }
                ForEach(rows, id: \.self) { r in
                    GridRow {
                        Text(r).font(.caption).frame(width: 56, alignment: .leading)
                        ForEach(cols, id: \.self) { c in
                            Text(r == c ? "—" : "✓").frame(width: 36).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
