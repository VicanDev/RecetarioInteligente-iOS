import SwiftUI

struct RecipeListView: View {
    @State private var searchText: String = ""
    @State private var recipes: [Meal] = []
    @State private var isLoading: Bool = false
    
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
                
                if isLoading {
                    Spacer()
                    ProgressView("Buscando recetas...")
                    Spacer()
                } else if recipes.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                        Text("No se encontraron recetas")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(recipes) { meal in
                                NavigationLink(destination: RecipeDetailView(meal: meal)) {
                                    RecipeCardView(meal: meal)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
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
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isLoading = true
        Task {
            do {
                recipes = try await RecipeService.shared.searchRecipes(by: trimmed)
            } catch {
                recipes = []
            }
            isLoading = false
        }
    }
    
    private func loadDefaultRecipes() async {
        isLoading = true
        do {
            recipes = try await RecipeService.shared.searchRecipes(by: "Chicken")
        } catch {
            recipes = []
        }
        isLoading = false
    }
}

#Preview {
    RecipeListView()
}
