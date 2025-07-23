import Foundation
import SwiftUI

class AntSpeciesDataManager: ObservableObject {
    @Published var species: [AntSpecies] = []
    @AppStorage("ant_species_data") private var speciesData: Data = Data()
    
    init() {
        loadSpecies()
    }
    
    private func loadSpecies() {
        if let decodedSpecies = try? JSONDecoder().decode([AntSpecies].self, from: speciesData) {
            species = decodedSpecies
        } else {
            species = AntSpecies.sampleData
            saveSpecies()
        }
    }
    
    private func saveSpecies() {
        if let encodedData = try? JSONEncoder().encode(species) {
            speciesData = encodedData
        }
    }
    
    func addSpecies(_ newSpecies: AntSpecies) {
        species.append(newSpecies)
        saveSpecies()
    }
    
    func updateSpecies(_ updatedSpecies: AntSpecies) {
        if let index = species.firstIndex(where: { $0.id == updatedSpecies.id }) {
            species[index] = updatedSpecies
            saveSpecies()
        }
    }
    
    func deleteSpecies(_ speciesId: UUID) {
        species.removeAll { $0.id == speciesId }
        saveSpecies()
    }
    
    func searchSpecies(query: String) -> [AntSpecies] {
        if query.isEmpty {
            return species
        }
        return species.filter { species in
            species.name.localizedCaseInsensitiveContains(query) ||
            species.scientificName.localizedCaseInsensitiveContains(query) ||
            species.category.rawValue.localizedCaseInsensitiveContains(query)
        }
    }
    
    func speciesByCategory(_ category: AntCategory) -> [AntSpecies] {
        return species.filter { $0.category == category }
    }
} 