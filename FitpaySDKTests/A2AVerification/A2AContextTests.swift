import XCTest
@testable import FitpaySDK

class A2AContextTests: XCTestCase {
    
    func testCreatingModelFromDictionary() {
        let testJSON: [String: Any] = ["applicationId": "123456789"]
        
        guard let a2aContext = try? A2AContext(testJSON) else {
            XCTFail()
            return
        }
        
        XCTAssert(a2aContext.applicationId == "")
        XCTAssert(a2aContext.action == "")
        XCTAssert(a2aContext.payload == "")

    }
    
}

