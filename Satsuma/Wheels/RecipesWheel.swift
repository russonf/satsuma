import SwiftUI

struct RecipesWheel: View {
    @ObservedObject var store = RecipesStore.shared

    var body: some View {
        if store.recipes.isEmpty {
            emptyState
        } else {
            RadialMenu(segments: store.recipes.prefix(8).map { recipe in
                WheelSegment(label: recipe.name.uppercased(), systemImage: recipe.symbol) { _ in
                    RecipesStore.shared.run(recipe)
                }
            })
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 36))
                .foregroundStyle(Color(red: 1, green: 0.6, blue: 0.2))
            Text("No recipes yet").font(.headline)
            Text("Settings → Recipes to create one")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(32)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white))
        .shadow(radius: 12)
        .frame(width: 260, height: 180)
    }
}
