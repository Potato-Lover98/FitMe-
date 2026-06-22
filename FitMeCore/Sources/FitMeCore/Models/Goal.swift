import Foundation

public struct Goal: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var vitalType: VitalType
    public var targetValue: Double
    public var unit: String
    public var period: GoalPeriod
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        vitalType: VitalType,
        targetValue: Double,
        unit: String,
        period: GoalPeriod = .daily,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.vitalType = vitalType
        self.targetValue = targetValue
        self.unit = unit
        self.period = period
        self.createdAt = createdAt
    }
}

public enum GoalPeriod: String, Codable, CaseIterable, Sendable {
    case daily
    case weekly
    case monthly
}