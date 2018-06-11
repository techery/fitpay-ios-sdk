import Foundation

/// Credit card info
open class CardInfo: Serializable {
    
    /// The credit card number, also known as a Primary Account Number (PAN)
    open var pan: String?
    
    /// The credit card expiration month
    open var expMonth: Int?
    
    /// The credit card expiration year
    open var expYear: Int?
    
    /// The credit card cvv2 code
    open var cvv: String?
    
    /// Card holder name
    open var name: String?
    
    /// Card holder billing address
    open var address: Address?
    
    /// Card holder risk data
    open var riskData: IdVerification?
    
}
