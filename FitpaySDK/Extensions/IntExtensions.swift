//
//  IntExtensions.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 13.04.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation

extension Int {
    func hex(charsLength: Int) -> String {
        var result = String(format: "%X", self)
        let resultSize = result.characters.count
        if resultSize < charsLength {
            for _ in resultSize..<charsLength {
                result = "0" + result
            }
        }
        return result
    }
}

extension UInt64 {
    func hex(charsLength: Int) -> String {
        var result = String(format: "%X", self)
        let resultSize = result.characters.count
        if resultSize < charsLength {
            for _ in resultSize..<charsLength {
                result = "0" + result
            }
        }
        return result
    }
}
