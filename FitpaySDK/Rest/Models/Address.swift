/// Address
@objc open class Address: NSObject, Serializable {
    
    /// The billing address street name and number
    @objc open var street1: String?
    
    /// The billing address unit or suite number, if available
    @objc open var street2: String?
    
    /// Additional billing address unit or suite number, if available
    @objc open var street3: String?
    
    /// The billing address city
    @objc open var city: String?
    
    /// The billing address state
    @objc open var state: String?
    
    /// The billing address five-digit zip code
    @objc open var postalCode: String?
    
    /// The billing address country code in ISO 3166-1 alpha-2 format
    @objc open var countryCode: String?
    
}
