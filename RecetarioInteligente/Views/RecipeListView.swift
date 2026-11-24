import SwiftUI

struct RecipeListView: View {
    @State private var searchText: String = ""
    @State private var recipes: [Meal] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    
                    TextField("Buscar recetas (ej. Pasta, Chicken)...", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit {
                            searchAction()
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(recipes) { meal in
                            RecipeCardView(meal: meal)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Recetas")
            .task {
                if recipes.isEmpty {
                    await loadDefaultRecipes()
                }
            }
        }
    }
    
    private func searchAction() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        Task {
            do {
                recipes = try await RecipeService.shared.searchRecipes(by: searchText)
            } catch {
                recipes = []
            }
        }
    }
    
    private func loadDefaultRecipes() async {
        do {
            recipes = try await RecipeService.shared.searchRecipes(by: "Chicken")
        } catch {
            recipes = []
        }
    }
}

#Preview {
    RecipeListView()
}
