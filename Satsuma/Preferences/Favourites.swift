import Foundation

enum Favourites {
    private static let key = "favourites.moveDestinations"
    private static let maxCount = 3

    static var destinations: [URL] {
        get {
            let paths = UserDefaults.standard.stringArray(forKey: key) ?? []
            return paths.compactMap { URL(fileURLWithPath: $0, isDirectory: true) }
        }
        set {
            let paths = Array(newValue.prefix(maxCount)).map(\.path)
            UserDefaults.standard.set(paths, forKey: key)
        }
    }

    static func add(_ url: URL) {
        var current = destinations.filter { $0 != url }
        current.insert(url, at: 0)
        destinations = current
    }

    static func remove(at index: Int) {
        var current = destinations
        guard current.indices.contains(index) else { return }
        current.remove(at: index)
        destinations = current
    }
}
