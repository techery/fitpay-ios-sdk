//
//  RtmMessageResponse.swift
//  FitpaySDK
//
//  Created by Anton on 02.11.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import UIKit

open class RtmMessageResponse: RtmMessage {

    var success: Bool?
    
    public required init(callbackId: Int? = nil, data: Any? = nil, type: RtmMessageType, success: Bool? = nil) {
        super.init()
        
        self.callBackId = callbackId
        self.data = data
        self.type = type
        self.success = success
    }

    private enum CodingKeys: String, CodingKey {
        case success
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(.success)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
    }
}
