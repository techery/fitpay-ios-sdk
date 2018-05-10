//
//  RtmSecureDeviceInfo.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 14.07.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

public class RtmSecureDeviceInfo: RtmDeviceInfo {
    private enum CodingKeys: String, CodingKey {
        case casdCert 
        case secureElement
        case secureElementId
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        casd = try container.decode(.casdCert)
        if let secureElement: [String: String] = try container.decode(.secureElement)  {
            secureElementId = secureElement["secureElementId"]
        } else {
            secureElementId = try container.decode(.secureElementId)
        }
    }
    
    override func copyFieldsFrom(deviceInfo: DeviceInfo) {
        super.copyFieldsFrom(deviceInfo: deviceInfo)
        self.casd = deviceInfo.casd
        self.secureElementId = deviceInfo.secureElementId
    }
}

