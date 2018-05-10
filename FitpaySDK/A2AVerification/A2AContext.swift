//
//  A2AVerificationError.swift
//  FitpaySDK
//
//  Created by Illya Kyznetsov on 3/5/18.
//

import UIKit

open class A2AContext: NSObject, Serializable {
    open var applicationId: String?
    open var action: String?
    open var payload: String?

    internal override init() {
        super.init()
    }
}

