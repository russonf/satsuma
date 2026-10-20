import Foundation
import AppKit
import Vision
import CryptoKit
import SwiftUI

enum MoreActions {
    private static var urls: [URL] { OverlayState.shared.currentURLs }

    static func ocr() {
        guard let url = urls.first else { return }
        guard let image = CIImage(contentsOf: url) else {
            Toast.shared.show("OCR: not an image", symbol: "exclamationmark.triangle.fill"); return
        }
        let request = VNRecognizeTextRequest { req, _ in
            let text = (req.results as? [VNRecognizedTextObservation] ?? [])
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
            DispatchQueue.main.async {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
                Toast.shared.show("OCR → clipboard (\(text.count) chars)")
            }
        }
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(ciImage: image)
        try? handler.perform([request])
    }

    static func hash() {
        guard let url = urls.first else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else {
                Toast.shared.show("Hash failed", symbol: "xmark.octagon.fill"); return
            }
            let digest = SHA256.hash(data: data)
            let hex = digest.map { String(format: "%02x", $0) }.joined()
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(hex, forType: .string)
            Toast.shared.show("SHA-256 → clipboard")
        }
    }

    static func rename() {
        guard let url = urls.first else { return }
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Rename file"
            alert.informativeText = url.lastPathComponent
            let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
            input.stringValue = url.deletingPathExtension().lastPathComponent
            alert.accessoryView = input
            alert.addButton(withTitle: "Rename")
            alert.addButton(withTitle: "Cancel")
            if alert.runModal() == .alertFirstButtonReturn {
                let newName = input.stringValue.isEmpty ? url.deletingPathExtension().lastPathComponent : input.stringValue
                let dest = url.deletingLastPathComponent()
                    .appendingPathComponent(newName)
                    .appendingPathExtension(url.pathExtension)
                try? FileManager.default.moveItem(at: url, to: dest)
                Toast.shared.show("Renamed → \(dest.lastPathComponent)")
            }
        }
    }

    static func share() {
        guard !urls.isEmpty else { return }
        DispatchQueue.main.async {
            let picker = NSSharingServicePicker(items: urls)
            if let screen = NSScreen.main {
                let rect = NSRect(x: screen.frame.midX - 50, y: screen.frame.midY - 50, width: 100, height: 100)
                let anchor = NSView(frame: rect)
                picker.show(relativeTo: anchor.bounds, of: anchor, preferredEdge: .minY)
            }
        }
    }

    static func reveal() {
        guard !urls.isEmpty else { return }
        DispatchQueue.main.async {
            NSWorkspace.shared.activateFileViewerSelecting(urls)
        }
    }

    static func iCloud() {
        guard !urls.isEmpty else { return }
        let fm = FileManager.default
        guard let iCloudBase = fm.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
                ?? fm.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
                as URL? else {
            Toast.shared.show("iCloud Drive not available", symbol: "exclamationmark.triangle.fill"); return
        }
        DispatchQueue.global().async {
            var ok = 0
            for u in urls {
                let dest = iCloudBase.appendingPathComponent(u.lastPathComponent)
                do { try fm.copyItem(at: u, to: dest); ok += 1 } catch { NSLog("iCloud copy failed: \(error)") }
            }
            Toast.shared.show("\(ok)/\(urls.count) → iCloud Drive")
        }
    }
}
