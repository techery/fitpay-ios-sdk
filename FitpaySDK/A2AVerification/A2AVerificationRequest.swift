import Foundation

/// Main Object sent back from `verificationFinished`
@objc public class A2AVerificationRequest: NSObject, Serializable {
    
    @objc public var cardType: String?
    
    /// A string that c
    @objc public var returnLocation: String?
    
    @objc public var context: A2AContext?
}
