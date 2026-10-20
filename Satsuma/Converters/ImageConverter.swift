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
    static func convert(urls: [URL], to format: TargetFormat) {
        DispatchQueue.global(qos: .userInitiated).async {
            var okCount = 0
            var lastDest: URL?
            for u in urls {
                do {
                    lastDest = try perform(url: u, to: format); okCount += 1
                } catch {
                    NSLog("Satsuma convert failed: \(error)")
                }
            }
            let noun = urls.count == 1 ? "file" : "files"
            Toast.shared.show("\(okCount)/\(urls.count) \(noun) → \(format.rawValue.uppercased())", resultURL: lastDest)
        }
    }

    static func perform(url: URL, to format: TargetFormat) throws -> URL {
        let dest = UniquePath.make(url.deletingPathExtension().appendingPathExtension(format.ext))
        if format == .pdf { return try imageToPDF(url: url, dest: dest) }
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil),
              let type = format.utType else {
            throw NSError(domain: "Satsuma", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported source or target"])
        }
        guard let destRef = CGImageDestinationCreateWithURL(dest as CFURL, type.identifier as CFString, 1, nil) else {
            throw NSError(domain: "Satsuma", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create destination"])
        }
        let quality = qualityFromSettings(for: format)
        let preserveMeta = UserDefaults.standard.object(forKey: "preserveMetadata.\(format.rawValue)") as? Bool ?? true
        var opts: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
        if !preserveMeta {
            opts[kCGImageMetadataShouldExcludeGPS] = true
        }
        CGImageDestinationAddImageFromSource(destRef, src, 0, opts as CFDictionary)
        if !CGImageDestinationFinalize(destRef) {
            throw NSError(domain: "Satsuma", code: 3, userInfo: [NSLocalizedDescriptionKey: "Finalize failed"])
        }
        return dest
    }

    private static func qualityFromSettings(for format: TargetFormat) -> Double {
        switch UserDefaults.standard.string(forKey: "quality.\(format.rawValue)") ?? "balanced" {
        case "high":   return 0.95
        case "strong": return 0.65
        default:       return 0.85
        }
    }

    private static func imageToPDF(url: URL, dest: URL) throws -> URL {
        guard let image = NSImage(contentsOf: url) else {
            throw NSError(domain: "Satsuma", code: 10, userInfo: [NSLocalizedDescriptionKey: "Could not load image"])
        }
        let doc = PDFDocument()
        if let page = PDFPage(image: image) { doc.insert(page, at: 0) }
        doc.write(to: dest)
        return dest
    }
}

extension Notification.Name {
    static let satsumaDidWriteFile = Notification.Name("satsumaDidWriteFile")
}
