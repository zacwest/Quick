#if canImport(Darwin) && !SWIFT_PACKAGE

import Nimble
@testable import Quick
import XCTest

// The regression tests for https://github.com/Quick/Quick/issues/891

class SimulateSelectedTests_TestCase: QuickSpec {
    override class var defaultTestSuite: QuickTestSuite {
        // XCTest doesn't call `defaultTestSuite` when running only selected tests.
        // We simulate this behavior by not calling super.
        return .init(name: "Selected tests")
    }

    override func spec() {
        it("example1") { }
        it("example2") { }
        it("example3") { }
    }
}

class SimulareAllTests_TestCase: QuickSpec {
    override func spec() {
        it("example1") { }
        it("example2") { }
        it("example3") { }
    }
}

class SimulateNotQuickSpec_TestCase: XCTestCase {
    func testAnyTestExists() {

    }

    func testDifferentTestCase() {

    }
}

class QuickSpec_SelectedTests: XCTestCase {
    func testQuickSpecTestInvocationsForAllTests() {
        // Simulate running 'All tests'
        let invocations = SimulareAllTests_TestCase.testInvocations
        expect(invocations).to(haveCount(3))

        let selectorNames = invocations.map { $0.selector.description }
        expect(selectorNames).to(contain(["example1", "example2", "example3"]))
    }

    func testQuickSpecTestInvocationsForSelectedTests() {
        // Simulate running 'Selected tests'
        let invocations = SimulateSelectedTests_TestCase.testInvocations
        expect(invocations).to(haveCount(3))

        let selectorNames = invocations.map { $0.selector.description }
        expect(selectorNames).to(contain(["example1", "example2", "example3"]))
    }

    func testNotQuickSpecInvokesRequestedTestCase() {
        guard let moduleName = Bundle.currentTestBundle?.moduleName else {
            XCTFail("couldn't find module name-ful test bundle")
            return
        }

        let nonQuickSuiteOnlyOne = XCTestSuite(forTestCaseWithName: "\(moduleName).SimulateNotQuickSpec_TestCase/testAnyTestExists")
        let nonQuickSuiteAll = XCTestSuite(forTestCaseWithName: "\(moduleName).SimulateNotQuickSpec_TestCase")
        let quickSuite = XCTestSuite(forTestCaseWithName: "\(moduleName).SimulateSelectedTests_TestCase")

        expect(nonQuickSuiteOnlyOne.tests).to(haveCount(1), description: "we only ask for one test case to be run")
        expect(nonQuickSuiteAll.tests).to(haveCount(2), description: "we ask for all to be run")
        expect(quickSuite.tests).toNot(beEmpty())
    }
}

#endif
