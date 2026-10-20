import Foundation
import AVFoundation

enum AudioFormat: String { case m4a, wav, aac, mp3, flac, aiff }

enum AudioConverter {
    static func convert(urls: [URL], to format: AudioFormat) {
        for url in urls { convert(url: url, to: format) }
    }

    static func convert(url: URL, to format: AudioFormat) {
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
        export.exportAsynchronously {
            DispatchQueue.main.async {
                if export.status == .completed {
                    Toast.shared.show("Converted to \(ext.uppercased())", resultURL: dest)
                } else {
                    Toast.shared.show("Export failed: \(export.error?.localizedDescription ?? "unknown")", symbol: "xmark.octagon.fill")
                }
            }
        }
    }

    private static func params(for format: AudioFormat) -> (String, AVFileType, String)? {
        switch format {
        case .m4a, .aac: return (AVAssetExportPresetAppleM4A, .m4a,  "m4a")
        case .wav:       return (AVAssetExportPresetPassthrough, .wav,  "wav")
        case .aiff:      return (AVAssetExportPresetPassthrough, .aiff, "aiff")
        case .mp3, .flac: return nil // not native to AVFoundation
        }
    }
}
