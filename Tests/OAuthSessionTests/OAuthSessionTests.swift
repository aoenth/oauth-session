import XCTest
@testable import OAuthSession

final class OAuthSessionTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(OAuthSession().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
