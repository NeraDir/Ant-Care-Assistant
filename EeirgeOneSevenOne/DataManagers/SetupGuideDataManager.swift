import Foundation
import SwiftUI

class SetupGuideDataManager: ObservableObject {
    @Published var guides: [SetupGuide] = []
    @AppStorage("setup_guides_data") private var guidesData: Data = Data()
    
    init() {
        loadGuides()
    }
    
    private func loadGuides() {
        if let decodedGuides = try? JSONDecoder().decode([SetupGuide].self, from: guidesData) {
            guides = decodedGuides
        } else {
            guides = SetupGuide.sampleData
            saveGuides()
        }
    }
    
    private func saveGuides() {
        if let encodedData = try? JSONEncoder().encode(guides) {
            guidesData = encodedData
        }
    }
    
    func addGuide(_ newGuide: SetupGuide) {
        guides.append(newGuide)
        saveGuides()
    }
    
    func updateGuide(_ updatedGuide: SetupGuide) {
        if let index = guides.firstIndex(where: { $0.id == updatedGuide.id }) {
            guides[index] = updatedGuide
            saveGuides()
        }
    }
    
    func deleteGuide(_ guideId: UUID) {
        guides.removeAll { $0.id == guideId }
        saveGuides()
    }
    
    func updateStepCompletion(guideId: UUID, stepId: UUID, isCompleted: Bool) {
        if let guideIndex = guides.firstIndex(where: { $0.id == guideId }) {
            if let stepIndex = guides[guideIndex].steps.firstIndex(where: { $0.id == stepId }) {
                guides[guideIndex].steps[stepIndex].isCompleted = isCompleted
                
                // Update overall progress
                let completedSteps = guides[guideIndex].steps.filter { $0.isCompleted }.count
                let totalSteps = guides[guideIndex].steps.count
                guides[guideIndex].progress = totalSteps > 0 ? Double(completedSteps) / Double(totalSteps) : 0.0
                guides[guideIndex].isCompleted = completedSteps == totalSteps
                
                saveGuides()
            }
        }
    }
} 