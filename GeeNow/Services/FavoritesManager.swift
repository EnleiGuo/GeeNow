import Foundation
import SwiftUI

@MainActor
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @AppStorage("favoriteSourceIds") private var favoriteIdsData: Data = Data()
    
    @Published private(set) var favoriteIds: Set<String> = []
    
    private init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: favoriteIdsData) {
            favoriteIds = decoded
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteIds) {
            favoriteIdsData = encoded
        }
    }
    
    func isFavorite(_ sourceId: String) -> Bool {
        favoriteIds.contains(sourceId)
    }
    
    func toggleFavorite(_ sourceId: String) {
        if favoriteIds.contains(sourceId) {
            favoriteIds.remove(sourceId)
        } else {
            favoriteIds.insert(sourceId)
        }
        saveFavorites()
    }
    
    func addFavorite(_ sourceId: String) {
        favoriteIds.insert(sourceId)
        saveFavorites()
    }
    
    func removeFavorite(_ sourceId: String) {
        favoriteIds.remove(sourceId)
        saveFavorites()
    }
}
