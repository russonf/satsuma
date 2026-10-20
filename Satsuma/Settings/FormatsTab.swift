import SwiftUI

struct FormatsTab: View {
    @State private var selected: String = "JPG"
    private let images = ["JPG","PNG","WEBP","HEIC","TIFF","SVG","AVIF","BMP"]
    private let docs   = ["PDF","DOCX","PAGES","PPT","PPTX","TXT","MD"]

    var body: some View {
        HStack(spacing: 0) {
            List(selection: $selected) {
                Section("Images") { ForEach(images, id: \.self) { Text($0).tag($0) } }
                Section("Documents") { ForEach(docs, id: \.self) { Text($0).tag($0) } }
            }
            .frame(width: 150)

            Divider()

            FormatDetail(format: selected).padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct FormatDetail: View {
    let format: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(format) Settings").font(.title3).bold()
            Text("Input and output format. Converts to related image and document types.")
                .font(.caption).foregroundStyle(.secondary)
            GroupBox("Conversion Settings") {
                Toggle("Preserve metadata", isOn: .constant(true))
            }
            GroupBox("Image Compression") {
                Picker("Compression", selection: .constant("balanced")) {
                    Text("Balanced").tag("balanced"); Text("Strong").tag("strong")
                }.pickerStyle(.segmented)
            }
            Spacer()
        }
    }
}
