import XCTest
@testable import FitMeCore

final class ModelTests: XCTestCase {

    func testVitalType_allCasesExist() {
        XCTAssertGreaterThan(VitalType.allCases.count, 10)
        XCTAssertTrue(VitalType.allCases.contains(.bodyTemperature))
        XCTAssertTrue(VitalType.allCases.contains(.heartRate))
    }

    func testVitalType_displayNameNonEmpty() {
        for v in VitalType.allCases {
            XCTAssertFalse(v.displayName.isEmpty)
            XCTAssertFalse(v.unit.isEmpty)
        }
    }

    func testReading_encodeDecode() throws {
        let reading = Reading(vitalType: .bodyTemperature, value: 38.2, unit: "°C", source: .manual, date: Date())
        let data = try JSONEncoder().encode(reading)
        let decoded = try JSONDecoder().decode(Reading.self, from: data)
        XCTAssertEqual(reading, decoded)
    }

    func testUser_bmiCalculation() {
        let user = User(name: "Test", age: 30, biologicalSex: .male, heightCm: 180, weightKg: 80)
        XCTAssertEqual(user.bmi, 80.0 / (1.8 * 1.8), accuracy: 0.01)
    }

    func testGoal_periodsExist() {
        XCTAssertTrue(GoalPeriod.allCases.contains(.daily))
        XCTAssertTrue(GoalPeriod.allCases.contains(.weekly))
    }

    func testFeverRisk_scoreClamped() {
        let risk = FeverRisk(score: 150, contributingFactors: [])
        XCTAssertLessThanOrEqual(risk.score, 100)
        XCTAssertEqual(risk.band, .high)
    }

    func testFeverRisk_bands() {
        XCTAssertEqual(RiskBand.from(score: 10), .low)
        XCTAssertEqual(RiskBand.from(score: 50), .medium)
        XCTAssertEqual(RiskBand.from(score: 90), .high)
    }
}