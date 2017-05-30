//
//  ScannedCard.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 29.05.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation

@objc public class ScannedCardInfo: NSObject {
    var cardNumber: String?
    var expiryMonth: Int?
    var expiryYear: Int?
    var cvv: String?
    
    override init() {
        super.init()
    }
}
