/// Address
open class Address: Serializable {
    
    /// The billing address street name and number
    open var street1: String?
    
    /// The billing address unit or suite number, if available
    open var street2: String?
    
    /// Additional billing address unit or suite number, if available
    open var street3: String?
    
    /// The billing address city
    open var city: String?
    
    /// The billing address state
    open var state: String?
    
    /// The billing address five-digit zip code
    open var postalCode: String?
    
    /// The billing address country code in ISO 3166-1 alpha-2 format
    open var countryCode: String?
    
}
