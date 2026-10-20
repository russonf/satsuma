import Foundation
import UniformTypeIdentifiers

enum FileKind { case image, video, audio, folder, archive, document, other }

enum FileTypeDetector {
    static func kind(of url: URL) -> FileKind {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
            return .folder
        }
        guard let type = (try? url.resourceValues(forKeys: [.contentTypeKey]))?.contentType else { return .other }
        if type.conforms(to: .image) { return .image }
        if type.conforms(to: .movie) || type.conforms(to: .video) { return .video }
        if type.conforms(to: .audio) { return .audio }
        if type.conforms(to: .archive) { return .archive }
        if type.conforms(to: .text) || type.conforms(to: .pdf)
            || type.conforms(to: .rtf)
            || type.conforms(to: UTType("com.microsoft.word.doc")  ?? .data)
            || type.conforms(to: UTType("org.openxmlformats.wordprocessingml.document") ?? .data)
            || type.conforms(to: UTType("com.apple.iwork.pages.pages") ?? .data) {
            return .document
        }
        return .other
    }

    static func kindOfSet(_ urls: [URL]) -> FileKind {
        guard let first = urls.first else { return .other }
        if urls.count > 1 { return .folder } // treat multi-selection like a folder bundle
        return kind(of: first)
    }
}
