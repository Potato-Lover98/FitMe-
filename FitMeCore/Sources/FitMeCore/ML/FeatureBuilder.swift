import Foundation

public enum FeatureBuilder {
    public static func normalize(heartRate: Double, bodyTemperature: Double, oxygenSaturation: Double) -> [Float] {
        [
            Float(heartRate / 200.0),
            Float((bodyTemperature - 30.0) / 15.0),
            Float(oxygenSaturation / 100.0),
        ]
    }

    public static func build(from heartRate: Double?, bodyTemperature: Double?, oxygenSaturation: Double?) -> [Float]? {
        guard let hr = heartRate, let temp = bodyTemperature, let spo2 = oxygenSaturation else {
            return nil
        }
        return normalize(heartRate: hr, bodyTemperature: temp, oxygenSaturation: spo2)
    }
}