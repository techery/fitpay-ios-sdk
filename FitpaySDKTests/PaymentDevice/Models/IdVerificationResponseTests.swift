import XCTest

@testable import FitpaySDK

class IdVerificationResponseTests: XCTestCase {

    func testEmptyInitializerSetsLocale() {
        let verificationResponse = IdVerificationResponse()
        
        XCTAssertEqual(verificationResponse.locale, "en-US")
    }
    
    func testLocaleIsIncludedInJSON() {
        let verificationResponse = IdVerificationResponse()
        
        //locale is private so we will test the json output
        let verificationResonseJson = verificationResponse.toJSON()
        
        XCTAssertEqual(verificationResonseJson?["locale"] as? String, "en-US")
    }
    
    func testLocaleNotOverridenWithJsonInitializer() {
        let verificationResponse = try? IdVerificationResponse(["locale": "wrong"])
        
        XCTAssertNotNil(verificationResponse)
        XCTAssertEqual(verificationResponse!.locale, "en-US")
    }

}
