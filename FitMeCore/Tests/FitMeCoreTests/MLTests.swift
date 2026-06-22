import XCTest
@testable import FitMeCore

final class MLTests: XCTestCase {

    var model: MLPModel!

    override func setUp() async throws {
        guard let url = Bundle.module.url(forResource: "FitMeML", withExtension: "bin") else {
            XCTFail("FitMeML.bin not found in test bundle")
            return
        }
        model = try ModelLoader.load(from: url)
    }

    func testModel_loadsSuccessfully() {
        XCTAssertNotNil(model)
        XCTAssertEqual(model.dims, [3, 16, 1])
        XCTAssertEqual(model.numInputs, 3)
        XCTAssertEqual(model.numOutputs, 1)
    }

    func testModel_forwardPassNormal() {
        let input: [Float] = [72 / 200.0, (36.7 - 30) / 15.0, 98 / 100.0]
        let output = Inferencer.predict(model: model, input: input)
        let score = PostProcessor.riskScore(output)
        let band = PostProcessor.band(output)
        XCTAssertGreaterThan(score, 0)
        XCTAssertLessThan(score, 50)
        XCTAssertEqual(band, .low)
    }

    func testModel_forwardPassHighRisk() {
        let input: [Float] = [140 / 200.0, (40.0 - 30) / 15.0, 84 / 100.0]
        let output = Inferencer.predict(model: model, input: input)
        let score = PostProcessor.riskScore(output)
        let band = PostProcessor.band(output)
        XCTAssertGreaterThan(score, 50)
        XCTAssertEqual(band, .high)
    }

    func testModel_forwardPassMediumRisk() {
        let input: [Float] = [110 / 200.0, (38.5 - 30) / 15.0, 92 / 100.0]
        let output = Inferencer.predict(model: model, input: input)
        let score = PostProcessor.riskScore(output)
        let band = PostProcessor.band(output)
        XCTAssertGreaterThan(score, 20)
        XCTAssertLessThan(score, 80)
    }

    func testModel_deterministic() {
        let input: [Float] = [72 / 200.0, (36.7 - 30) / 15.0, 98 / 100.0]
        let r1 = Inferencer.predict(model: model, input: input)
        let r2 = Inferencer.predict(model: model, input: input)
        XCTAssertEqual(r1, r2)
    }

    func testFeatureBuilder_normalize() {
        let features = FeatureBuilder.normalize(heartRate: 72, bodyTemperature: 36.7, oxygenSaturation: 98)
        XCTAssertEqual(features[0], 0.36, accuracy: 0.001)
        XCTAssertEqual(features[1], 0.4467, accuracy: 0.001)
        XCTAssertEqual(features[2], 0.98, accuracy: 0.001)
    }

    func testFeatureBuilder_buildNil() {
        let result = FeatureBuilder.build(from: 72, bodyTemperature: nil, oxygenSaturation: 98)
        XCTAssertNil(result)
    }

    func testPostProcessor_band() {
        XCTAssertEqual(PostProcessor.bandFromScore(10), .low)
        XCTAssertEqual(PostProcessor.bandFromScore(50), .medium)
        XCTAssertEqual(PostProcessor.bandFromScore(90), .high)
    }

    func testPostProcessor_output() {
        let output = PostProcessor.process(0.15)
        XCTAssertEqual(output.score, 15, accuracy: 0.001)
        XCTAssertEqual(output.band, .low)
    }

    func testFitMeML_evaluate() throws {
        try FitMeML.load(from: Bundle.module.url(forResource: "FitMeML", withExtension: "bin")!)
        XCTAssertTrue(FitMeML.isLoaded)

        let result = FitMeML.evaluate(heartRate: 72, bodyTemperature: 36.7, oxygenSaturation: 98)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.band, .low)

        let desc = FitMeML.riskDescription(heartRate: 140, bodyTemperature: 40.0, oxygenSaturation: 84)
        XCTAssertTrue(desc.contains("HIGH"))
    }
}