import Foundation
import SwiftUI

class ExpenseDataManager: ObservableObject {
    @Published var expenses: [Expense] = []
    @AppStorage("expenses_data") private var expensesData: Data = Data()
    
    init() {
        loadExpenses()
    }
    
    private func loadExpenses() {
        if let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: expensesData) {
            expenses = decodedExpenses
        } else {
            expenses = Expense.sampleData
            saveExpenses()
        }
    }
    
    private func saveExpenses() {
        if let encodedData = try? JSONEncoder().encode(expenses) {
            expensesData = encodedData
        }
    }
    
    func addExpense(_ newExpense: Expense) {
        expenses.append(newExpense)
        saveExpenses()
    }
    
    func updateExpense(_ updatedExpense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            expenses[index] = updatedExpense
            saveExpenses()
        }
    }
    
    func deleteExpense(_ expenseId: UUID) {
        expenses.removeAll { $0.id == expenseId }
        saveExpenses()
    }
    
    func totalExpenses() -> Double {
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    func expensesByCategory(_ category: ExpenseCategory) -> [Expense] {
        return expenses.filter { $0.category == category }
    }
    
    func monthlyTotal() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return expenses.filter { expense in
            expense.date >= startOfMonth
        }.reduce(0) { $0 + $1.amount }
    }
    
    func expensesForDateRange(from startDate: Date, to endDate: Date) -> [Expense] {
        return expenses.filter { expense in
            expense.date >= startDate && expense.date <= endDate
        }
    }
} 