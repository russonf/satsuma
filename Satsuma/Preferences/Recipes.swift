import Foundation
import Combine

enum RecipeStep: String, Codable, CaseIterable, Identifiable {
    // Conversion
    case toJPG, toPNG, toWEBP, toHEIC, toTIFF, toAVIF, toBMP, toPDF
    case toMP4, toMOV
    case toM4A, toWAV
    // Tools
    case airdrop, copyFile, copyPath, move, openInTerminal, float
    // Actions
    case compress, metadata, zip, tar, tgz
    // More
    case ocr, hash, rename, share, iCloud, reveal

    var id: String { rawValue }

    var label: String {
        switch self {
        case .toJPG: return "Convert → JPG"
        case .toPNG: return "Convert → PNG"
        case .toWEBP: return "Convert → WEBP"
        case .toHEIC: return "Convert → HEIC"
        case .toTIFF: return "Convert → TIFF"
        case .toAVIF: return "Convert → AVIF"
        case .toBMP:  return "Convert → BMP"
        case .toPDF:  return "Convert → PDF"
        case .toMP4:  return "Convert → MP4"
        case .toMOV:  return "Convert → MOV"
        case .toM4A:  return "Convert → M4A"
        case .toWAV:  return "Convert → WAV"
        case .airdrop: return "AirDrop"
        case .copyFile: return "Copy file"
        case .copyPath: return "Copy path"
        case .move: return "Move…"
        case .openInTerminal: return "Open in Terminal"
        case .float: return "Add to Float"
        case .compress: return "Compress"
        case .metadata: return "Show metadata"
        case .zip: return "Archive → ZIP"
        case .tar: return "Archive → TAR"
        case .tgz: return "Archive → TGZ"
        case .ocr: return "OCR → clipboard"
        case .hash: return "SHA-256 → clipboard"
        case .rename: return "Rename…"
        case .share: return "Share…"
        case .iCloud: return "Copy to iCloud"
        case .reveal: return "Reveal in Finder"
        }
    }

    func run() {
        let urls = OverlayState.shared.currentURLs
        switch self {
        case .toJPG:  ImageConverter.convert(urls: urls, to: .jpg)
        case .toPNG:  ImageConverter.convert(urls: urls, to: .png)
        case .toWEBP: ImageConverter.convert(urls: urls, to: .webp)
        case .toHEIC: ImageConverter.convert(urls: urls, to: .heic)
        case .toTIFF: ImageConverter.convert(urls: urls, to: .tiff)
        case .toAVIF: ImageConverter.convert(urls: urls, to: .avif)
        case .toBMP:  ImageConverter.convert(urls: urls, to: .bmp)
        case .toPDF:  ImageConverter.convert(urls: urls, to: .pdf)
        case .toMP4:  VideoConverter.convert(urls: urls, to: .mp4)
        case .toMOV:  VideoConverter.convert(urls: urls, to: .mov)
        case .toM4A:  AudioConverter.convert(urls: urls, to: .m4a)
        case .toWAV:  AudioConverter.convert(urls: urls, to: .wav)
        case .airdrop: ToolActions.airdrop()
        case .copyFile: ToolActions.copyFile()
        case .copyPath: ToolActions.copyPath()
        case .move: ToolActions.move()
        case .openInTerminal: ToolActions.openInTerminal()
        case .float: ToolActions.float()
        case .compress: FileActions.compress()
        case .metadata: FileActions.metadata()
        case .zip: ArchiveConverter.create(urls: urls, format: .zip)
        case .tar: ArchiveConverter.create(urls: urls, format: .tar)
        case .tgz: ArchiveConverter.create(urls: urls, format: .tgz)
        case .ocr: MoreActions.ocr()
        case .hash: MoreActions.hash()
        case .rename: MoreActions.rename()
        case .share: MoreActions.share()
        case .iCloud: MoreActions.iCloud()
        case .reveal: MoreActions.reveal()
        }
    }
}

struct Recipe: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var symbol: String = "wand.and.stars"
    var steps: [RecipeStep]
}

final class RecipesStore: ObservableObject {
    static let shared = RecipesStore()
    private let key = "recipes.v1"
    @Published var recipes: [Recipe] = []

    init() { load() }

    func add(_ recipe: Recipe) { recipes.append(recipe); save() }
    func update(_ recipe: Recipe) {
        if let i = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[i] = recipe; save()
        }
    }
    func delete(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }; save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Recipe].self, from: data) else { return }
        recipes = decoded
    }

    /// Run a recipe's steps in order on the current OverlayState selection.
    /// Steps are fire-and-forget; async steps may overlap.
    func run(_ recipe: Recipe) {
        for step in recipe.steps {
            step.run()
        }
        Toast.shared.show("Ran recipe: \(recipe.name)", symbol: "wand.and.stars")
    }
}
