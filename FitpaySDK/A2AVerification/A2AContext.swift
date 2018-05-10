import UIKit

/// Object containing the information needed to pass into the issuer app
open class A2AContext: NSObject, Serializable {
    
    /// iTunes App Id
    /// 9 digit number as a string
    /// Can be used to construct an iTunes URL as a fallback if the user doesn't have the issuer app installed
    open var applicationId: String?
    
    /// The url used to be open the issuer app
    open var action: String?
    
    /// The payload to send the issuer as a parameter
    /// ?a2apayload={payload}
    open var payload: String?
    
}

