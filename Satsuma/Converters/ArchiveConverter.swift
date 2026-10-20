import Foundation

enum ArchiveFormat: String { case zip, tar, gz, tgz }

enum ArchiveConverter {
    static func create(urls: [URL], format: ArchiveFormat) {
        guard let first = urls.first else { return }
        let base = first.deletingPathExtension().lastPathComponent
        let dir  = first.deletingLastPathComponent()
        let dest = UniquePath.make(dir.appendingPathComponent("\(base).\(format.rawValue)"))

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try perform(urls: urls, format: format, dest: dest)
                Toast.shared.show("Archived → \(dest.lastPathComponent)", resultURL: dest)
            } catch {
                Toast.shared.show("Archive failed: \(error.localizedDescription)", symbol: "xmark.octagon.fill")
            }
        }
    }

    private static func perform(urls: [URL], format: ArchiveFormat, dest: URL) throws {
        let proc = Process()
        switch format {
        case .zip:
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
            var args = ["-c", "-k", "--sequesterRsrc", "--keepParent"]
            args.append(contentsOf: urls.map(\.path))
            args.append(dest.path)
            proc.arguments = args
        case .tar:
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
            proc.arguments = ["-cf", dest.path] + urls.map(\.lastPathComponent)
            proc.currentDirectoryURL = urls.first?.deletingLastPathComponent()
        case .tgz:
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
            proc.arguments = ["-czf", dest.path] + urls.map(\.lastPathComponent)
            proc.currentDirectoryURL = urls.first?.deletingLastPathComponent()
        case .gz:
            FileManager.default.createFile(atPath: dest.path, contents: nil)
            let out = try FileHandle(forWritingTo: dest)
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/gzip")
            proc.arguments = ["-kc", urls[0].path]
            proc.standardOutput = out
        }
        try proc.run()
        proc.waitUntilExit()
        if proc.terminationStatus != 0 {
            throw NSError(domain: "Satsuma", code: Int(proc.terminationStatus),
                          userInfo: [NSLocalizedDescriptionKey: "exit \(proc.terminationStatus)"])
        }
    }
}
