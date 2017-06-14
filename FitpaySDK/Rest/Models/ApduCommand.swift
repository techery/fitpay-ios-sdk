//
//  APDUCommand.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 15.05.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import ObjectMapper

open class APDUCommand : NSObject, Mappable, APDUResponseProtocol {
    
    internal var links: [ResourceLink]?
    open var commandId: String?
    open var groupId: Int = 0
    open var sequence: Int = 0
    open var command: String?
    open var type: String?
    open var continueOnFailure: Bool = false
    
    open var responseData: Data?
    
    override init() {
        super.init()
    }
    
    public required init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        links <- (map["_links"], ResourceLinkTransformType())
        commandId <- map["commandId"]
        groupId <- map["groupId"]
        sequence <- map["sequence"]
        command <- map["command"]
        type <- map["type"]
        continueOnFailure <- map["continueOnFailure"]
    }
    
    open var responseDictionary : [String:Any] {
        get {
            var dic : [String:Any] = [:]
            
            if let commandId = self.commandId {
                dic["commandId"] = commandId
            }
            
            if let responseCode = self.responseCode {
                dic["responseCode"] = responseCode.hex
            }
            
            if let responseData = self.responseData {
                dic["responseData"] = responseData.hex
            }
            
            return dic
        }
    }
}

