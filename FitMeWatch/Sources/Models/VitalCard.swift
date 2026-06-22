import SwiftUI

struct VitalCard: Identifiable {
    let id = UUID()
    let title: String
    var value: String
    let unit: String
    let icon: String
    let color: Color
    var status: VitalStatus
    var source: DataSource
    let summary: VitalSummary

    func withLiveValue(_ newValue: String, status: VitalStatus) -> VitalCard {
        var copy = self
        copy.value = newValue
        copy.status = status
        copy.source = .sensor
        return copy
    }

    static let mockData: [VitalCard] = [
        VitalCard(
            title: "Heart Rate",
            value: "72",
            unit: "bpm",
            icon: "heart.fill",
            color: .red,
            status: .normal,
            source: .mock,
            summary: VitalSummary(
                whatItMeans: "Your heart beats 72 times per minute at rest. Normal resting HR is 60–100 bpm.",
                riskLevel: "Low",
                riskScore: 15,
                riskColor: .green,
                relatedConditions: [
                    "Bradycardia (<60 bpm) — slow heart rate, can be normal in athletes",
                    "Tachycardia (>100 bpm) — fast heart rate, may signal stress or infection",
                    "Arrhythmia — irregular rhythm, watch for palpitations",
                ],
                recommendation: "Your heart rate is healthy. Keep up regular cardio exercise."
            )
        ),
        VitalCard(
            title: "Body Temp",
            value: "36.7",
            unit: "°C",
            icon: "thermometer",
            color: .orange,
            status: .normal,
            source: .mock,
            summary: VitalSummary(
                whatItMeans: "36.7°C is a normal body temperature. Fever starts at 38.0°C.",
                riskLevel: "Low",
                riskScore: 8,
                riskColor: .green,
                relatedConditions: [
                    "Fever (≥38°C) — body fighting infection",
                    "Hyperthermia (>40°C) — medical emergency, seek help",
                    "Hypothermia (<35°C) — dangerous cooling, get warm",
                ],
                recommendation: "Temperature looks great. Stay hydrated and monitor if you feel unwell."
            )
        ),
        VitalCard(
            title: "Blood Pressure",
            value: "120/80",
            unit: "mmHg",
            icon: "stethoscope",
            color: .blue,
            status: .normal,
            source: .mock,
            summary: VitalSummary(
                whatItMeans: "120/80 mmHg is optimal. Systolic (top) should be under 130, diastolic (bottom) under 80.",
                riskLevel: "Low",
                riskScore: 12,
                riskColor: .green,
                relatedConditions: [
                    "Hypertension Stage 1 (130–139/80–89) — lifestyle changes needed",
                    "Hypertension Stage 2 (≥140/90) — medication may be required",
                    "Hypotension (<90/60) — can cause dizziness or fainting",
                ],
                recommendation: "Blood pressure is in the optimal range. Limit salt and stay active."
            )
        ),
        VitalCard(
            title: "SpO₂",
            value: "98",
            unit: "%",
            icon: "lungs.fill",
            color: .cyan,
            status: .normal,
            source: .mock,
            summary: VitalSummary(
                whatItMeans: "98% oxygen saturation is excellent. Normal is 95–100%.",
                riskLevel: "Low",
                riskScore: 5,
                riskColor: .green,
                relatedConditions: [
                    "Hypoxemia (<90%) — low blood oxygen, seek medical attention",
                    "Sleep apnea — drops in SpO₂ during sleep, monitor overnight",
                    "COPD / asthma — chronic low SpO₂, manage with inhaler",
                ],
                recommendation: "Oxygen levels are perfect. Keep lungs healthy — avoid smoking."
            )
        ),
        VitalCard(
            title: "Respiratory Rate",
            value: "16",
            unit: "breaths/min",
            icon: "wind",
            color: .teal,
            status: .normal,
            source: .mock,
            summary: VitalSummary(
                whatItMeans: "16 breaths per minute is normal for an adult at rest (12–20 rpm).",
                riskLevel: "Low",
                riskScore: 6,
                riskColor: .green,
                relatedConditions: [
                    "Bradypnea (<12 rpm) — slow breathing, can indicate fatigue or medication effects",
                    "Tachypnea (>20 rpm) — fast breathing, may signal fever or infection",
                    "Sleep apnea — irregular breathing during sleep",
                ],
                recommendation: "Breathing rate is healthy. Practice deep breathing for stress relief."
            )
        ),
        VitalCard(
            title: "Heart Rate Variability",
            value: "48",
            unit: "ms",
            icon: "waveform.path.ecg",
            color: .purple,
            status: .normal,
            source: .mock,
            summary: VitalSummary(
                whatItMeans: "HRV of 48ms measures the variation between heartbeats. Higher is generally better.",
                riskLevel: "Low",
                riskScore: 10,
                riskColor: .green,
                relatedConditions: [
                    "Low HRV (<20ms) — linked to stress, fatigue, or overtraining",
                    "High HRV (>100ms) — excellent recovery, strong autonomic balance",
                    "Dropping HRV trend — may signal onset of illness",
                ],
                recommendation: "Good HRV. Prioritize sleep and manage stress to keep it high."
            )
        ),
        VitalCard(
            title: "Steps",
            value: "8,420",
            unit: "count",
            icon: "figure.walk",
            color: .green,
            status: .normal,
            source: .mock,
            summary: VitalSummary(
                whatItMeans: "8,420 steps today — close to the 10,000 recommended daily target.",
                riskLevel: "Low",
                riskScore: 10,
                riskColor: .green,
                relatedConditions: [
                    "Sedentary lifestyle (<4,000) — increased cardiovascular risk",
                    "Obesity risk — low activity contributes to weight gain",
                    "Joint health — moderate walking reduces stiffness",
                ],
                recommendation: "Almost at your goal! A short walk will get you there."
            )
        ),
        VitalCard(
            title: "Active Energy",
            value: "420",
            unit: "kcal",
            icon: "flame.fill",
            color: .pink,
            status: .normal,
            source: .mock,
            summary: VitalSummary(
                whatItMeans: "420 kcal burned through activity today. Target is typically 500–600 kcal.",
                riskLevel: "Low",
                riskScore: 12,
                riskColor: .green,
                relatedConditions: [
                    "Low burn (<200) — sedentary day, try to move more",
                    "Overtraining (>1000) — risk of injury, ensure recovery",
                    "Metabolic health — consistent burn improves insulin sensitivity",
                ],
                recommendation: "Good activity. A brisk walk will close your move ring."
            )
        ),
        VitalCard(
            title: "Sleep",
            value: "7.5",
            unit: "hours",
            icon: "moon.fill",
            color: .indigo,
            status: .normal,
            source: .mock,
            summary: VitalSummary(
                whatItMeans: "7.5 hours of sleep is within the recommended 7–9 hour range.",
                riskLevel: "Low",
                riskScore: 18,
                riskColor: .green,
                relatedConditions: [
                    "Sleep deprivation (<6h) — impairs immunity and cognition",
                    "Insomnia — difficulty falling or staying asleep",
                    "Sleep apnea — pauses in breathing, linked to heart disease",
                ],
                recommendation: "Great sleep duration. Aim for a consistent bedtime."
            )
        ),
    ]
}

enum DataSource {
    case mock
    case sensor
    case manual

    var label: String {
        switch self {
        case .mock:   "Mock"
        case .sensor: "Live"
        case .manual: "Manual"
        }
    }

    var icon: String {
        switch self {
        case .mock:   "circle.dashed"
        case .sensor: "dot.radiowaves.left.and.right"
        case .manual: "hand.tap"
        }
    }
}

enum VitalStatus {
    case low, normal, elevated, high

    var label: String {
        switch self {
        case .low:      "Low"
        case .normal:   "Normal"
        case .elevated:  "Elevated"
        case .high:      "High"
        }
    }

    var color: Color {
        switch self {
        case .low:      .blue
        case .normal:   .green
        case .elevated: .orange
        case .high:     .red
        }
    }
}

struct VitalSummary {
    let whatItMeans: String
    let riskLevel: String
    let riskScore: Int
    let riskColor: Color
    let relatedConditions: [String]
    let recommendation: String
}