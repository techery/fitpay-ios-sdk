//
//  RtmSecureDeviceInfo.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 14.07.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import ObjectMapper

public class RtmSecureDeviceInfo: RtmDeviceInfo {
    open override func mapping(map: Map) {
        super.mapping(map: map)
        
        casd <- map["casd"]
        if let secureElement = map["secureElement"].currentValue as? [String: String] {
            secureElementId = secureElement["secureElementId"]
        } else {
            secureElementId <- map["secureElementId"]
        }
    }
}

