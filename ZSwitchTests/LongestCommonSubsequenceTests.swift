import Foundation
import XCTest

class LongestCommonSubsequenceTests: XCTestCase {
    
    func testLcsDistance() {
        let a = "ABCED"
        let b = "ACBED"
        
        XCTAssertEqual(0, a.lcsDistance(a))
        XCTAssertEqual(0, "".lcsDistance(""))
        XCTAssertEqual(2, "ABC".lcsDistance("DEF"))
        XCTAssertTrue(0.2 - a.lcsDistance(b) < 0.00001)
        XCTAssertTrue(0.2 - b.lcsDistance(a) < 0.00001)
        XCTAssertTrue("app".lcsDistance("AppStore") < "app".lcsDistance("Base"))
    }

    func testLCSwithSelfIsSelf() {
        let a = "ABCDE"

        XCTAssertEqual(a, a.longestCommonSubsequence(a))
    }

    func testLCSWithEmptyStringIsEmptyString() {
        let a = "ABCDE"

        XCTAssertEqual("", a.longestCommonSubsequence(""))
    }

    func testLCSIsEmptyWhenNoCharMatches() {
        let a = "ABCDE"
        let b = "WXYZ"

        XCTAssertEqual("", a.longestCommonSubsequence(b))
    }

    func testLCSIsNotCommutative() {
        let a = "ABCDEF"
        let b = "XAWDMVBEKD"

        XCTAssertEqual("ADE", a.longestCommonSubsequence(b))
        XCTAssertEqual("ABD", b.longestCommonSubsequence(a))
    }
}
