import XCTest
@testable import FitpaySDK

class RelationshipTests: BaseTestProvider {
        
    func testRelationshipParsing() {
        let relationship = mockModels.getRelationship()

        XCTAssertNotNil(relationship?.links)
        XCTAssertNotNil(relationship?.card)
        XCTAssertNotNil(relationship?.device)

        let json = relationship?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["card"])
        XCTAssertNotNil(json?["device"])
    }
}
