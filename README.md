# Satsuma 🍊

A free, native macOS menu-bar app. **Drag any file**, hold a **modifier key** mid-drag, and a radial wheel appears at the cursor. Release on a segment to run the action.

| Modifier | Wheel | Segments |
|---|---|---|
| **Shift** | Conversion | JPG · PNG · WEBP · HEIC · TIFF · AVIF · BMP · PDF |
| **Command** | Tools | AirDrop · Float · Copy · Move · Copy Path · Terminal |
| **Control** | Actions | Compress · Metadata · Edit · Annotate · Add BG · Crop · Redact |

Modifier assignments and output formats are configurable in Settings.

## Build

Requires macOS 14+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
xcodegen generate
open Satsuma.xcodeproj
```

Build & run from Xcode (⌘R).

## First-run permissions

Satsuma needs two macOS privacy grants:

1. **Accessibility** — to watch for modifier keys during a drag. System Settings → Privacy & Security → Accessibility → add Satsuma.
2. **Full Disk Access** — to read and write files outside the sandbox. System Settings → Privacy & Security → Full Disk Access → add Satsuma.

The app will prompt for Accessibility automatically on first launch.

## How the conversions work

- **Image conversion** uses `ImageIO` (JPG, PNG, WEBP, HEIC, TIFF, AVIF, BMP) and `PDFKit` (image → PDF).
- **Document conversion** uses `textutil` under the hood (RTF, HTML, DOCX, TXT).
- **Compress** uses `ditto` to make a `.zip` beside the original.
- **Metadata** opens a window of file attributes + ImageIO properties (EXIF).
- **Edit / Annotate / Crop / Redact / Add BG** open the file in **Preview** with its Markup toolbar — a solid v1 before we ship first-party editors.
- **Float** opens a floating HUD panel that keeps files handy for later dragging.

## License

MIT. Use it, fork it, give it to friends.
