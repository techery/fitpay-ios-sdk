//
//  A2AVerificationError.swift
//  FitpaySDK
//
//  Created by Illya Kyznetsov on 3/5/18.
//

/**
 Errors for A2AVerificationRequest
 */
enum A2AVerificationError: String {
    case CantProcess  = "can not process verification request"
    case NoActivity   = "no Activity found to handle Intent"
    case NotSupported = "a2a auth is not supported"
    case Unknown      = "unknown"
}
