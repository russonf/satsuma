import Foundation
import AVFoundation

enum VideoFormat: String { case mp4, mov, webm, m4v }

enum VideoConverter {
    static func convert(urls: [URL], to format: VideoFormat) {
        for url in urls { convert(url: url, to: format) }
    }

    static func convert(url: URL, to format: VideoFormat) {
        guard let (preset, fileType, ext) = params(for: format) else {
            Toast.shared.show("\(format.rawValue.uppercased()) encode not supported natively", symbol: "exclamationmark.triangle.fill")
            return
        }
        let asset = AVURLAsset(url: url)
        guard let export = AVAssetExportSession(asset: asset, presetName: preset) else {
            Toast.shared.show("Export init failed", symbol: "xmark.octagon.fill"); return
        }
        let dest = UniquePath.make(url.deletingPathExtension().appendingPathExtension(ext))
        export.outputURL = dest
        export.outputFileType = fileType
        export.shouldOptimizeForNetworkUse = true
        OverlayState.shared.progress = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { t in
            OverlayState.shared.progress = Double(export.progress)
            if export.status != .exporting && export.status != .waiting { t.invalidate() }
        }
        RunLoop.main.add(timer, forMode: .common)

        export.exportAsynchronously {
            DispatchQueue.main.async {
                OverlayState.shared.progress = nil
                if export.status == .completed {
                    Toast.shared.show("Converted to \(ext.uppercased())", resultURL: dest)
                } else {
                    Toast.shared.show("Export failed: \(export.error?.localizedDescription ?? "unknown")", symbol: "xmark.octagon.fill")
                }
            }
        }
    }

    private static func params(for format: VideoFormat) -> (String, AVFileType, String)? {
        switch format {
        case .mp4, .m4v: return (AVAssetExportPresetHighestQuality, .mp4,  format.rawValue)
        case .mov:       return (AVAssetExportPresetHighestQuality, .mov,  "mov")
        case .webm:      return nil
        }
    }
}
