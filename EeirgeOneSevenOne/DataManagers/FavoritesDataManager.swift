import Foundation
import SwiftUI

class FavoritesDataManager: ObservableObject {
    @Published var favorites: [FavoriteItem] = []
    @AppStorage("favorites_data") private var favoritesData: Data = Data()
    
    init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        if let decodedFavorites = try? JSONDecoder().decode([FavoriteItem].self, from: favoritesData) {
            favorites = decodedFavorites
        }
    }
    
    private func saveFavorites() {
        if let encodedData = try? JSONEncoder().encode(favorites) {
            favoritesData = encodedData
        }
    }
    
    func addFavorite(_ newFavorite: FavoriteItem) {
        favorites.append(newFavorite)
        saveFavorites()
    }
    
    func removeFavorite(_ favoriteId: UUID) {
        favorites.removeAll { $0.id == favoriteId }
        saveFavorites()
    }
    
    func isFavorited(referenceId: String, type: FavoriteType) -> Bool {
        return favorites.contains { $0.referenceId == referenceId && $0.type == type }
    }
    
    func favoritesByType(_ type: FavoriteType) -> [FavoriteItem] {
        return favorites.filter { $0.type == type }
    }
    
    func recentFavorites() -> [FavoriteItem] {
        return favorites.sorted { $0.dateAdded > $1.dateAdded }.prefix(10).map { $0 }
    }
} 