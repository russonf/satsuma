import Foundation

/// Thin wrapper around `textutil` for document conversions.
/// Supports: rtf, rtfd, html, doc, docx, txt, webarchive.
enum DocumentConverter {
    enum DocFormat: String { case rtf, rtfd, html, doc, docx, txt, webarchive }

    static func convert(url: URL, to format: DocFormat) throws -> URL {
        let dest = url.deletingPathExtension().appendingPathExtension(format.rawValue)
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/textutil")
        proc.arguments = ["-convert", format.rawValue, "-output", dest.path, url.path]
        let err = Pipe()
        proc.standardError = err
        try proc.run()
        proc.waitUntilExit()
        if proc.terminationStatus != 0 {
            let msg = String(data: err.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            throw NSError(domain: "Satsuma", code: Int(proc.terminationStatus),
                          userInfo: [NSLocalizedDescriptionKey: "textutil: \(msg)"])
        }
        return dest
    }
}
