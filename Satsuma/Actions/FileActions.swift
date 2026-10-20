import Foundation
import AppKit

enum FileActions {
    private static var urls: [URL] { OverlayState.shared.currentURLs }

    static func compress() { ArchiveConverter.create(urls: urls, format: .zip) }
    static func zip()      { ArchiveConverter.create(urls: urls, format: .zip) }
    static func tar()      { ArchiveConverter.create(urls: urls, format: .tar) }
    static func tgz()      { ArchiveConverter.create(urls: urls, format: .tgz) }

    static func metadata() {
        guard let u = urls.first else { return }
        DispatchQueue.main.async { MetadataWindow.show(for: u) }
    }

    static func edit() {
        guard let u = urls.first else { return }
        DispatchQueue.main.async {
            let preview = URL(fileURLWithPath: "/System/Applications/Preview.app")
            NSWorkspace.shared.open([u], withApplicationAt: preview, configuration: NSWorkspace.OpenConfiguration())
        }
    }

    static func crop()     { if let u = urls.first { DispatchQueue.main.async { CropWindow.show(for: u) } } }
    static func redact()   { if let u = urls.first { DispatchQueue.main.async { RedactWindow.show(for: u) } } }
    static func annotate() { if let u = urls.first { DispatchQueue.main.async { AnnotateWindow.show(for: u) } } }

    static func addBackground() {
        if let u = urls.first { DispatchQueue.main.async { AddBackgroundWindow.show(for: u) } }
    }

    static func resize() {
        if let u = urls.first { DispatchQueue.main.async { ResizeWindow.show(for: u) } }
    }
}
