import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var inventoryDataManager: InventoryDataManager
    @State private var selectedCategory: ItemCategory? = nil
    @State private var showingOwnedOnly = false
    @State private var selectedItem: InventoryItem? = nil
    @State private var showingAddItem = false
    
    var filteredItems: [InventoryItem] {
        var items = inventoryDataManager.items
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        if showingOwnedOnly {
            items = items.filter { $0.isOwned }
        }
        
        return items
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter controls
                VStack(spacing: 8) {
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button("All") {
                                selectedCategory = nil
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedCategory == nil ? Color.green : Color.white)
                .shadow(color: selectedCategory == nil ? Color.clear : Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .foregroundColor(selectedCategory == nil ? .white : .primary)
                            .cornerRadius(15)
                            
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                Button(category.rawValue) {
                                    selectedCategory = category
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedCategory == category ? Color.green : Color.white)
                    .shadow(color: selectedCategory == category ? Color.clear : Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(15)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Owned filter
                    Toggle("Show Owned Only", isOn: $showingOwnedOnly)
                        .padding(.horizontal)
                }
                
                // Items list
                if filteredItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cube.box.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 8) {
                            Text("No Items Found")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Add inventory items to track your ant keeping supplies, food, and equipment.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Add First Item") {
                            showingAddItem = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredItems) { item in
                        InventoryItemRowView(item: item)
                            .onTapGesture {
                                selectedItem = item
                            }
                    }
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Add") {
                        showingAddItem = true
                    }
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            InventoryItemDetailView(item: item)
                .environmentObject(inventoryDataManager)
        }
        .sheet(isPresented: $showingAddItem) {
            AddInventoryItemView()
                .environmentObject(inventoryDataManager)
        }
    }
}

struct InventoryItemRowView: View {
    let item: InventoryItem
    
