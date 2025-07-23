

import SwiftUI

struct ContentView: View {
    @StateObject private var speciesDataManager = AntSpeciesDataManager()
    @StateObject private var setupGuideDataManager = SetupGuideDataManager()
    @StateObject private var colonyDataManager = ColonyDataManager()
    @StateObject private var inventoryDataManager = InventoryDataManager()
    @StateObject private var expenseDataManager = ExpenseDataManager()

    @StateObject private var favoritesDataManager = FavoritesDataManager()
    @StateObject private var openAIService = OpenAIService()
    
    var body: some View {
        TabView {
            AntSpeciesCatalogView()
                .environmentObject(speciesDataManager)
                .environmentObject(favoritesDataManager)
                .tabItem {
                    Image(systemName: "ant.fill")
                    Text("Species")
                }
            
            SetupGuidesView()
                .environmentObject(setupGuideDataManager)
                .environmentObject(favoritesDataManager)
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Guides")
                }
            
            ColonyTrackerView()
                .environmentObject(colonyDataManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Colonies")
                }
            
            InventoryView()
                .environmentObject(inventoryDataManager)
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Inventory")
                }
            
            MaterialCalculatorView()
                .tabItem {
                    Image(systemName: "ruler")
                    Text("Calculator")
                }
            
            ExpenseTrackerView()
                .environmentObject(expenseDataManager)
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Expenses")
                }
            
            GPTAntAdvisorView()
                .environmentObject(openAIService)
                .environmentObject(favoritesDataManager)
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI Advisor")
                }
            

            
            FavoritesHistoryView()
                .environmentObject(favoritesDataManager)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
        }
        .accentColor(Color(red: 0.298, green: 0.686, blue: 0.314)) // #4CAF50
    }
}

#Preview {
    ContentView()
}
