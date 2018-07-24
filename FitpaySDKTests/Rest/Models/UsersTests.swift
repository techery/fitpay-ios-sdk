//import XCTest
//@testable import FitpaySDK
//
//class UsersTests: BaseTestProvider {
//    
//    var user: User!
//    var restClient: RestClient!
//    var testHelper: TestHelper!
//
//    override func setUp() {
//        let session = RestSession()
//        restClient = RestClient(session: session)
//        testHelper = TestHelper(session: session, client: restClient)
//        
//        FitpayConfig.clientId = "fp_webapp_pJkVp2Rl"
//        FitpayConfig.apiURL = "https://api.fit-pay.com"
//        FitpayConfig.authURL = "https://auth.fit-pay.com"
//        
//    
//        let expectation = self.expectation(description: "setUp")
//
//        testHelper.createAndLoginUser(expectation) { [unowned self] user ina
//            self.user = user
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 2, handler: nil)
//    }
//    
//    override func tearDown() {
//        let expectation = self.expectation(description: "tearDown")
//
//        user.deleteUser { (error) in
//            if error != nil {
//                XCTFail("error deleting user")
//            }
//            
//            expectation.fulfill()
//        }
//        
//        waitForExpectations(timeout: 20, handler: nil)
//    }
//    
//    func testUserParsing() {
//        let user = mockModels.getUser()
//
//        XCTAssertNotNil(user?.links)
//        XCTAssertEqual(user?.id, mockModels.someId)
//        XCTAssertEqual(user?.created, mockModels.someDate)
//        XCTAssertEqual(user?.createdEpoch, NSTimeIntervalTypeTransform().transform(mockModels.timeEpoch))
//        XCTAssertEqual(user?.lastModified, mockModels.someDate)
//        XCTAssertEqual(user?.lastModifiedEpoch, NSTimeIntervalTypeTransform().transform(mockModels.timeEpoch))
//        XCTAssertEqual(user?.encryptedData, "some data")
//
//        let json = user?.toJSON()
//        XCTAssertNotNil(json?["_links"])
//        XCTAssertEqual(json?["id"] as? String, mockModels.someId)
//        XCTAssertEqual(json?["createdTs"] as? String, mockModels.someDate)
//        XCTAssertEqual(json?["createdTsEpoch"] as? Int64, mockModels.timeEpoch)
//        XCTAssertEqual(json?["lastModifiedTs"] as? String, mockModels.someDate)
//        XCTAssertEqual(json?["lastModifiedTsEpoch"] as? Int64, mockModels.timeEpoch)
//        XCTAssertEqual(json?["encryptedData"] as? String, "some data")
//    }
//    
//    func testGetCreditCards() {
//        let expectation = self.expectation(description: "getCreditCards")
//
//        //TODO
////        user?.getCreditCards(excludeState: [], limit: 10, offset: 0, deviceId: "1234") { (creditCardCollection, error) in
////            XCTAssertEqual(self.restClient.lastCalledParams?["deviceId"] as? String, "1234")
////            expectation.fulfill()
////        }
//        
//        waitForExpectations(timeout: 2, handler: nil)
//    }
//    
//}
