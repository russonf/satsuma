import SwiftUI
import AppKit

struct FoldersTab: View {
    @ObservedObject private var store = FolderBookmarks.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Folder Access").font(.headline)
            Text("Add folders you want Satsuma to always have access to — Satsuma stores a macOS security-scoped bookmark so it still works after a reboot. Adding a parent folder covers everything inside.")
                .font(.caption).foregroundStyle(.secondary)

            GroupBox {
                if store.folders.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "folder.badge.plus").font(.title)
                            .foregroundStyle(.secondary)
                        Text("No folders added yet.")
                            .foregroundStyle(.secondary).font(.caption)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.folders) { entry in
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundStyle(Color(red: 0.95, green: 0.52, blue: 0.17))
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(entry.url.lastPathComponent).fontWeight(.medium)
                                    Text(entry.url.path).font(.caption)
                                        .foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                                }
                                Spacer()
                                Button(role: .destructive) { store.remove(entry) }
                                label: { Image(systemName: "trash") }
                                    .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .frame(minHeight: 140)
                }
                HStack {
                    Spacer()
                    Button("Add Folder…") { pickFolder() }
                        .buttonStyle(.borderedProminent)
                }
            }
            Spacer()
        }.padding()
    }

    private func pickFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Grant Satsuma access to this folder"
        if panel.runModal() == .OK, let url = panel.url {
            FolderBookmarks.shared.add(url: url)
        }
    }
}
