import Foundation

struct SetupGuide: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    var steps: [SetupStep]
    let category: GuideCategory
    let estimatedTime: String
    let difficulty: DifficultyLevel
    var progress: Double = 0.0
    var isCompleted: Bool = false
    
    static let sampleData: [SetupGuide] = [
        SetupGuide(
            title: "First Colony Setup",
            description: "Complete guide for setting up your first ant colony",
            steps: [
                SetupStep(
                    title: "Prepare Test Tube",
                    description: "Fill test tube with water and cotton ball",
                    isCompleted: false,
                    imageSystemName: "testtube.2"
                ),
                SetupStep(
                    title: "Add Queen",
                    description: "Carefully place queen ant in test tube setup",
                    isCompleted: false,
                    imageSystemName: "ant.fill"
                ),
                SetupStep(
                    title: "Create Dark Environment",
                    description: "Cover test tube with aluminum foil",
                    isCompleted: false,
                    imageSystemName: "moon.fill"
                )
            ],
            category: .beginner,
            estimatedTime: "30 minutes",
            difficulty: .beginner
        )
    ]
}

struct SetupStep: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    var isCompleted: Bool
    let imageSystemName: String
}

enum GuideCategory: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case housing = "Housing"
    case feeding = "Feeding"
    case breeding = "Breeding"
    case maintenance = "Maintenance"
} 