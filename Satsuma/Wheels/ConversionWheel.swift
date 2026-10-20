import SwiftUI

struct ConversionWheel: View {
    @ObservedObject var state = OverlayState.shared

    var body: some View {
        switch state.kind {
        case .video:    RadialMenu(segments: videoSegments)
        case .audio:    RadialMenu(segments: audioSegments)
        case .folder:   RadialMenu(segments: archiveSegments)
        case .document: RadialMenu(segments: documentSegments)
        default:        RadialMenu(segments: imageSegments)
        }
    }

    private var documentSegments: [WheelSegment] { [
        .init(label: "PDF",  systemImage: nil) { _ in ImageConverter.convert(urls: state.currentURLs, to: .pdf) },
        .init(label: "RTF",  systemImage: nil) { _ in DocumentConverter.convert(urls: state.currentURLs, to: .rtf) },
        .init(label: "DOCX", systemImage: nil) { _ in DocumentConverter.convert(urls: state.currentURLs, to: .docx) },
        .init(label: "HTML", systemImage: nil) { _ in DocumentConverter.convert(urls: state.currentURLs, to: .html) },
        .init(label: "TXT",  systemImage: nil) { _ in DocumentConverter.convert(urls: state.currentURLs, to: .txt) },
        .init(label: "MD",   systemImage: nil) { _ in DocumentConverter.convert(urls: state.currentURLs, to: .md) },
    ] }

    private var imageSegments: [WheelSegment] { [
        .init(label: "JPG",  systemImage: nil) { _ in ImageConverter.convert(urls: state.currentURLs, to: .jpg) },
        .init(label: "PNG",  systemImage: nil) { _ in ImageConverter.convert(urls: state.currentURLs, to: .png) },
        .init(label: "WEBP", systemImage: nil) { _ in ImageConverter.convert(urls: state.currentURLs, to: .webp) },
        .init(label: "HEIC", systemImage: nil) { _ in ImageConverter.convert(urls: state.currentURLs, to: .heic) },
        .init(label: "TIFF", systemImage: nil) { _ in ImageConverter.convert(urls: state.currentURLs, to: .tiff) },
        .init(label: "AVIF", systemImage: nil) { _ in ImageConverter.convert(urls: state.currentURLs, to: .avif) },
        .init(label: "BMP",  systemImage: nil) { _ in ImageConverter.convert(urls: state.currentURLs, to: .bmp) },
        .init(label: "PDF",  systemImage: nil) { _ in ImageConverter.convert(urls: state.currentURLs, to: .pdf) },
    ] }

    private var videoSegments: [WheelSegment] { [
        .init(label: "MP4",  systemImage: nil) { _ in VideoConverter.convert(urls: state.currentURLs, to: .mp4) },
        .init(label: "MOV",  systemImage: nil) { _ in VideoConverter.convert(urls: state.currentURLs, to: .mov) },
        .init(label: "M4V",  systemImage: nil) { _ in VideoConverter.convert(urls: state.currentURLs, to: .m4v) },
        .init(label: "WEBM", systemImage: nil) { _ in VideoConverter.convert(urls: state.currentURLs, to: .webm) },
    ] }

    private var audioSegments: [WheelSegment] { [
        .init(label: "M4A",  systemImage: nil) { _ in AudioConverter.convert(urls: state.currentURLs, to: .m4a) },
        .init(label: "WAV",  systemImage: nil) { _ in AudioConverter.convert(urls: state.currentURLs, to: .wav) },
        .init(label: "AAC",  systemImage: nil) { _ in AudioConverter.convert(urls: state.currentURLs, to: .aac) },
        .init(label: "AIFF", systemImage: nil) { _ in AudioConverter.convert(urls: state.currentURLs, to: .aiff) },
        .init(label: "MP3",  systemImage: nil) { _ in AudioConverter.convert(urls: state.currentURLs, to: .mp3) },
        .init(label: "FLAC", systemImage: nil) { _ in AudioConverter.convert(urls: state.currentURLs, to: .flac) },
    ] }

    private var archiveSegments: [WheelSegment] { [
        .init(label: "ZIP",  systemImage: "archivebox") { _ in ArchiveConverter.create(urls: state.currentURLs, format: .zip) },
        .init(label: "TAR",  systemImage: "shippingbox") { _ in ArchiveConverter.create(urls: state.currentURLs, format: .tar) },
        .init(label: "TGZ",  systemImage: "archivebox.fill") { _ in ArchiveConverter.create(urls: state.currentURLs, format: .tgz) },
        .init(label: "GZ",   systemImage: "doc.zipper") { _ in ArchiveConverter.create(urls: state.currentURLs, format: .gz) },
    ] }
}
