//
//  Issuers.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 15.06.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation
import ObjectMapper

open class Issuers: Mappable, ClientModel {
    internal var links:[ResourceLink]?
    
    weak var client: RestClient?
    
    public var countries: [String:Country]?
    
    public required init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        links <- (map["_links"], ResourceLinkTransformType())
        countries <- map["countries"]
    }
    
    public struct Country: Mappable {
        public init?(map: Map) { }

        
        public var cardNetworks: [String: CardNetwork]?
        
        mutating public func mapping(map: Map) {
            cardNetworks <- map["cardNetworks"]
        }
    }
    
    public struct CardNetwork: Mappable {
        
        public var issuers: [String]?
        
        public init?(map: Map) { }

        mutating public func mapping(map: Map) {
            issuers <- map["issuers"]
        }
    }
}
