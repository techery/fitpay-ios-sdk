//
//  TestKeyedDecodingContainer.swift
//  FitpaySDK
//
//  Created by Illya Kyznetsov on 7/2/18.
//  Copyright © 2018 Fitpay. All rights reserved.
//

import XCTest
@testable import FitpaySDK

class DataExtensionsTests: BaseTestProvider {

    func testBase64URLencoded() {
        let payloadIV = String.random(JWEObject.PayloadIVSize).data(using: String.Encoding.utf8)
        guard let encodedPayloadIV = payloadIV?.base64URLencoded() else {
            XCTAssert(false, "Bad encoding")
            return
        }

        XCTAssertFalse(encodedPayloadIV.contains("/"))
    }

    func testreverseEndian() {
        let original = PAYMENT_CHARACTERISTIC_UUID_APDU_CONTROL.data
        let reversed = original.reverseEndian
        XCTAssertTrue(original.first == reversed.last)
    }

    func testErrorMessage() {
        let errorJSON = "{\"message\":\"The property termsVersion contains an invalid value (null): may not be empty\"}"
        let errorData = errorJSON.data(using: .utf8)
        let errorMessage = errorData?.errorMessage
        XCTAssertEqual(errorMessage, "The property termsVersion contains an invalid value (null): may not be empty")
    }

    func testErrorMessages() {
        let errorsJSON = "{\"errors\": [{\"message\":\"The property termsVersion contains an invalid value (null): may not be empty\"}]}"
        let errorsData = errorsJSON.data(using: .utf8)
        let errorMessages = errorsData?.errorMessages
        XCTAssertEqual(errorMessages?.first, "The property termsVersion contains an invalid value (null): may not be empty")
    }

    func testUTF8String() {
        let string = "The property termsVersion contains an invalid value (null): may not be empty"
        let utf32Data = string.data(using: String.Encoding.utf32)
        let utf8Data = string.data(using: String.Encoding.utf8)
        XCTAssertEqual(string, utf8Data?.UTF8String)
        XCTAssertNotEqual(string, utf32Data?.UTF8String)
    }
}
