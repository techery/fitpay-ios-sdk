//
//  RtmMessage.swift
//  FitpaySDK
//
//  Created by Anton on 02.11.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import UIKit


open class RtmMessage: NSObject, Serializable {
    open var callBackId: Int?
    open var data: Any?
    open var type: String?
    

    
    internal override init() {
        super.init()
    }

    private enum CodingKeys: String, CodingKey {
        case callBackId
        case data
        case type
    }

    struct JSONCodingKeys: CodingKey {
        var stringValue: String

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?

        init?(intValue: Int) {
            self.init(stringValue: "\(intValue)")
            self.intValue = intValue
        }
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        callBackId = try container.decode(.callBackId)
        data = try container.decode([String: Any].self, forKey: .data)
        type = try container.decode(.type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(callBackId, forKey: .callBackId)      
        try container.encode(type, forKey: .type)
    }
}
