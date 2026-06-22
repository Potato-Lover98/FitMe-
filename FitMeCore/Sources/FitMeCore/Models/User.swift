import Foundation

public struct User: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var age: Int
    public var biologicalSex: BiologicalSex
    public var heightCm: Double
    public var weightKg: Double
    public var goals: [Goal]

    public init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        biologicalSex: BiologicalSex,
        heightCm: Double,
        weightKg: Double,
        goals: [Goal] = []
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.biologicalSex = biologicalSex
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.goals = goals
    }

    public var bmi: Double {
        let meters = heightCm / 100
        guard meters > 0 else { return 0 }
        return weightKg / (meters * meters)
    }
}

public enum BiologicalSex: String, Codable, CaseIterable, Sendable {
    case male
    case female
    case other
}