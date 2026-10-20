import SwiftUI
import AppKit

struct FoldersTab: View {
    @AppStorage("folders.bookmarks") private var bookmarkData: Data = Data()
    @State private var folders: [URL] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Folder Access").font(.headline)
            Text("Satsuma saves results beside the originals. macOS asks you to allow each output folder once. Allowing a parent folder, such as your home folder, also covers every folder inside it.")
                .font(.caption).foregroundStyle(.secondary)

            GroupBox {
                if folders.isEmpty {
                    Text("No folders allowed yet.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(folders, id: \.self) { Text($0.path) }
                }
                HStack {
                    Spacer()
                    Button("Add Folder…") { pickFolder() }
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
        if panel.runModal() == .OK, let url = panel.url {
            folders.append(url)
        }
    }
}
