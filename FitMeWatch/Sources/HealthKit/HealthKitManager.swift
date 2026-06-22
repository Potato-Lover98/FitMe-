import Foundation
import HealthKit
import os.log

@MainActor
final class HealthKitManager: ObservableObject {

    static let shared = HealthKitManager()

    private let store = HKHealthStore()
    private let logger = Logger(subsystem: "com.fitme.watch", category: "HealthKit")

    @Published var isAuthorized = false
    @Published var authorizationError: String?

    private var activeQueries: [HKQuery] = []
    private var liveHeartRate: Double?
    private var liveHRV: Double?
    private var liveSpO2: Double?
    private var liveRespRate: Double?
    private var liveWristTemp: Double?

    private let allTypes: [HKQuantityType] = [
        HKQuantityType(.heartRate),
        HKQuantityType(.heartRateVariabilitySDNN),
        HKQuantityType(.oxygenSaturation),
        HKQuantityType(.respiratoryRate),
        HKQuantityType(.bodyTemperature),
        HKQuantityType(.stepCount),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.appleSleepingWristTemperature),
    ]

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async {
        guard isHealthDataAvailable else {
            authorizationError = "HealthKit not available on this device"
            logger.error("HealthKit not available")
            return
        }

        let readTypes: Set<HKObjectType> = Set(allTypes.map { $0 as HKObjectType })
        let writeTypes: Set<HKSampleType> = []

        do {
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
            await MainActor.run {
                self.isAuthorized = true
                self.logger.info("HealthKit authorization granted")
            }
        } catch {
            await MainActor.run {
                self.authorizationError = error.localizedDescription
                self.logger.error("HealthKit auth failed: \(error.localizedDescription)")
            }
        }
    }

    func startLiveQueries() {
        guard isAuthorized else { return }
        startHeartRateQuery()
        startHRVQuery()
        startSpO2Query()
        startRespRateQuery()
        startWristTempQuery()
    }

    func stopAllQueries() {
        activeQueries.forEach { store.stop($0) }
        activeQueries.removeAll()
    }

    private func startHeartRateQuery() {
        let type = HKQuantityType(.heartRate)
        let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, _, _ in
            self?.fetchLatestValue(type: type, unit: .count().unitDivided(by: .minute())) { value in
                Task { @MainActor in self?.liveHeartRate = value }
            }
        }
        store.execute(query)
        activeQueries.append(query)
    }

    private func startHRVQuery() {
        let type = HKQuantityType(.heartRateVariabilitySDNN)
        let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, _, _ in
            self?.fetchLatestValue(type: type, unit: .secondUnit(with: .milli)) { value in
                Task { @MainActor in self?.liveHRV = value }
            }
        }
        store.execute(query)
        activeQueries.append(query)
    }

    private func startSpO2Query() {
        let type = HKQuantityType(.oxygenSaturation)
        let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, _, _ in
            self?.fetchLatestValue(type: type, unit: .percent()) { value in
                Task { @MainActor in self?.liveSpO2 = value * 100 }
            }
        }
        store.execute(query)
        activeQueries.append(query)
    }

    private func startRespRateQuery() {
        let type = HKQuantityType(.respiratoryRate)
        let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, _, _ in
            self?.fetchLatestValue(type: type, unit: .count().unitDivided(by: .minute())) { value in
                Task { @MainActor in self?.liveRespRate = value }
            }
        }
        store.execute(query)
        activeQueries.append(query)
    }

    private func startWristTempQuery() {
        let type = HKQuantityType(.appleSleepingWristTemperature)
        let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, _, _ in
            self?.fetchLatestValue(type: type, unit: .degreeCelsius()) { value in
                Task { @MainActor in self?.liveWristTemp = value }
            }
        }
        store.execute(query)
        activeQueries.append(query)
    }

    private func fetchLatestValue(type: HKQuantityType, unit: HKUnit, completion: @escaping (Double) -> Void) {
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            let value = sample.quantity.doubleValue(for: unit)
            completion(value)
        }
        store.execute(query)
    }

    func fetchStepsToday() async -> Double {
        await fetchCumulative(type: .stepCount, unit: .count())
    }

    func fetchActiveEnergyToday() async -> Double {
        await fetchCumulative(type: .activeEnergyBurned, unit: .kilocalorie())
    }

    func fetchSleepHoursLastNight() async -> Double {
        let type = HKCategoryType(.sleepAnalysis)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                guard let sample = samples?.first as? HKCategorySample else {
                    continuation.resume(returning: 0)
                    return
                }
                let hours = sample.endDate.timeIntervalSince(sample.startDate) / 3600
                continuation.resume(returning: hours)
            }
            store.execute(query)
        }
    }

    private func fetchCumulative(type: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: HKQuantityType(type),
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                completionHandler: { _, stats, _ in
                    let value = stats?.sumQuantity()?.doubleValue(for: unit) ?? 0
                    continuation.resume(returning: value)
                }
            )
            store.execute(query)
        }
    }

    func currentSensorReadings() -> SensorReadings {
        SensorReadings(
            heartRate: liveHeartRate,
            heartRateVariability: liveHRV,
            oxygenSaturation: liveSpO2,
            respiratoryRate: liveRespRate,
            wristTemperature: liveWristTemp
        )
    }
}

struct SensorReadings {
    let heartRate: Double?
    let heartRateVariability: Double?
    let oxygenSaturation: Double?
    let respiratoryRate: Double?
    let wristTemperature: Double?

    var hasAnyLive: Bool {
        heartRate != nil || heartRateVariability != nil || oxygenSaturation != nil || respiratoryRate != nil || wristTemperature != nil
    }
}