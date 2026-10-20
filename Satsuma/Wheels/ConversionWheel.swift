import SwiftUI

struct ConversionWheel: View {
    var body: some View {
        RadialMenu(segments: [
            .init(label: "JPG",  systemImage: nil) { ImageConverter.convert(to: .jpg) },
            .init(label: "WEBP", systemImage: nil) { ImageConverter.convert(to: .webp) },
            .init(label: "HEIC", systemImage: nil) { ImageConverter.convert(to: .heic) },
            .init(label: "TIFF", systemImage: nil) { ImageConverter.convert(to: .tiff) },
            .init(label: "AVIF", systemImage: nil) { ImageConverter.convert(to: .avif) },
            .init(label: "BMP",  systemImage: nil) { ImageConverter.convert(to: .bmp) },
            .init(label: "PDF",  systemImage: nil) { ImageConverter.convert(to: .pdf) },
            .init(label: "PNG",  systemImage: nil) { ImageConverter.convert(to: .png) },
        ])
    }
}
