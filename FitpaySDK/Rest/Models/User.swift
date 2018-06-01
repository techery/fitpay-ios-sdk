
open class User: NSObject, ClientModel, Serializable, SecretApplyable {
    
    open var id: String?
    open var created: String?
    open var createdEpoch: TimeInterval?
    open var lastModified: String?
    open var lastModifiedEpoch: TimeInterval?
    
    var links: [ResourceLink]?
    var encryptedData: String?
    var info: UserInfo?
    
    private static let creditCardsResourceKey = "creditCards"
    private static let devicesResourceKey = "devices"
    private static let selfResourceKey = "self"
    
    open var firstName: String? {
        return self.info?.firstName
    }
    
    open var lastName: String? {
        return self.info?.lastName
    }
    
    open var birthDate: String? {
        return self.info?.birthDate
    }
    
    open var email: String? {
        return self.info?.email
    }
    
    open var listCreditCardsAvailable: Bool {
        return self.links?.url(User.creditCardsResourceKey) != nil
    }
    
    open var listDevicesAvailable: Bool {
        return self.links?.url(User.devicesResourceKey) != nil
    }
    
    weak var client: RestClient?
    
    private enum CodingKeys: String, CodingKey {
        case links = "_links"
        case id
        case created = "createdTs"
        case createdEpoch = "createdTsEpoch"
        case lastModified = "lastModifiedTs"
        case lastModifiedEpoch = "lastModifiedTsEpoch"
        case encryptedData
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        links = try container.decode(.links, transformer: ResourceLinkTypeTransform())
        id = try? container.decode(.id)
        created = try? container.decode(.created)
        createdEpoch = try container.decode(.createdEpoch, transformer: NSTimeIntervalTypeTransform())
        lastModified = try? container.decode(.lastModified)
        lastModifiedEpoch = try container.decode(.lastModifiedEpoch, transformer: NSTimeIntervalTypeTransform())
        encryptedData = try? container.decode(.encryptedData)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try? container.encode(links, forKey: .links, transformer: ResourceLinkTypeTransform())
        try? container.encode(created, forKey: .created)
        try? container.encode(createdEpoch, forKey: .createdEpoch, transformer: NSTimeIntervalTypeTransform())
        try? container.encode(lastModified, forKey: .lastModified)
        try? container.encode(lastModifiedEpoch, forKey: .lastModifiedEpoch, transformer: NSTimeIntervalTypeTransform())
        try? container.encode(encryptedData, forKey: .encryptedData)
    }
    
    /**
     Add a single credit card to a user's profile. If the card owner has no default card, then the new card will become the default.
     
     - parameter pan:        pan
     - parameter expMonth:   expiration month
     - parameter expYear:    expiration year
     - parameter cvv:        cvv code
     - parameter name:       user name
     - parameter street1:    address
     - parameter street2:    address
     - parameter street3:    street name
     - parameter city:       address
     - parameter state:      state
     - parameter postalCode: postal code
     - parameter country:    country
     - parameter completion: CreateCreditCardHandler closure
     */
    @objc public func createCreditCard(pan: String, expMonth: Int, expYear: Int, cvv: String, name: String,
                                       street1: String, street2: String, street3: String, city: String, state: String, postalCode: String, country: String,
                                       completion: @escaping RestClient.CreditCardHandler) {
        let resource = User.creditCardsResourceKey
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client {
            client.createCreditCard(url, pan: pan, expMonth: expMonth, expYear: expYear, cvv: cvv, name: name, street1: street1, street2: street2, street3: street3, city: city, state: state, postalCode: postalCode, country: country, completion: completion)
        } else {
            completion(nil, ErrorResponse.clientUrlError(domain: User.self, client: client, url: url, resource: resource))
        }
        
    }
    
