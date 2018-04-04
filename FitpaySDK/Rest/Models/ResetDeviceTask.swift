//
//  ResetDeviceTask.swift
//  FitpaySDK
//
//  Created by Illya Kyznetsov on 4/4/18.
//  Copyright © 2018 Fitpay. All rights reserved.
//

import ObjectMapper

@objcMembers
open class ResetDeviceTask: NSObject, Mappable
{
    internal var links: [ResourceLink]?
    open var resetId: String?
    open var status: String?
    open var seStatus: String?


    public required init?(map: Map)
    {

    }

    open func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        resetId <- map["resetId"]
        status <- map["status"]
        seStatus <- map["seStatus"]
    }
}
