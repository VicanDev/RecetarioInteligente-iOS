import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

class RecipeService {
    static let shared = RecipeService()
    
    private let baseURL = "https://www.themealdb.com/api/json/v1/1"
    
    func searchRecipes(by query: String) async throws -> [Meal] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "\(baseURL)/search.php?s=\(encodedQuery)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.noData
        }
        
        do {
            let decoded = try JSONDecoder().decode(MealResponse.self, from: data)
            return decoded.meals ?? []
        } catch {
            throw NetworkError.decodingError
        }
    }
}
