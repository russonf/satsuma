import Foundation

/// Shells out to `textutil` for document conversions.
enum DocumentConverter {
    enum DocFormat: String { case rtf, rtfd, html, doc, docx, txt, webarchive, md }

    static func convert(urls: [URL], to format: DocFormat) {
        DispatchQueue.global(qos: .userInitiated).async {
            var ok = 0
            var last: URL?
            for u in urls {
                do { last = try perform(url: u, to: format); ok += 1 }
                catch { NSLog("textutil: \(error)") }
            }
            Toast.shared.show("\(ok)/\(urls.count) → \(format.rawValue.uppercased())", resultURL: last)
        }
    }

    static func perform(url: URL, to format: DocFormat) throws -> URL {
        if format == .md { return try toMarkdown(url: url) }
        let dest = UniquePath.make(url.deletingPathExtension().appendingPathExtension(format.rawValue))
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

    /// Best-effort MD export: convert to plain text and write .md. Not a true Markdown render.
    private static func toMarkdown(url: URL) throws -> URL {
        let tmpTxt = try perform(url: url, to: .txt)
        let dest = UniquePath.make(url.deletingPathExtension().appendingPathExtension("md"))
        try FileManager.default.moveItem(at: tmpTxt, to: dest)
        return dest
    }
}
