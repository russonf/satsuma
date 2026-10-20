import SwiftUI

struct SettingsRoot: View {
    var body: some View {
        TabView {
            GeneralTab().tabItem { Label("General", systemImage: "gear") }
            FormatsTab().tabItem { Label("Formats", systemImage: "doc.on.doc") }
            CompatibilityTab().tabItem { Label("Compatibility", systemImage: "arrow.left.arrow.right") }
            FoldersTab().tabItem { Label("Folders", systemImage: "folder") }
            AboutTab().tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 480, height: 560)
    }
}
