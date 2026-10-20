import SwiftUI

struct FormatsTab: View {
    @State private var selected: String = "jpg"
    private let images = ["jpg","png","webp","heic","tiff","avif","bmp"]
    private let docs   = ["pdf"]

    var body: some View {
        HStack(spacing: 0) {
            List(selection: $selected) {
                Section("Images") { ForEach(images, id: \.self) { Text($0.uppercased()).tag($0) } }
                Section("Documents") { ForEach(docs, id: \.self) { Text($0.uppercased()).tag($0) } }
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
    @AppStorage private var quality: String
    @AppStorage private var preserveMeta: Bool

    init(format: String) {
        self.format = format
        self._quality = AppStorage(wrappedValue: "balanced", "quality.\(format)")
        self._preserveMeta = AppStorage(wrappedValue: true, "preserveMetadata.\(format)")
    }

    private static let lossyFormats: Set<String> = ["jpg", "webp", "heic", "avif"]
    private var isLossy: Bool { Self.lossyFormats.contains(format) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(format.uppercased()) Settings").font(.title3).bold()
            Text("Output options for this format. Changes save instantly and apply to future conversions.")
                .font(.caption).foregroundStyle(.secondary)

            GroupBox("Conversion Settings") {
                Picker("Quality", selection: $quality) {
                    Text("High").tag("high")
                    Text("Balanced").tag("balanced")
                    Text("Strong (small)").tag("strong")
                }.pickerStyle(.segmented).disabled(!isLossy)
                if !isLossy {
                    Text("Quality has no effect on \(format.uppercased()) — this is a lossless format.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Toggle("Preserve metadata (EXIF, GPS)", isOn: $preserveMeta)
            }
            Spacer()
        }
    }
}
