import XCTest
@testable import FitpaySDK

class TransformTests: XCTestCase {
    
    func testNSTimeIntervalToInt() {
        let currentTime = Date().timeIntervalSince1970
        let timeTransform = NSTimeIntervalTypeTransform()
        
        guard let timeAsInt = timeTransform.transform(currentTime) else {
            XCTAssert(false, "Can't get int value for time.")
            return
        }

        let intMirror = Mirror(reflecting: timeAsInt)
        
        XCTAssert(String(describing: intMirror.subjectType) == "Int64")
    }

}

