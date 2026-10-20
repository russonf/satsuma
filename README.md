# Satsuma 🍊

A free, native macOS menu-bar app for fast file operations. Drag any file, hold a modifier, and a radial wheel appears at the cursor. Release on a segment to run the action — on one file or many.

Runs in the background with no Dock icon. Status item: an orange hexagon grid in the menu bar.

**Why Satsuma over the alternatives:** free, open-source, zero telemetry, zero network calls, forkable under MIT. Build-from-source auditable in under an hour.

**Inspired by** [Tangerine for Mac](https://tangerineformac.com) — a paid, closed-source app on the Mac App Store that invented this gesture. Satsuma is an independent, open-source reimplementation. If you want polish, docs, and paid support, buy Tangerine. If you want free, hackable, and auditable, Satsuma is for you.

*(Screenshots coming in v0.1.1 — captured from the real Satsuma UI, not from Tangerine.)*

---

## The core gesture

1. Start dragging one or more files from Finder (or any app that exposes file URLs).
2. While still holding the mouse button, press a **modifier key**.
3. A wheel of segments appears at the cursor and stays pinned there.
4. Move the cursor to a segment (it highlights). Release.
5. The action runs on the dragged file(s). A notification confirms.

Change your mind mid-drag? Just press a different modifier — the wheel swaps. Release outside any segment to cancel.

---

## The four wheels

### Shift — Conversion wheel

**Context-sensitive.** The segments change based on what you're dragging.

| If you drag... | You see | Notes |
|---|---|---|
| An image | JPG · PNG · WEBP · HEIC · TIFF · AVIF · BMP · PDF | ImageIO under the hood. PDF via PDFKit. |
| A video | MP4 · MOV · M4V · WEBM | AVFoundation. WEBM is not native — shows a "not supported" notification. |
| An audio file | M4A · WAV · AAC · AIFF · MP3 · FLAC | AVFoundation. MP3 and FLAC are not native — show "not supported" notification. |
| A folder, or multiple files | ZIP · TAR · TGZ · GZ | Shells out to `ditto`, `tar`, `gzip`. |

Each output is written **beside the original** with the new extension. Images follow the per-format quality + metadata settings in Settings → Formats.

### Command — Tools wheel

- **AIRDROP** — opens the AirDrop sheet with the file(s).
- **FLOAT** — stashes the file(s) in a floating HUD panel for later dragging. Settings control whether this creates a new float or adds to the last one.
- **COPY** — puts the file(s) on the system clipboard (`cmd+V` in Finder or any app).
- **MOVE** — opens a folder picker; moves the file(s) there.
- **COPY PATH** — copies the file path(s) to the clipboard as text. Multi-file = newline-separated.
- **TERMINAL** — opens the parent folder in your terminal. Settings → General → Terminal app picks Terminal / iTerm / Ghostty.

### Control — Actions wheel

- **COMPRESS** — zips the file(s) beside the original. (Identical to the context-sensitive ZIP segment for folders.)
- **METADATA** — opens a window showing filesystem attributes + ImageIO properties (EXIF, GPS, camera, etc.).
- **EDIT** — opens the file in Preview.
- **ANNOTATE** — opens a Satsuma annotation window (pen tool with colour + width, text labels placed on tap). Save → writes `name.annotated.png` beside the original.
- **ADD BG** — opens in Preview with Markup. First-party BG replacement is on the roadmap.
- **CROP** — opens a Satsuma crop window. Drag to select, click Save Crop → writes `name.cropped.png` beside the original.
- **REDACT** — opens a Satsuma redact window. Drag rectangles over anything to paint them solid black. Save → writes `name.redacted.png` beside the original.

### Shift + Option — Recipes wheel

**Chain actions together.** Create recipes in Settings → Recipes, each one a sequence of steps (e.g. *Convert → JPG · AirDrop*). Hold **Shift + Option** while dragging and your recipes appear as segments. Drop on one → every step runs in order against the dragged file(s).

Up to 8 recipes show on the wheel. If you have more, trim or reorder in Settings.

### Option — More wheel

- **OCR** — recognises text in the image (Apple Vision), copies the result to the clipboard.
- **HASH** — SHA-256 of the file bytes, copied to the clipboard as hex.
- **RENAME** — prompts for a new base name; keeps the extension; renames in place.
- **SHARE** — opens the macOS share sheet with the file(s) selected.
- **ICLOUD** — copies the file(s) to iCloud Drive (`~/Library/Mobile Documents/com~apple~CloudDocs/`).
- **REVEAL** — reveals the file(s) in Finder.

---

## Multi-file support

Drag any number of files. The centre bubble shows `3 · 12.4 MB` (count · total size). Actions apply to all:

- Convert → each file is converted individually.
- AirDrop / Share → the sheet opens with all files.
- Copy / Move → all files handled.
- Rename / Crop / Redact / Annotate / OCR / Hash → operate on the **first** file only (these are single-file by nature). Everything else is batch.

---

## Settings

Opens from the menu-bar menu → Settings…

### General
- **Appearance** — Glass / Solid (cosmetic placeholder for now).
- **Launch at login** — registers Satsuma with macOS so it starts automatically. Uses `SMAppService`.
- **Sound and haptic feedback** — toggles the pop sound + haptic buzz when a notification appears.
- **Drag Modifiers** — remap each wheel to any of Shift / Command / Control / Option.
- **Float behaviour** — "Create a New Float" opens a new float window per drop; "Add to Existing Float" appends to the last one.
- **Terminal app** — Terminal / iTerm / Ghostty.

### Formats
Per-format quality and metadata controls. Settings apply at convert time.

- **Quality** — High / Balanced / Strong (small). Only affects lossy formats (JPG, WEBP, HEIC, AVIF).
- **Preserve metadata** — keep or strip EXIF / GPS when converting.

### Compatibility
Reference matrix of which input formats can convert to which output formats.

### Folders
Add parent folders for file access. (Satsuma runs non-sandboxed so this is for your convenience; macOS will prompt for Desktop/Documents/Downloads on first touch anyway.)

### About
Version, license, and the satsuma.

---

## Floating HUD panel ("Float")

When you drop on **FLOAT**, the file is parked in a floating window with its icon and name. You can drag items out of it to any app or Finder. The window stays on top across spaces.

---

## First-run permissions

1. **Accessibility** — needed to detect modifier keys globally. The app prompts on launch. If you miss it: System Settings → Privacy & Security → Accessibility → add Satsuma.
2. **Full Disk Access** — needed to read/write files outside sandboxed scopes. System Settings → Privacy & Security → Full Disk Access → add Satsuma.

Without these, drag detection may miss some drags and conversions may fail silently in protected folders.

---

## Feedback

Every finished action shows a notification in the top-right of the main screen:
- `3/3 files → JPG` on batch convert
- `SHA-256 → clipboard` on hash
- `Export failed: <reason>` on failure

Sound and haptic can be turned off in Settings → General.

## Drag OUT — grabbing the result from a notification

When a conversion produces a new file (image, video, audio, archive, document), the success notification includes a small **icon of the result** on the right. You can **drag that icon** straight from the notification into any other app:

- **Finder** — drop it in a folder to put a copy there.
- **Slack / Discord / Teams / WhatsApp** — drop it into the message input to attach the file.
- **Mail / Outlook** — drop it into a draft to attach.
- **Safari / Chrome** — drop onto an upload field or a web app that accepts file drops.
- **Preview / Photoshop / Final Cut** — drop into the dock icon or an open document.

The notification stays visible for ~5 seconds (vs 1.8 s for status-only notifications) so you have time to grab it. If you need longer, click into the notification first — the drag source remains the result file until the next successful conversion overwrites it.

What's dragged is the **newly produced file on disk**, not a copy — the target app receives the real file URL. Drop into Finder with ⌥ to copy instead of move, same as any Finder drag.

Supported in all converters: Image, Video, Audio, Archive, Document. Not supported in actions that don't produce a new file (e.g. Rename, OCR → clipboard, Hash → clipboard, Share, AirDrop) — those actions don't need a drag source.

---

## Known limitations (honest list)

- **MP3 and FLAC encoding** are not available via AVFoundation. We show a notification instead of silently failing. A later version may bundle `ffmpeg`.
- **WEBM encoding** — same story.
- **SVG, PAGES, PPT, PPTX, DOCX** aren't yet routed through the Conversion wheel — only via the `textutil` wrapper in `DocumentConverter.swift` (not yet surfaced in UI).
- **Chain actions / Watched folder / History** — on the pre-launch roadmap, not shipped.
- Drag detection is a heuristic (watches the drag pasteboard + mouse-button state). There is no public global drag-session API on macOS. If a drag feels missed, release and try again.
- **Add BG** currently hands off to Preview Markup. First-party is on the roadmap.

---

## Install

**Easy way:** download the latest `Satsuma.dmg` from [Releases](https://github.com/russonf/satsuma/releases/latest), open it, drag `Satsuma.app` to `/Applications`.

**First launch:** macOS Gatekeeper will say *"Satsuma cannot be opened because Apple cannot check it for malicious software."* This is normal for free, unsigned apps. Two ways around it:

1. In Finder, **right-click Satsuma.app → Open** → confirm. You only need to do this once.
2. Or, in Terminal: `xattr -dr com.apple.quarantine /Applications/Satsuma.app`

After that, Satsuma opens normally. The orange hexagon appears in your menu bar.

## Build from source

Requires macOS 14+, Xcode 15+, and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
git clone https://github.com/russonf/satsuma.git
cd satsuma
xcodegen generate
open Satsuma.xcodeproj
```

Build & run with ⌘R.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Short version: fork, branch, PR against `main`.

---

## Roadmap

Shipping toward feature parity with Tangerine's "275 conversion options + 26 advanced tools":

- **Images** — SVG as source and destination; ICO; AVIF/JPEG XL quality dials; batch resize profiles
- **Documents** — Pages / Keynote / Numbers export, PDF → images, DOCX ↔ PDF with layout preservation, XLSX, EPUB, Markdown parser (currently .md is passthrough from .txt)
- **Video** — WEBM / MKV via bundled ffmpeg; trim; resolution / framerate presets; GIF export
- **Audio** — MP3 / FLAC via bundled ffmpeg; trim; normalize; bitrate presets
- **Archives** — 7z, RAR extraction; archive inspector; nested extract
- **Advanced tools** — background removal (Vision), batch rename patterns, EXIF stripper, duplicate finder, folder → image montage, PDF merge / split / rotate / reorder, OCR → PDF text layer

Fork the repo and claim one — [CONTRIBUTING.md](CONTRIBUTING.md) walks through the flow.

## License

MIT. Fork it, ship your own, give it away.

## Credits

Original gesture and feature concept by [Tangerine for Mac](https://tangerineformac.com). Independent reimplementation by [@russonf](https://github.com/russonf), built in collaboration with Claude. No Tangerine assets, code, or trademarks used.