    /**
     Retrieves the details of an existing credit card. You need only supply the uniqueidentifier that was returned upon creation.
     
     - parameter excludeState: Exclude all credit cards in the specified state. If you desire to specify multiple excludeState values, then repeat this query parameter multiple times.
     - parameter limit:        max number of profiles per page
     - parameter offset:       start index position for list of entities returned
     - parameter completion:   CreditCardsHandler closure
     */
    public func listCreditCards(excludeState: [String], limit: Int, offset: Int, completion: @escaping RestClient.CreditCardsHandler) {
        let resource = User.creditCardsResourceKey
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client {
            client.creditCards(url, excludeState: excludeState, limit: limit, offset: offset, completion: completion)
        } else {
            completion(nil, ErrorResponse.clientUrlError(domain: User.self, client: client, url: url, resource: resource))
        }
    }
    
    /**
     For a single user, retrieve a pagable collection of devices in their profile
     
     - parameter limit:      max number of profiles per page
     - parameter offset:     start index position for list of entities returned
     - parameter completion: DevicesHandler closure
     */
    public func listDevices(limit: Int, offset: Int, completion: @escaping RestClient.DevicesHandler) {
        let resource = User.devicesResourceKey
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client {
            client.devices(url, limit: limit, offset: offset, completion: completion)
        } else {
            completion(nil, ErrorResponse.clientUrlError(domain: User.self, client: client, url: url, resource: resource))
        }
    }
    
    /**
     For a single user, create a new device in their profile
     
     - parameter device: DeviceInfo
     */
    @objc public func createDevice(_ device: DeviceInfo, completion: @escaping RestClient.DeviceHandler) {
        let resource = User.devicesResourceKey
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            client.createNewDevice(url, deviceType: device.deviceType!, manufacturerName: device.manufacturerName!, deviceName: device.deviceName!,
                                   serialNumber: device.serialNumber, modelNumber: device.modelNumber, hardwareRevision: device.hardwareRevision,
                                   firmwareRevision: device.firmwareRevision, softwareRevision: device.softwareRevision,
                                   notificationToken: device.notificationToken, systemId: device.systemId, osName: device.osName,
                                   secureElementId: device.secureElementId, casd: device.casd, completion: completion)
        } else {
            completion(nil, ErrorResponse.clientUrlError(domain: User.self, client: client, url: url, resource: resource))
        }
    }
    
    @objc public func createRelationship(creditCardId: String, deviceId: String, completion: @escaping RestClient.RelationshipHandler) {
        let resource = User.selfResourceKey
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client {
            client.createRelationship(url, creditCardId: creditCardId, deviceId: deviceId, completion: completion)
        } else {
            completion(nil, ErrorResponse.clientUrlError(domain: User.self, client: client, url: url, resource: resource))
        }
    }
    
    @objc public func deleteUser(_ completion: @escaping RestClient.DeleteHandler) {
        let resource = User.selfResourceKey
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client {
            client.deleteUser(url, completion: completion)
        } else {
            completion(ErrorResponse.clientUrlError(domain: User.self, client: client, url: url, resource: resource))
        }
    }
    
    @objc public func updateUser(firstName: String?, lastName: String?, birthDate: String?, originAccountCreated: String?, termsAccepted: String?, termsVersion: String?, completion: @escaping RestClient.UserHandler) {
        let resource = User.selfResourceKey
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client {
            client.updateUser(url, firstName: firstName, lastName: lastName, birthDate: birthDate, originAccountCreated: originAccountCreated, termsAccepted: termsAccepted, termsVersion: termsVersion, completion: completion)
        } else {
            completion(nil, ErrorResponse.clientUrlError(domain: User.self, client: client, url: url, resource: resource))
        }
    }
    
    //MARK: - Internal Helpers
    
    func applySecret(_ secret: Data, expectedKeyId: String?) {
        self.info = JWEObject.decrypt(self.encryptedData, expectedKeyId: expectedKeyId, secret: secret)
    }
    
}

struct UserInfo: Serializable {
    var firstName: String?
    var lastName: String?
    var birthDate: String?
    var email: String?
}
