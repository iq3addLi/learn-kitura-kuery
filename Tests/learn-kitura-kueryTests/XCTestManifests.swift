import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(learn_kitura_kueryTests.allTests),
    ]
}
#endif
