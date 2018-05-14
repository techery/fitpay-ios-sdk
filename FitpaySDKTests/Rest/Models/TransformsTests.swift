import XCTest
@testable import FitpaySDK

class TransformTests: XCTestCase {
    
    func testNSTimeIntervalToInt() {
        let expectation = super.expectation(description: "NSTimeInterval converted to int correctly")
        
        let currentTime = Date().timeIntervalSince1970
        let timeTransform = NSTimeIntervalTypeTransform()
        guard let timeAsInt = timeTransform.transform(currentTime) else {
            XCTAssert(false, "Can't get int value for time.")
            return
        }
        
        let intMirror = Mirror(reflecting: timeAsInt)
        debugPrint(String(describing: intMirror.subjectType))
        XCTAssertTrue(String(describing: intMirror.subjectType) == "Int64")
        
        expectation.fulfill()
        
        super.waitForExpectations(timeout: 10, handler: nil)
    }

}

