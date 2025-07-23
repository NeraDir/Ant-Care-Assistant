import Foundation
import SwiftUI

class InventoryDataManager: ObservableObject {
    @Published var items: [InventoryItem] = []
    @AppStorage("inventory_data") private var inventoryData: Data = Data()
    
    init() {
        loadItems()
    }
    
    private func loadItems() {
        if let decodedItems = try? JSONDecoder().decode([InventoryItem].self, from: inventoryData) {
            items = decodedItems
        } else {
            items = InventoryItem.sampleData
            saveItems()
        }
    }
    
    private func saveItems() {
        if let encodedData = try? JSONEncoder().encode(items) {
            inventoryData = encodedData
        }
    }
    
    func addItem(_ newItem: InventoryItem) {
        items.append(newItem)
        saveItems()
    }
    
    func updateItem(_ updatedItem: InventoryItem) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
            saveItems()
        }
    }
    
    func deleteItem(_ itemId: UUID) {
        items.removeAll { $0.id == itemId }
        saveItems()
    }
    
    func itemsByCategory(_ category: ItemCategory) -> [InventoryItem] {
        return items.filter { $0.category == category }
    }
    
    func ownedItems() -> [InventoryItem] {
        return items.filter { $0.isOwned }
    }
    
    func neededItems() -> [InventoryItem] {
        return items.filter { !$0.isOwned }
    }
    
    func upcomingReminders() -> [InventoryItem] {
        let calendar = Calendar.current
        let now = Date()
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: now) ?? now
        
        return items.filter { item in
            if let reminderDate = item.reminderDate {
                return reminderDate >= now && reminderDate <= nextWeek
            }
            return false
        }
    }
} 