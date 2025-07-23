import SwiftUI

struct FavoritesHistoryView: View {
    @EnvironmentObject var favoritesDataManager: FavoritesDataManager
    @State private var selectedCategory: FavoriteType? = nil
    @State private var selectedFavorite: FavoriteItem? = nil
    
    var filteredFavorites: [FavoriteItem] {
        if let category = selectedCategory {
            return favoritesDataManager.favoritesByType(category)
        }
        return favoritesDataManager.favorites
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.pink.opacity(0.1),
                        Color.red.opacity(0.05),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if favoritesDataManager.favorites.isEmpty {
                    // Modern empty state
                    ScrollView {
                        VStack(spacing: 32) {
                            Spacer(minLength: 60)
                            
                            // Animated heart with gradient
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.pink.opacity(0.3), Color.red.opacity(0.2)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 50, weight: .light))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.pink, Color.red]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            VStack(spacing: 16) {
                                Text("Start Building Your\nFavorites Collection")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.pink, Color.red]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("Save your favorite species, guides, calculations, and AI advice for quick access. Tap the heart icon throughout the app to add items here.")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Modern feature cards
                            VStack(spacing: 20) {
                                Text("What You Can Save:")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    ModernFeatureCard(icon: "ant.fill", title: "Species", subtitle: "Ant information", color: .green)
                                    ModernFeatureCard(icon: "list.bullet.clipboard", title: "Guides", subtitle: "Setup tutorials", color: .blue)
                                    ModernFeatureCard(icon: "ruler", title: "Calculations", subtitle: "Material results", color: .orange)
                                    ModernFeatureCard(icon: "brain.head.profile", title: "AI Advice", subtitle: "Expert responses", color: .purple)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            Spacer(minLength: 40)
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        // Modern category filter
                        VStack(spacing: 16) {
                            HStack {
                                Text("Your Favorites")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.pink, Color.red]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ModernFilterButton(
                                        title: "All",
                                        count: favoritesDataManager.favorites.count,
                                        isSelected: selectedCategory == nil,
                                        action: { selectedCategory = nil }
                                    )
                                    
                                    ForEach(FavoriteType.allCases, id: \.self) { type in
                                        let count = favoritesDataManager.favoritesByType(type).count
                                        ModernFilterButton(
                                            title: type.rawValue,
                                            count: count,
                                            isSelected: selectedCategory == type,
                                            action: { selectedCategory = type }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        .background(Color.white.opacity(0.8))
                        .background(.ultraThinMaterial)
                    
                        // Modern favorites list
                        if filteredFavorites.isEmpty {
                            VStack(spacing: 24) {
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.pink.opacity(0.2), Color.red.opacity(0.1)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 35))
                                        .foregroundStyle(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.pink, Color.red]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                
                                VStack(spacing: 12) {
                                    Text("No \(selectedCategory?.rawValue ?? "Favorites") Yet")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text("Start building your collection by tapping the heart icon throughout the app.")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                }
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredFavorites.sorted { $0.dateAdded > $1.dateAdded }) { favorite in
                                        ModernFavoriteCard(favorite: favorite)
                                            .onTapGesture {
                                                selectedFavorite = favorite
                                            }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                .padding(.bottom, 32)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                if !favoritesDataManager.favorites.isEmpty {
                    ToolbarItem(placement: .automatic) {
                        Button("Clear All") {
                            clearAllFavorites()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(item: $selectedFavorite) { favorite in
            FavoriteDetailView(favorite: favorite)
                .environmentObject(favoritesDataManager)
        }
    }
    
    private func clearAllFavorites() {
        for favorite in favoritesDataManager.favorites {
            favoritesDataManager.removeFavorite(favorite.id)
        }
    }
}

struct FavoriteTypeExample: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 20, height: 20)
            }
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

struct ModernFeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.2), color.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

struct ModernFilterButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color.pink, Color.red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.white]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: isSelected ? Color.pink.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 8 : 2, x: 0, y: isSelected ? 4 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernFavoriteCard: View {
    let favorite: FavoriteItem
    
    var typeColor: Color {
        switch favorite.type {
        case .species: return .green
        case .guide: return .blue
        case .calculation: return .orange
        case .advice: return .purple
        }
    }
    
    var typeIcon: String {
        switch favorite.type {
        case .species: return "ant.fill"
        case .guide: return "list.bullet.clipboard"
        case .calculation: return "ruler"
        case .advice: return "brain.head.profile"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Type indicator
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [typeColor.opacity(0.3), typeColor.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: typeIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(typeColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(favorite.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Text(favorite.type.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(typeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(typeColor.opacity(0.1))
                        )
                }
                
                if !favorite.description.isEmpty {
                    Text(favorite.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(favorite.dateAdded, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: typeColor.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
}

struct FavoriteRowView: View {
    let favorite: FavoriteItem
    
    var body: some View {
        HStack {
            // Type icon
            ZStack {
                Circle()
                    .fill(colorForType(favorite.type).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconForType(favorite.type))
                    .foregroundColor(colorForType(favorite.type))
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(favorite.title)
                        .font(.headline)
                    Spacer()
                    Text(favorite.dateAdded, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(favorite.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(favorite.type.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(colorForType(favorite.type).opacity(0.2))
                    .foregroundColor(colorForType(favorite.type))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func iconForType(_ type: FavoriteType) -> String {
        switch type {
        case .species: return "ant.fill"
        case .guide: return "list.bullet.clipboard"
        case .calculation: return "calculator"
        case .advice: return "brain.head.profile"
        }
    }
    
    private func colorForType(_ type: FavoriteType) -> Color {
        switch type {
        case .species: return .green
        case .guide: return .blue
        case .calculation: return .orange
        case .advice: return .purple
        }
    }
}

struct FavoriteDetailView: View {
    let favorite: FavoriteItem
    @EnvironmentObject var favoritesDataManager: FavoritesDataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(colorForType(favorite.type).opacity(0.2))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: iconForType(favorite.type))
                                    .foregroundColor(colorForType(favorite.type))
                                    .font(.title)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(favorite.title)
                                    .font(.title)
                                    .bold()
                                Text(favorite.type.rawValue)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text("Added on \(favorite.dateAdded, formatter: DateFormatter.fullDate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(favorite.description)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                    
                    // Reference info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reference")
                            .font(.headline)
                        
                        HStack {
                            Text("Type:")
                                .bold()
                            Spacer()
                            Text(favorite.type.rawValue)
                                .foregroundColor(colorForType(favorite.type))
                        }
                        
                        HStack {
                            Text("Reference ID:")
                                .bold()
                            Spacer()
                            Text(String(favorite.referenceId.prefix(8)) + "...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                    
                    // Related favorites
                    let relatedFavorites = favoritesDataManager.favoritesByType(favorite.type)
                        .filter { $0.id != favorite.id }
                        .prefix(3)
                    
                    if !relatedFavorites.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Related Favorites")
                                .font(.headline)
                            
                            ForEach(Array(relatedFavorites), id: \.id) { relatedFavorite in
                                HStack {
                                    Image(systemName: iconForType(relatedFavorite.type))
                                        .foregroundColor(colorForType(relatedFavorite.type))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(relatedFavorite.title)
                                            .font(.subheadline)
                                            .bold()
                                        Text(relatedFavorite.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Favorite Detail")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("Remove") {
                        favoritesDataManager.removeFavorite(favorite.id)
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func iconForType(_ type: FavoriteType) -> String {
        switch type {
        case .species: return "ant.fill"
        case .guide: return "list.bullet.clipboard"
        case .calculation: return "calculator"
        case .advice: return "brain.head.profile"
        }
    }
    
    private func colorForType(_ type: FavoriteType) -> Color {
        switch type {
        case .species: return .green
        case .guide: return .blue
        case .calculation: return .orange
        case .advice: return .purple
        }
    }
}

extension DateFormatter {
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
}

#Preview {
    FavoritesHistoryView()
        .environmentObject(FavoritesDataManager())
} 