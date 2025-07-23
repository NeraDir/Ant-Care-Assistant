import Foundation
import SwiftUI

class ColonyDataManager: ObservableObject {
    @Published var colonies: [Colony] = []
    @AppStorage("colonies_data") private var coloniesData: Data = Data()
    
    init() {
        loadColonies()
    }
    
    private func loadColonies() {
        if let decodedColonies = try? JSONDecoder().decode([Colony].self, from: coloniesData) {
            colonies = decodedColonies
        } else {
            colonies = Colony.sampleData
            saveColonies()
        }
    }
    
    private func saveColonies() {
        if let encodedData = try? JSONEncoder().encode(colonies) {
            coloniesData = encodedData
        }
    }
    
    func addColony(_ newColony: Colony) {
        colonies.append(newColony)
        saveColonies()
    }
    
    func updateColony(_ updatedColony: Colony) {
        if let index = colonies.firstIndex(where: { $0.id == updatedColony.id }) {
            colonies[index] = updatedColony
            saveColonies()
        }
    }
    
    func deleteColony(_ colonyId: UUID) {
        colonies.removeAll { $0.id == colonyId }
        saveColonies()
    }
    
    func addLog(to colonyId: UUID, log: ColonyLog) {
        if let index = colonies.firstIndex(where: { $0.id == colonyId }) {
            colonies[index].logs.append(log)
            
            // Update last activity dates
            switch log.activity {
            case .feeding:
                colonies[index].lastFed = log.date
            case .cleaning:
                colonies[index].lastCleaned = log.date
            default:
                break
            }
            
            saveColonies()
        }
    }
    
    func getColony(by id: UUID) -> Colony? {
        return colonies.first { $0.id == id }
    }
} 