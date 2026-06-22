import Foundation

public struct MLRiskOutput: Equatable, Sendable {
    public let score: Double
    public let band: RiskBand
    public let rawOutput: Float

    public init(rawOutput: Float) {
        self.rawOutput = rawOutput
        self.score = Double(rawOutput * 100)
        self.band = RiskBand.from(score: score)
    }

    public init(score: Double) {
        self.score = min(max(0, score), 100)
        self.rawOutput = Float(self.score / 100)
        self.band = RiskBand.from(score: self.score)
    }
}

public enum PostProcessor {
    public static func process(_ rawOutput: Float) -> MLRiskOutput {
        MLRiskOutput(rawOutput: rawOutput)
    }

    public static func riskScore(_ rawOutput: Float) -> Double {
        Double(rawOutput * 100)
    }

    public static func band(_ rawOutput: Float) -> RiskBand {
        let score = Double(rawOutput * 100)
        return RiskBand.from(score: score)
    }

    public static func bandFromScore(_ score: Double) -> RiskBand {
        RiskBand.from(score: score)
    }
}