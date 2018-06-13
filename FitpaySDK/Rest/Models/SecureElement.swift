import Foundation

@objc open class SecureElement: NSObject, Codable {
    
    /// The ID of a secure element in a payment capable device
    @objc open var secureElementId: String?
    
    /// Controlling authority security domain certificate
    /// Like an SSL certificate, but for secure elements
    @objc open var casd: String?
    
    /// Initialize class with all variables
    @objc public init(secureElementId: String?, casd: String?) {
        super.init()
        self.secureElementId = secureElementId
        self.casd = casd
    }
    
}
