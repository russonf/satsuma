import AppKit
import QuickLookThumbnailing

enum ThumbnailProvider {
    static func request(for url: URL, size: CGSize, scale: CGFloat = 2, completion: @escaping (NSImage?) -> Void) {
        let req = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .all)
        QLThumbnailGenerator.shared.generateBestRepresentation(for: req) { rep, _ in
            DispatchQueue.main.async { completion(rep?.nsImage) }
        }
    }
}
