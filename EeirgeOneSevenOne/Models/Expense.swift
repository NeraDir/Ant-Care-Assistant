import Foundation

struct Expense: Identifiable, Codable {
    let id = UUID()
    var amount: Double
    var description: String
    var category: ExpenseCategory
    var date: Date
    var notes: String
    
    static let sampleData: [Expense] = [
        Expense(
            amount: 25.99,
            description: "Test Tube Setup Kit",
            category: .equipment,
            date: Date().addingTimeInterval(-86400 * 3),
            notes: "Initial setup for first colony"
        ),
        Expense(
            amount: 8.50,
            description: "Honey and Crickets",
            category: .food,
            date: Date().addingTimeInterval(-86400),
            notes: "Weekly feeding supplies"
        )
    ]
}

enum ExpenseCategory: String, CaseIterable, Codable {
    case equipment = "Equipment"
    case food = "Food"
    case housing = "Housing"
    case maintenance = "Maintenance"
    case books = "Books & Education"
    case other = "Other"
} 