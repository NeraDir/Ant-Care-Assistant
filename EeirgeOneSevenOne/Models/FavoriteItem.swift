import Foundation

struct FavoriteItem: Identifiable, Codable {
    let id = UUID()
    let type: FavoriteType
    let title: String
    let description: String
    let dateAdded: Date
    let referenceId: String
}

enum FavoriteType: String, CaseIterable, Codable {
    case species = "Species"
    case guide = "Guide"
    case calculation = "Calculation"
    case advice = "AI Advice"
} 