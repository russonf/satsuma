import SwiftUI

struct RecipesTab: View {
    @ObservedObject var store = RecipesStore.shared
    @State private var editing: Recipe?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recipes").font(.headline)
                Spacer()
                Button {
                    editing = Recipe(name: "New Recipe", steps: [])
                } label: { Label("New", systemImage: "plus") }
            }
            Text("Chain actions together. Access with ⇧⌥ while dragging. Steps run top to bottom.")
                .font(.caption).foregroundStyle(.secondary)

            GroupBox {
                if store.recipes.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "wand.and.stars").font(.title).foregroundStyle(.secondary)
                        Text("No recipes yet").foregroundStyle(.secondary).font(.caption)
                    }.frame(maxWidth: .infinity, minHeight: 120)
                } else {
                    List {
                        ForEach(store.recipes) { r in
                            HStack {
                                Image(systemName: r.symbol)
                                    .foregroundStyle(Color(red: 1, green: 0.6, blue: 0.2))
                                VStack(alignment: .leading) {
                                    Text(r.name).fontWeight(.medium)
                                    Text(r.steps.map(\.label).joined(separator: " → "))
                                        .font(.caption).foregroundStyle(.secondary)
                                        .lineLimit(1).truncationMode(.tail)
                                }
                                Spacer()
                                Button("Edit") { editing = r }
                                Button(role: .destructive) { store.delete(r) }
                                label: { Image(systemName: "trash") }
                                    .buttonStyle(.borderless)
                            }
                        }
                    }.frame(minHeight: 180)
                }
            }
            Spacer()
        }
        .padding()
        .sheet(item: $editing) { recipe in
            RecipeEditor(recipe: recipe) { updated in
                if store.recipes.contains(where: { $0.id == updated.id }) {
                    store.update(updated)
                } else {
                    store.add(updated)
                }
                editing = nil
            } onCancel: { editing = nil }
        }
    }
}

private struct RecipeEditor: View {
    @State var recipe: Recipe
    let onSave: (Recipe) -> Void
    let onCancel: () -> Void

    @State private var pickingStep = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Name", text: $recipe.name)
                    .textFieldStyle(.roundedBorder)
                Picker("Icon", selection: $recipe.symbol) {
                    ForEach(["wand.and.stars", "sparkles", "paperplane", "square.and.arrow.up", "archivebox", "camera.aperture", "scissors", "arrow.triangle.2.circlepath"], id: \.self) { s in
                        Image(systemName: s).tag(s)
                    }
                }.frame(width: 90)
            }.padding(12)

            Divider()

            List {
                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { idx, step in
                    HStack {
                        Text("\(idx + 1).").foregroundStyle(.secondary).frame(width: 24)
                        Text(step.label)
                        Spacer()
                        Button(role: .destructive) {
                            recipe.steps.remove(at: idx)
                        } label: { Image(systemName: "minus.circle") }
                            .buttonStyle(.borderless)
                    }
                }
                .onMove { from, to in recipe.steps.move(fromOffsets: from, toOffset: to) }
            }
            .frame(minHeight: 240)

            Divider()

            HStack {
                Button {
                    pickingStep = true
                } label: { Label("Add step", systemImage: "plus.circle.fill") }
                    .popover(isPresented: $pickingStep) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Pick a step").font(.headline).padding(10)
                            Divider()
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(RecipeStep.allCases) { step in
                                        Button {
                                            recipe.steps.append(step)
                                            pickingStep = false
                                        } label: {
                                            Text(step.label).frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 10).padding(.vertical, 6)
                                        }.buttonStyle(.plain)
                                    }
                                }
                            }
                        }.frame(width: 240, height: 320)
                    }
                Spacer()
                Button("Cancel", action: onCancel)
                Button("Save") { onSave(recipe) }
                    .keyboardShortcut(.defaultAction)
                    .disabled(recipe.name.isEmpty || recipe.steps.isEmpty)
            }.padding(12)
        }
        .frame(width: 460, height: 500)
    }
}
