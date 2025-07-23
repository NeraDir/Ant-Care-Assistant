import SwiftUI

struct AntSpeciesCatalogView: View {
    @EnvironmentObject var speciesDataManager: AntSpeciesDataManager
    @EnvironmentObject var favoritesDataManager: FavoritesDataManager
    
    @State private var searchText = ""
    @State private var selectedCategory: AntCategory? = nil
    @State private var selectedSpecies: AntSpecies? = nil
    
    var filteredSpecies: [AntSpecies] {
        var species = speciesDataManager.searchSpecies(query: searchText)
        if let category = selectedCategory {
            species = species.filter { $0.category == category }
        }
        return species
    }
    
    private func deleteSpecies(at offsets: IndexSet) {
        for index in offsets {
            let speciesId = filteredSpecies[index].id
            speciesDataManager.deleteSpecies(speciesId)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search species...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
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
                        
                        ForEach(AntCategory.allCases, id: \.self) { category in
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
                
                // Species list
                if filteredSpecies.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "ant.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 8) {
                            Text("No Species Found")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Add some ant species to your catalog to get started with your collection.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Add First Species") {
                            // Add new species functionality would go here
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredSpecies) { species in
                            SpeciesRowView(species: species)
                                .onTapGesture {
                                    selectedSpecies = species
                                }
                        }
                        .onDelete(perform: deleteSpecies)
                    }
                }
            }
            .navigationTitle("Ant Species")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Add") {
                        // Add new species functionality would go here
                    }
                }
            }
        }
        .sheet(item: $selectedSpecies) { species in
            SpeciesDetailView(species: species)
                .environmentObject(favoritesDataManager)
        }
    }
}

struct SpeciesRowView: View {
    let species: AntSpecies
    
    var body: some View {
        HStack {
            Image(systemName: species.imageSystemName)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(species.name)
                    .font(.headline)
                Text(species.scientificName)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
                
                HStack {
                    DifficultyBadge(difficulty: species.difficulty)
                    Text(species.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

struct SpeciesDetailView: View {
    let species: AntSpecies
    @EnvironmentObject var favoritesDataManager: FavoritesDataManager
    @Environment(\.dismiss) private var dismiss
    
    var isFavorited: Bool {
        favoritesDataManager.isFavorited(referenceId: species.id.uuidString, type: .species)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: species.imageSystemName)
                                .font(.largeTitle)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading) {
                                Text(species.name)
                                    .font(.title)
                                    .bold()
                                Text(species.scientificName)
                                    .font(.title3)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            DifficultyBadge(difficulty: species.difficulty)
                            Text(species.category.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(species.description)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Care Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Care Information")
                            .font(.headline)
                        
                        CareInfoRow(title: "Colony Size", value: species.colonySize)
                        CareInfoRow(title: "Temperature", value: species.temperature)
                        CareInfoRow(title: "Humidity", value: species.humidity)
                        CareInfoRow(title: "Feeding", value: species.feedingInfo)
                        CareInfoRow(title: "Nesting", value: species.nestingInfo)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .padding()
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle("Species Detail")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        if isFavorited {
                            if let favorite = favoritesDataManager.favorites.first(where: { 
                                $0.referenceId == species.id.uuidString && $0.type == .species 
                            }) {
                                favoritesDataManager.removeFavorite(favorite.id)
                            }
                        } else {
                            let favorite = FavoriteItem(
                                type: .species,
                                title: species.name,
                                description: species.scientificName,
                                dateAdded: Date(),
                                referenceId: species.id.uuidString
                            )
                            favoritesDataManager.addFavorite(favorite)
                        }
                    } label: {
                        Image(systemName: isFavorited ? "heart.fill" : "heart")
                            .foregroundColor(isFavorited ? .red : .gray)
                    }
                }
            }
        }
    }
}

struct CareInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .bold()
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
            Spacer()
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: DifficultyLevel
    
    var color: Color {
        switch difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        case .expert:
            return .purple
        }
    }
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

#Preview {
    AntSpeciesCatalogView()
        .environmentObject(AntSpeciesDataManager())
        .environmentObject(FavoritesDataManager())
} 