import Foundation

public enum VitalType: String, Codable, CaseIterable, Sendable {
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case bodyTemperature
    case heartRate
    case heartRateVariability
    case oxygenSaturation
    case respiratoryRate
    case bloodGlucose
    case weight
    case bodyFatPercentage
    case sleep
    case steps
    case activeEnergy
    case hydration
    case mood
    case stress

    public var displayName: String {
        switch self {
        case .bloodPressureSystolic:   "Blood Pressure (Systolic)"
        case .bloodPressureDiastolic:   "Blood Pressure (Diastolic)"
        case .bodyTemperature:          "Body Temperature"
        case .heartRate:                "Heart Rate"
        case .heartRateVariability:     "Heart Rate Variability"
        case .oxygenSaturation:         "Oxygen Saturation (SpO₂)"
        case .respiratoryRate:          "Respiratory Rate"
        case .bloodGlucose:             "Blood Glucose"
        case .weight:                   "Weight"
        case .bodyFatPercentage:        "Body Fat %"
        case .sleep:                    "Sleep"
        case .steps:                    "Steps"
        case .activeEnergy:             "Active Energy"
        case .hydration:                "Hydration"
        case .mood:                     "Mood"
        case .stress:                   "Stress"
        }
    }

    public var unit: String {
        switch self {
        case .bloodPressureSystolic:   "mmHg"
        case .bloodPressureDiastolic:   "mmHg"
        case .bodyTemperature:          "°C"
        case .heartRate:                "bpm"
        case .heartRateVariability:     "ms"
        case .oxygenSaturation:         "%"
        case .respiratoryRate:          "breaths/min"
        case .bloodGlucose:             "mg/dL"
        case .weight:                   "kg"
        case .bodyFatPercentage:        "%"
        case .sleep:                    "hours"
        case .steps:                    "count"
        case .activeEnergy:             "kcal"
        case .hydration:                "mL"
        case .mood:                     "score"
        case .stress:                   "score"
        }
    }
}