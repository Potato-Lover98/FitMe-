import Foundation

public struct FeverRisk: Codable, Equatable, Sendable {
    public let score: Double
    public let contributingFactors: [String]
    public let timestamp: Date
    public let band: RiskBand

    public init(score: Double, contributingFactors: [String], timestamp: Date = Date()) {
        self.score = min(max(0, score), 100)
        self.contributingFactors = contributingFactors
        self.timestamp = timestamp
        self.band = RiskBand.from(score: score)
    }
}

public enum RiskBand: String, Codable, Sendable {
    case low
    case medium
    case high

    public static func from(score: Double) -> RiskBand {
        switch score {
        case ..<30:   .low
        case ..<70:   .medium
        default:      .high
        }
    }
}