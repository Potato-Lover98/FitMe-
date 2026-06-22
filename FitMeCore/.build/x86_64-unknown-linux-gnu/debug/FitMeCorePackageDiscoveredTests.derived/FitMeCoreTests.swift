import XCTest
@testable import FitMeCoreTests

fileprivate extension MLTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__MLTests = [
        ("testFeatureBuilder_buildNil", testFeatureBuilder_buildNil),
        ("testFeatureBuilder_normalize", testFeatureBuilder_normalize),
        ("testFitMeML_evaluate", testFitMeML_evaluate),
        ("testModel_deterministic", testModel_deterministic),
        ("testModel_forwardPassHighRisk", testModel_forwardPassHighRisk),
        ("testModel_forwardPassMediumRisk", testModel_forwardPassMediumRisk),
        ("testModel_forwardPassNormal", testModel_forwardPassNormal),
        ("testModel_loadsSuccessfully", testModel_loadsSuccessfully),
        ("testPostProcessor_band", testPostProcessor_band),
        ("testPostProcessor_output", testPostProcessor_output)
    ]
}

fileprivate extension ModelTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__ModelTests = [
        ("testFeverRisk_bands", testFeverRisk_bands),
        ("testFeverRisk_scoreClamped", testFeverRisk_scoreClamped),
        ("testGoal_periodsExist", testGoal_periodsExist),
        ("testReading_encodeDecode", testReading_encodeDecode),
        ("testUser_bmiCalculation", testUser_bmiCalculation),
        ("testVitalType_allCasesExist", testVitalType_allCasesExist),
        ("testVitalType_displayNameNonEmpty", testVitalType_displayNameNonEmpty)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __FitMeCoreTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MLTests.__allTests__MLTests),
        testCase(ModelTests.__allTests__ModelTests)
    ]
}