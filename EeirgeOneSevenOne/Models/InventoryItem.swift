import Foundation

struct InventoryItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var category: ItemCategory
    var isOwned: Bool
    var quantity: Int
    var notes: String
    var reminderDate: Date?
    var purchaseDate: Date?
    var cost: Double?
    
    static let sampleData: [InventoryItem] = [
        InventoryItem(
            name: "Test Tubes",
            category: .housing,
            isOwned: true,
            quantity: 10,
            notes: "16x150mm size",
            reminderDate: nil,
            purchaseDate: Date().addingTimeInterval(-86400 * 7),
            cost: 15.99
        ),
        InventoryItem(
            name: "Cotton Balls",
            category: .supplies,
            isOwned: true,
            quantity: 50,
            notes: "Organic cotton",
            reminderDate: nil,
            purchaseDate: Date().addingTimeInterval(-86400 * 7),
            cost: 5.99
        ),
        InventoryItem(
            name: "Formicarium",
            category: .housing,
            isOwned: false,
            quantity: 0,
            notes: "Need 20x15cm size",
            reminderDate: Date().addingTimeInterval(86400 * 7),
            purchaseDate: nil,
            cost: nil
        )
    ]
}

enum ItemCategory: String, CaseIterable, Codable {
    case housing = "Housing"
    case feeding = "Feeding"
    case supplies = "Supplies"
    case tools = "Tools"
    case maintenance = "Maintenance"
    case safety = "Safety"
} 