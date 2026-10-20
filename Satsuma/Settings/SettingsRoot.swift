import SwiftUI

struct SettingsRoot: View {
    var body: some View {
        TabView {
            GeneralTab().tabItem { Label("General", systemImage: "gear") }
            FormatsTab().tabItem { Label("Formats", systemImage: "doc.on.doc") }
            CompatibilityTab().tabItem { Label("Compatibility", systemImage: "arrow.left.arrow.right") }
            RecipesTab().tabItem { Label("Recipes", systemImage: "wand.and.stars") }
            FoldersTab().tabItem { Label("Folders", systemImage: "folder") }
            AboutTab().tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(minWidth: 600, idealWidth: 720, minHeight: 500, idealHeight: 600)
        .satsumaBackground()
    }
}
