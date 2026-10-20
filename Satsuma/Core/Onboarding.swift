import AppKit
import SwiftUI

enum Onboarding {
    private static let doneKey = "onboarding.v1.done"

    static func showIfNeeded() {
        if UserDefaults.standard.bool(forKey: doneKey) { return }
        present()
    }

    static func present() {
        let host = NSHostingController(rootView: OnboardingView(onDone: {
            UserDefaults.standard.set(true, forKey: doneKey)
            NSApp.keyWindow?.close()
        }))
        let w = NSWindow(contentViewController: host)
        w.title = "Welcome to Satsuma"
        w.setContentSize(NSSize(width: 560, height: 460))
        w.styleMask.insert(.fullSizeContentView)
        w.titlebarAppearsTransparent = true
        w.isMovableByWindowBackground = true
        w.center()
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

private struct OnboardingView: View {
    @State private var step = 0
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $step) {
                WelcomePane().tag(0)
                GesturePane().tag(1)
                PermissionsPane().tag(2)
            }
            .tabViewStyle(.automatic)

            Divider()
            HStack {
                if step > 0 {
                    Button("Back") { step -= 1 }
                }
                Spacer()
                PageDots(count: 3, active: step)
                Spacer()
                if step < 2 {
                    Button(step == 1 ? "Set up permissions" : "Next") { step += 1 }
                        .keyboardShortcut(.defaultAction)
                } else {
                    Button("Done") { onDone() }
                        .keyboardShortcut(.defaultAction)
                }
            }.padding(16)
        }
        .frame(width: 560, height: 460)
        .background(.ultraThinMaterial)
    }
}

private struct WelcomePane: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color(red: 1, green: 0.6, blue: 0.2))
                .padding(.top, 40)
            Text("Satsuma").font(.largeTitle).bold()
            Text("Drag any file. Hold a modifier. Pick an action.")
                .font(.title3).foregroundStyle(.secondary)
            Text("Satsuma lives in the menu bar. There's no window — the wheel appears at your cursor the moment you need it.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40).padding(.top, 8)
            Spacer()
        }
    }
}

private struct GesturePane: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How the gesture works").font(.title2).bold().padding(.top, 24)
            Row(key: "1.", text: "Start dragging a file from Finder.")
            Row(key: "2.", text: "While still holding the mouse button, press a modifier key:")
            VStack(alignment: .leading, spacing: 10) {
                Mod(key: "⇧ Shift",    label: "Conversion — JPG, PNG, MP4, ZIP…")
                Mod(key: "⌘ Command",  label: "Tools — AirDrop, Copy, Move, Terminal…")
                Mod(key: "⌃ Control",  label: "Actions — Compress, Crop, Redact, Annotate…")
                Mod(key: "⌥ Option",   label: "More — OCR, Hash, Rename, Share, iCloud…")
            }.padding(.leading, 24)
            Row(key: "3.", text: "Release on a segment to run the action. Press Esc to cancel.")
            Spacer()
        }.padding(.horizontal, 32)
    }
    private struct Row: View {
        let key: String; let text: String
        var body: some View {
            HStack(alignment: .top, spacing: 10) {
                Text(key).bold().frame(width: 24, alignment: .leading)
                Text(text)
            }
        }
    }
    private struct Mod: View {
        let key: String; let label: String
        var body: some View {
            HStack(spacing: 10) {
                Text(key).font(.system(.body, design: .monospaced)).bold()
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(Capsule().fill(Color.secondary.opacity(0.15)))
                Text(label).foregroundStyle(.secondary)
            }
        }
    }
}

private struct PermissionsPane: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Grant two permissions").font(.title2).bold().padding(.top, 24)
            Text("Satsuma needs these to work. You can always change them in System Settings → Privacy & Security.")
                .foregroundStyle(.secondary)

            PermCard(icon: "accessibility", title: "Accessibility",
                     subtitle: "Lets Satsuma detect modifier keys during a drag. Add Satsuma to the list and tick it on.") {
                // Trigger the one-time system prompt (no-op if already decided)
                PermissionsCheck.ensureAccessibility()
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
            PermCard(icon: "externaldrive", title: "Full Disk Access",
                     subtitle: "Lets Satsuma read and write files in protected folders. Click + in the list, press ⇧⌘G, paste the path below, then tick Satsuma on.") {
                // Nudge the system to register Satsuma by attempting a protected read.
                _ = try? Data(contentsOf: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Mail"))
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
                    NSWorkspace.shared.open(url)
                }
            }
            // Dev-build helper: FDA's + button needs the exact binary path. Shows
            // where the app currently lives (DerivedData when run from Xcode;
            // /Applications once installed).
            let path = Bundle.main.bundleURL.path.removingPercentEncoding ?? Bundle.main.bundleURL.path
            VStack(alignment: .leading, spacing: 4) {
                Text("Current app location")
                    .font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Text(path)
                        .font(.system(.caption, design: .monospaced))
                        .lineLimit(1).truncationMode(.middle)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 6).fill(.quaternary))
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(path, forType: .string)
                    } label: { Image(systemName: "doc.on.doc") }
                        .help("Copy app path")
                }
            }
            Spacer()
        }.padding(.horizontal, 32)
    }
    private struct PermCard: View {
        let icon: String; let title: String; let subtitle: String; let action: () -> Void
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon).font(.title2).foregroundStyle(.tint).frame(width: 32)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).bold()
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button("Open System Settings", action: action)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(.quaternary))
        }
    }
}

private struct PageDots: View {
    let count: Int; let active: Int
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { i in
                Circle().fill(i == active ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 7, height: 7)
            }
        }
    }
}
