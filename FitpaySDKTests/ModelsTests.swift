
//
//  ModelsTests.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 05.02.2018.
//  Copyright © 2018 Fitpay. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import FitpaySDK

class TransactionTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testParsingDecimalValue() {
        let json = "{\"amount\": 0.691}"
        let transaction = Transaction(JSONString: json)
        
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction!.amount?.description ?? "", "0.691")
    }
}
