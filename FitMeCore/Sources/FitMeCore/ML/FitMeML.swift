import Foundation

public enum FitMeML {
    public static var isLoaded: Bool { model != nil }

    private static var model: MLPModel?

    public static func load(from url: URL) throws {
        model = try ModelLoader.load(from: url)
    }

    public static func loadFromBundle() throws {
        model = try ModelLoader.loadFromBundle()
    }

    public static func evaluate(heartRate: Double, bodyTemperature: Double, oxygenSaturation: Double) -> MLRiskOutput? {
        guard let model = model else { return nil }
        let features = FeatureBuilder.normalize(heartRate: heartRate, bodyTemperature: bodyTemperature, oxygenSaturation: oxygenSaturation)
        let raw = Inferencer.predict(model: model, input: features)
        return PostProcessor.process(raw)
    }

    public static func riskDescription(heartRate: Double, bodyTemperature: Double, oxygenSaturation: Double) -> String {
        guard let result = evaluate(heartRate: heartRate, bodyTemperature: bodyTemperature, oxygenSaturation: oxygenSaturation) else {
            return "Model not loaded"
        }
        return String(format: "%.1f%% (%@)", result.score, result.band.rawValue.uppercased())
    }
}