import Foundation

struct Colony: Identifiable, Codable {
    let id = UUID()
    var name: String
    var species: String
    var foundedDate: Date
    var queenCount: Int
    var workerCount: Int
    var larvae: Int
    var pupae: Int
    var eggs: Int
    var notes: String
    var logs: [ColonyLog]
    var lastFed: Date?
    var lastCleaned: Date?
    var temperatureRange: String
    var humidityRange: String
    
    static let sampleData: [Colony] = [
        Colony(
            name: "Colony Alpha",
            species: "Camponotus",
            foundedDate: Date().addingTimeInterval(-86400 * 30),
            queenCount: 1,
            workerCount: 15,
            larvae: 8,
            pupae: 5,
            eggs: 12,
            notes: "First colony, doing well",
            logs: [
                ColonyLog(
                    date: Date(),
                    activity: .feeding,
                    notes: "Fed honey and crickets"
                )
            ],
            lastFed: Date().addingTimeInterval(-86400),
            lastCleaned: Date().addingTimeInterval(-86400 * 3),
            temperatureRange: "22-25°C",
            humidityRange: "60-70%"
        )
    ]
}

struct ColonyLog: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let activity: LogActivity
    let notes: String
}

enum LogActivity: String, CaseIterable, Codable {
    case feeding = "Feeding"
    case cleaning = "Cleaning"
    case observation = "Observation"
    case breeding = "Breeding"
    case maintenance = "Maintenance"
    case medical = "Medical"
} 