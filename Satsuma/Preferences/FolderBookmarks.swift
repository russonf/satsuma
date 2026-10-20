import Foundation
import AppKit

/// Persists security-scoped bookmarks for folders the user has given access to.
/// Resolves them on demand and starts/stops access when needed.
final class FolderBookmarks: ObservableObject {
    static let shared = FolderBookmarks()
    private let key = "folders.bookmarks.v1"

    @Published private(set) var folders: [Entry] = []

    struct Entry: Identifiable, Equatable {
        let id = UUID()
        let url: URL
        let bookmark: Data
    }

    init() { load() }

    func add(url: URL) {
        guard let data = try? url.bookmarkData(options: [.withSecurityScope],
                                               includingResourceValuesForKeys: nil,
                                               relativeTo: nil) else { return }
        folders.append(Entry(url: url, bookmark: data))
        save()
    }

    func remove(_ entry: Entry) {
        folders.removeAll { $0.id == entry.id }
        save()
    }

    /// Call before touching a file under one of these folders; call stop when done.
    func startAccess(_ entry: Entry) -> URL? {
        var stale = false
        guard let url = try? URL(resolvingBookmarkData: entry.bookmark,
                                 options: [.withSecurityScope],
                                 relativeTo: nil,
                                 bookmarkDataIsStale: &stale) else { return nil }
        return url.startAccessingSecurityScopedResource() ? url : nil
    }
    func stopAccess(_ url: URL) { url.stopAccessingSecurityScopedResource() }

    // MARK: persistence

    private func save() {
        let payload = folders.map { ["path": $0.url.path, "bookmark": $0.bookmark] as [String: Any] }
        UserDefaults.standard.set(payload, forKey: key)
    }

    private func load() {
        guard let arr = UserDefaults.standard.array(forKey: key) as? [[String: Any]] else { return }
        folders = arr.compactMap { d in
            guard let path = d["path"] as? String, let data = d["bookmark"] as? Data else { return nil }
            return Entry(url: URL(fileURLWithPath: path), bookmark: data)
        }
    }
}
