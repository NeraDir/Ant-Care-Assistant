import SwiftUI

struct ExpenseTrackerView: View {
    @EnvironmentObject var expenseDataManager: ExpenseDataManager
    @State private var selectedCategory: ExpenseCategory? = nil
    @State private var showingAddExpense = false
    @State private var selectedExpense: Expense? = nil
    
    var filteredExpenses: [Expense] {
        if let category = selectedCategory {
            return expenseDataManager.expensesByCategory(category)
        }
        return expenseDataManager.expenses
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Summary cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        SummaryCard(
                            title: "Total Spent",
                            value: "$\(expenseDataManager.totalExpenses().formatted(.number.precision(.fractionLength(2))))",
                            color: .blue
                        )
                        
                        SummaryCard(
                            title: "This Month",
                            value: "$\(expenseDataManager.monthlyTotal().formatted(.number.precision(.fractionLength(2))))",
                            color: .green
                        )
                        
                        SummaryCard(
                            title: "Avg per Item",
                            value: "$\((expenseDataManager.expenses.isEmpty ? 0 : expenseDataManager.totalExpenses() / Double(expenseDataManager.expenses.count)).formatted(.number.precision(.fractionLength(2))))",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                }
                
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
                        
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
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
                
                // Expenses list
                if filteredExpenses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 8) {
                            Text("No Expenses Found")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Start tracking your ant keeping expenses to manage your budget and monitor spending patterns.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Add First Expense") {
                            showingAddExpense = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredExpenses.sorted { $0.date > $1.date }) { expense in
                        ExpenseRowView(expense: expense)
                            .onTapGesture {
                                selectedExpense = expense
                            }
                    }
                }
            }
            .navigationTitle("Expense Tracker")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Add") {
                        showingAddExpense = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
                .environmentObject(expenseDataManager)
        }
        .sheet(item: $selectedExpense) { expense in
            ExpenseDetailView(expense: expense)
                .environmentObject(expenseDataManager)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(color)
        }
        .padding()
        .frame(minWidth: 100)
        .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .cornerRadius(12)
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.headline)
                
                HStack {
                    Text(expense.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(categoryColor(expense.category).opacity(0.2))
                        .foregroundColor(categoryColor(expense.category))
                        .cornerRadius(8)
                    
                    Text(expense.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !expense.notes.isEmpty {
                    Text(expense.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text("$\(expense.amount.formatted(.number.precision(.fractionLength(2))))")
                .font(.title3)
                .bold()
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
    
    private func categoryColor(_ category: ExpenseCategory) -> Color {
        switch category {
        case .equipment: return .blue
        case .food: return .green
        case .housing: return .orange
        case .maintenance: return .purple
        case .books: return .red
        case .other: return .gray
        }
    }
}

struct ExpenseDetailView: View {
    let expense: Expense
    @EnvironmentObject var expenseDataManager: ExpenseDataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.description)
                                    .font(.title)
                                    .bold()
                                Text(expense.category.rawValue)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("$\(expense.amount.formatted(.number.precision(.fractionLength(2))))")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.green)
                                Text(expense.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                    
                    // Details
                    if !expense.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            Text(expense.notes)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .cornerRadius(12)
                    }
                    
                    // Category breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category Analysis")
                            .font(.headline)
                        
                        let categoryTotal = expenseDataManager.expensesByCategory(expense.category)
                            .reduce(0) { $0 + $1.amount }
                        
                        HStack {
                            Text("Total in \(expense.category.rawValue):")
                                .bold()
                            Spacer()
                            Text("$\(categoryTotal.formatted(.number.precision(.fractionLength(2))))")
                                .foregroundColor(.green)
                        }
                        
                        let percentage = (expense.amount / categoryTotal) * 100
                        HStack {
                            Text("This expense:")
                                .bold()
                            Spacer()
                            Text("\(percentage.formatted(.number.precision(.fractionLength(1))))% of category")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Expense Detail")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("Delete") {
                        expenseDataManager.deleteExpense(expense.id)
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

struct AddExpenseView: View {
    @EnvironmentObject var expenseDataManager: ExpenseDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var category: ExpenseCategory = .equipment
    @State private var date = Date()
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Expense Details") {
                    HStack {
                        Text("Amount")
                        TextField("0.00", text: $amount)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("Description", text: $description)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Notes") {
                    TextField("Additional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("Save") {
                        guard let amountValue = Double(amount) else { return }
                        
                        let expense = Expense(
                            amount: amountValue,
                            description: description,
                            category: category,
                            date: date,
                            notes: notes
                        )
                        expenseDataManager.addExpense(expense)
                        dismiss()
                    }
                    .disabled(amount.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ExpenseTrackerView()
        .environmentObject(ExpenseDataManager())
} 