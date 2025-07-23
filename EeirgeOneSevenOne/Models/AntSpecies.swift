import Foundation

struct AntSpecies: Identifiable, Codable {
    let id = UUID()
    let name: String
    let scientificName: String
    let category: AntCategory
    let difficulty: DifficultyLevel
    let colonySize: String
    let temperature: String
    let humidity: String
    let feedingInfo: String
    let nestingInfo: String
    let description: String
    let imageSystemName: String
    
    static let sampleData: [AntSpecies] = [
        AntSpecies(
            name: "Carpenter Ant",
            scientificName: "Camponotus",
            category: .carpenter,
            difficulty: .beginner,
            colonySize: "10,000-50,000",
            temperature: "20-25°C",
            humidity: "50-70%",
            feedingInfo: "Insects, honey, fruit",
            nestingInfo: "Wood galleries, test tubes",
            description: "Large ants known for nesting in wood. Great for beginners due to their hardy nature.",
            imageSystemName: "ant.fill"
        ),
        AntSpecies(
            name: "Harvester Ant",
            scientificName: "Pogonomyrmex",
            category: .harvester,
            difficulty: .intermediate,
            colonySize: "1,000-10,000",
            temperature: "25-30°C",
            humidity: "30-50%",
            feedingInfo: "Seeds, grains, occasional insects",
            nestingInfo: "Deep underground chambers",
            description: "Seed collecting ants with powerful mandibles. Require specific climate conditions.",
            imageSystemName: "ant"
        )
    ]
}

enum AntCategory: String, CaseIterable, Codable {
    case carpenter = "Carpenter"
    case harvester = "Harvester"
    case leafcutter = "Leafcutter"
    case fire = "Fire"
    case pavement = "Pavement"
    case pharaoh = "Pharaoh"
    case acrobat = "Acrobat"
    case field = "Field"
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
} 