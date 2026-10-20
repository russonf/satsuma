import Foundation
import ImageIO
import UniformTypeIdentifiers
import PDFKit
import AppKit

enum TargetFormat: String {
    case jpg, png, webp, heic, tiff, avif, bmp, pdf

    var utType: UTType? {
        switch self {
        case .jpg:  return .jpeg
        case .png:  return .png
        case .webp: return .webP
        case .heic: return .heic
        case .tiff: return .tiff
        case .avif: return UTType("public.avif")
        case .bmp:  return .bmp
        case .pdf:  return .pdf
        }
    }
    var ext: String { rawValue }
}

enum ImageConverter {
    static func convert(to format: TargetFormat) {
        guard let url = OverlayState.shared.currentFileURL else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let out = try perform(url: url, to: format)
                NSLog("Satsuma: wrote \(out.path)")
                NotificationCenter.default.post(name: .satsumaDidWriteFile, object: out)
            } catch {
                NSLog("Satsuma: convert failed: \(error)")
            }
        }
    }

    static func perform(url: URL, to format: TargetFormat) throws -> URL {
        let dest = url.deletingPathExtension().appendingPathExtension(format.ext)
        if format == .pdf {
            return try imageToPDF(url: url, dest: dest)
        }
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil),
              let type = format.utType else {
            throw NSError(domain: "Satsuma", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported source or target"])
        }
        guard let destRef = CGImageDestinationCreateWithURL(dest as CFURL, type.identifier as CFString, 1, nil) else {
            throw NSError(domain: "Satsuma", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create destination"])
        }
        let quality = UserDefaults.standard.object(forKey: "quality.\(format.rawValue)") as? Double ?? 0.85
        let opts: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
        CGImageDestinationAddImageFromSource(destRef, src, 0, opts as CFDictionary)
        if !CGImageDestinationFinalize(destRef) {
            throw NSError(domain: "Satsuma", code: 3, userInfo: [NSLocalizedDescriptionKey: "Finalize failed"])
        }
        return dest
    }

    private static func imageToPDF(url: URL, dest: URL) throws -> URL {
        guard let image = NSImage(contentsOf: url) else {
            throw NSError(domain: "Satsuma", code: 10, userInfo: [NSLocalizedDescriptionKey: "Could not load image"])
        }
        let doc = PDFDocument()
        if let page = PDFPage(image: image) {
            doc.insert(page, at: 0)
        }
        doc.write(to: dest)
        return dest
    }
}

extension Notification.Name {
    static let satsumaDidWriteFile = Notification.Name("satsumaDidWriteFile")
}
