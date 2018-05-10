import UIKit

public class A2AVerificationRequest : NSObject, Serializable {
    open var cardType: String?
    open var returnLocation: String?
    open var context: A2AContext?
}
