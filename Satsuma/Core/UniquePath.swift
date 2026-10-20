import Foundation

enum UniquePath {
    /// Returns the given URL if nothing exists at that path, otherwise appends
    /// " 2", " 3", etc. before the extension until an unused name is found.
    static func make(_ url: URL) -> URL {
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) { return url }
        let base = url.deletingPathExtension().lastPathComponent
        let ext  = url.pathExtension
        let dir  = url.deletingLastPathComponent()
        var n = 2
        while true {
            let candidate = dir
                .appendingPathComponent("\(base) \(n)")
                .appendingPathExtension(ext)
            if !fm.fileExists(atPath: candidate.path) { return candidate }
            n += 1
            if n > 9999 { return candidate }
        }
    }
}