    var body: some View {
        HStack {
            // Ownership indicator
            ZStack {
                Circle()
                    .fill(item.isOwned ? Color.green : Color.red)
                    .frame(width: 20, height: 20)
                
                Image(systemName: item.isOwned ? "checkmark" : "xmark")
                    .foregroundColor(.white)
                    .font(.caption)
                    .bold()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .strikethrough(!item.isOwned)
                
                HStack {
                    Text(item.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    
                    if item.isOwned && item.quantity > 0 {
                        Text("Qty: \(item.quantity)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let cost = item.cost {
                    Text("$\(cost, specifier: "%.2f")")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.green)
                }
                
                if let reminderDate = item.reminderDate, reminderDate > Date() {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct InventoryItemDetailView: View {
    let item: InventoryItem
    @EnvironmentObject var inventoryDataManager: InventoryDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var editingName: String
    @State private var editingCategory: ItemCategory
    @State private var editingQuantity: Int
    @State private var editingCost: String
    @State private var editingIsOwned: Bool
    
    init(item: InventoryItem) {
        self.item = item
        self._editingName = State(initialValue: item.name)
        self._editingCategory = State(initialValue: item.category)
        self._editingQuantity = State(initialValue: item.quantity)
        self._editingCost = State(initialValue: item.cost?.formatted(.number.precision(.fractionLength(2))) ?? "")
        self._editingIsOwned = State(initialValue: item.isOwned)
    }
    
    private func saveChanges() {
        let costValue = Double(editingCost.isEmpty ? "0" : editingCost)
        
        var updatedItem = item
        updatedItem.name = editingName.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedItem.category = editingCategory
        updatedItem.quantity = editingQuantity
        updatedItem.cost = costValue
        updatedItem.isOwned = editingIsOwned
        
        inventoryDataManager.updateItem(updatedItem)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                if isEditing {
                                    TextField("Item name", text: $editingName)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                } else {
                                    Text(item.name)
                                        .font(.title)
                                        .bold()
                                }
                                
                                if isEditing {
                                    Picker("Category", selection: $editingCategory) {
                                        ForEach(ItemCategory.allCases, id: \.self) { category in
                                            Text(category.rawValue).tag(category)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                } else {
                                    Text(item.category.rawValue)
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            VStack {
                                if isEditing {
                                    VStack(spacing: 8) {
                                        Button(action: {
                                            editingIsOwned.toggle()
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(editingIsOwned ? Color.green : Color.red)
                                                    .frame(width: 40, height: 40)
                                                
                                                Image(systemName: editingIsOwned ? "checkmark" : "xmark")
                                                    .foregroundColor(.white)
                                                    .font(.title3)
                                                    .bold()
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Text("Tap to change")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(item.isOwned ? Color.green : Color.red)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: item.isOwned ? "checkmark" : "xmark")
                                            .foregroundColor(.white)
                                            .font(.title3)
                                            .bold()
                                    }
                                }
                                
                                Text(isEditing ? (editingIsOwned ? "Owned" : "Needed") : (item.isOwned ? "Owned" : "Needed"))
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(isEditing ? (editingIsOwned ? .green : .red) : (item.isOwned ? .green : .red))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                    
                    // Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                        
                        if (isEditing && editingIsOwned) || (item.isOwned && item.quantity > 0) {
                            HStack {
                                Text("Quantity")
                                    .font(.subheadline)
                                    .bold()
                                Spacer()
                                if isEditing {
                                    Stepper(value: $editingQuantity, in: 0...999) {
                                        Text("\(editingQuantity)")
                                            .font(.subheadline)
                                    }
                                } else {
                                    Text("\(item.quantity)")
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        HStack {
                            Text("Cost")
                                .font(.subheadline)
                                .bold()
                            Spacer()
                            if isEditing {
                                HStack {
                                    Text("$")
                                    TextField("0.00", text: $editingCost)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                }
                            } else {
                                if let cost = item.cost {
                                    Text("$\(cost.formatted(.number.precision(.fractionLength(2))))")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                } else {
                                    Text("Not set")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        if let purchaseDate = item.purchaseDate {
                            HStack {
                                Text("Purchased")
                                    .font(.subheadline)
                                    .bold()
                                Spacer()
                                Text(purchaseDate, style: .date)
                                    .font(.subheadline)
                            }
                        }
                        
                        if let reminderDate = item.reminderDate {
                            HStack {
                                Text("Reminder")
                                    .font(.subheadline)
                                    .bold()
                                Spacer()
                                Text(reminderDate, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(reminderDate > Date() ? .orange : .red)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                    
                    // Notes
                    if !item.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            Text(item.notes)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Item Detail")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    if isEditing {
                        Button("Cancel") {
                            isEditing = false
                            // Reset editing values
                            editingName = item.name
                            editingCategory = item.category
                            editingQuantity = item.quantity
                            editingCost = item.cost?.formatted(.number.precision(.fractionLength(2))) ?? ""
                            editingIsOwned = item.isOwned
                        }
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                            isEditing = false
                        }
                        .disabled(editingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
        }
    }
}

struct AddInventoryItemView: View {
    @EnvironmentObject var inventoryDataManager: InventoryDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var category: ItemCategory = .supplies
    @State private var isOwned = false
    @State private var quantity = 1
    @State private var notes = ""
    @State private var cost: String = ""
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Item Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    Toggle("I own this item", isOn: $isOwned)
                }
                
                if isOwned {
                    Section("Ownership Details") {
                        Stepper("Quantity: \(quantity)", value: $quantity, in: 1...999)
                        
                        HStack {
                            Text("Cost")
                            TextField("0.00", text: $cost)
                        }
                    }
                } else {
                    Section("Reminder") {
                        Toggle("Set Reminder", isOn: $hasReminder)
                        
                        if hasReminder {
                            DatePicker("Reminder Date", selection: $reminderDate, displayedComponents: .date)
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Additional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("Save") {
                        let item = InventoryItem(
                            name: name,
                            category: category,
                            isOwned: isOwned,
                            quantity: isOwned ? quantity : 0,
                            notes: notes,
                            reminderDate: hasReminder ? reminderDate : nil,
                            purchaseDate: isOwned ? Date() : nil,
                            cost: Double(cost)
                        )
                        inventoryDataManager.addItem(item)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    InventoryView()
        .environmentObject(InventoryDataManager())
} 