import Foundation
import Observation

@MainActor
@Observable
final class SensorViewModel {

    var cards: [VitalCard] = []
    var isLive: Bool = false
    var isRefreshing: Bool = false
    var authorizationNeeded: Bool = false

    private let healthKit = HealthKitManager.shared
    private var refreshTimer: Timer?

    init() {
        loadMockData()
    }

    func loadMockData() {
        isLive = false
        cards = VitalCard.mockData
    }

    func requestHealthKitAndLoad() async {
        guard healthKit.isHealthDataAvailable else {
            authorizationNeeded = true
            loadMockData()
            return
        }

        await healthKit.requestAuthorization()

        if healthKit.isAuthorized {
            isLive = true
            authorizationNeeded = false
            healthKit.startLiveQueries()
            await refreshAll()
            startAutoRefresh()
        } else {
            authorizationNeeded = true
            loadMockData()
        }
    }

    func refreshAll() async {
        isRefreshing = true
        defer { isRefreshing = false }

        let readings = healthKit.currentSensorReadings()
        let steps = await healthKit.fetchStepsToday()
        let energy = await healthKit.fetchActiveEnergyToday()
        let sleep = await healthKit.fetchSleepHoursLastNight()

        var updated: [VitalCard] = []

        for var card in VitalCard.mockData {
            switch card.title {
            case "Heart Rate":
                if let hr = readings.heartRate {
                    card = card.withLiveValue(String(Int(hr)), status: Self.hrStatus(hr))
                }
            case "Heart Rate Variability":
                if let hrv = readings.heartRateVariability {
                    card = card.withLiveValue(String(Int(hrv)), status: Self.hrvStatus(hrv))
                }
            case "Body Temp":
                if let temp = readings.wristTemperature {
                    card = card.withLiveValue(String(format: "%.1f", temp), status: Self.tempStatus(temp))
                }
            case "SpO₂":
                if let spo2 = readings.oxygenSaturation {
                    card = card.withLiveValue(String(Int(spo2)), status: Self.spo2Status(spo2))
                }
            case "Respiratory Rate":
                if let rr = readings.respiratoryRate {
                    card = card.withLiveValue(String(Int(rr)), status: Self.respStatus(rr))
                }
            case "Steps":
                card = card.withLiveValue(Self.formatted(Int(steps)), status: .normal)
            case "Active Energy":
                card = card.withLiveValue(String(Int(energy)), status: .normal)
            case "Sleep":
                if sleep > 0 {
                    card = card.withLiveValue(String(format: "%.1f", sleep), status: .normal)
                }
            default:
                break
            }
            updated.append(card)
        }

        cards = updated.isEmpty ? VitalCard.mockData : updated
    }

    private func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            Task { @MainActor in await self?.refreshAll() }
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }

    static func hrStatus(_ bpm: Double) -> VitalStatus {
        switch bpm {
        case ..<50:     .low
        case 60..<100:  .normal
        case 100..<120: .elevated
        default:        .high
        }
    }

    static func hrvStatus(_ ms: Double) -> VitalStatus {
        switch ms {
        case ..<20:     .high
        case 20..<40:   .elevated
        case 40..<100:  .normal
        default:        .low
        }
    }

    static func tempStatus(_ c: Double) -> VitalStatus {
        switch c {
        case ..<35:         .low
        case 35..<37.5:    .normal
        case 37.5..<38:    .elevated
        default:           .high
        }
    }

    static func spo2Status(_ pct: Double) -> VitalStatus {
        switch pct {
        case ..<90:    .high
        case 90..<95:  .elevated
        default:       .normal
        }
    }

    static func respStatus(_ rpm: Double) -> VitalStatus {
        switch rpm {
        case ..<12:    .low
        case 12..<20:  .normal
        case 20..<25:  .elevated
        default:        .high
        }
    }

    static func formatted(_ n: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}