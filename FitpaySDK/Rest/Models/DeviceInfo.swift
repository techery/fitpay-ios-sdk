
@objcMembers open class DeviceInfo: NSObject, ClientModel, Serializable, SecretApplyable {
    
    open var deviceIdentifier: String?
    open var deviceName: String?
    open var deviceType: String?
    open var manufacturerName: String?
    open var state: String?
    open var serialNumber: String?
    open var modelNumber: String?
    open var hardwareRevision: String?
    open var firmwareRevision: String?
    open var softwareRevision: String?
    open var notificationToken: String?
    open var createdEpoch: TimeInterval?
    open var created: String?
    open var osName: String?
    open var systemId: String?
    open var cardRelationships: [CardRelationship]?
    open var licenseKey: String?
    open var bdAddress: String?
    open var pairing: String?
    open var secureElementId: String?
    open var casd: String?
    
    // Extra metadata specific for a particural type of device
    open var metadata: [String: Any]?

    open var userAvailable: Bool {
        return self.links?.url(DeviceInfo.userResourceKey) != nil
    }

    open var listCommitsAvailable: Bool {
        return self.links?.url(DeviceInfo.commitsResourceKey) != nil
    }

    var client: RestClient? {
        get {
            return self._client
        }
        set {
            self._client = newValue

            if let cardRelationships = self.cardRelationships {
                for cardRelationship in cardRelationships {
                    cardRelationship.client = self.client
                }
            }
        }
    }
    
    internal var links: [ResourceLink]?
    
    private static let userResourceKey = "user"
    private static let commitsResourceKey = "commits"
    private static let selfResourceKey = "self"
    private static let lastAckCommitResourceKey = "lastAckCommit"
    
    private weak var _client: RestClient?
    
    override public init() {
        super.init()
    }

    init(deviceType: String, manufacturerName: String, deviceName: String, serialNumber: String?, modelNumber: String?, hardwareRevision: String?, firmwareRevision: String?, softwareRevision: String?, notificationToken: String?, systemId: String?, osName: String?, secureElementId: String?, casd: String?) {
        self.deviceType = deviceType
        self.manufacturerName = manufacturerName
        self.deviceName = deviceName
        self.serialNumber = serialNumber
        self.modelNumber = modelNumber
        self.hardwareRevision = hardwareRevision
        self.firmwareRevision = firmwareRevision
        self.softwareRevision = softwareRevision
        self.notificationToken = notificationToken
        self.systemId = systemId
        self.osName = osName
        self.secureElementId = secureElementId
        self.casd = casd
    }

    private enum CodingKeys: String, CodingKey {
        case links = "_links"
        case created = "createdTs"
        case createdEpoch = "createdTsEpoch"
        case deviceIdentifier
        case deviceName
        case deviceType
        case manufacturerName
        case state
        case serialNumber
        case modelNumber
        case hardwareRevision
        case firmwareRevision
        case softwareRevision
        case notificationToken
        case osName
        case systemId
        case licenseKey
        case bdAddress
        case pairing
        case secureElement
        case secureElementId
        case casd = "casdCert"
        case cardRelationships
        case metadata
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        links = try container.decode(.links, transformer: ResourceLinkTypeTransform())
        created = try container.decode(.created)
        createdEpoch = try container.decode(.createdEpoch, transformer: NSTimeIntervalTypeTransform())
        deviceIdentifier = try container.decode(.deviceIdentifier)
        deviceName = try container.decode(.deviceName)
        deviceType = try container.decode(.deviceType)
        manufacturerName = try container.decode(.manufacturerName)
        state = try container.decode(.state)
        serialNumber = try container.decode(.serialNumber)
        modelNumber = try container.decode(.modelNumber)
        hardwareRevision = try container.decode(.hardwareRevision)
        firmwareRevision =  try container.decode(.firmwareRevision)
        softwareRevision = try container.decode(.softwareRevision)
        notificationToken = try container.decode(.notificationToken)
        osName = try container.decode(.osName)
        systemId = try container.decode(.systemId)
        licenseKey = try container.decode(.licenseKey)
        bdAddress = try container.decode(.bdAddress)
        pairing = try container.decode(.pairing)
        if let secureElement: [String: String] = try container.decode(.secureElement)  {
            secureElementId = secureElement["secureElementId"]
            casd = secureElement["casdCert"]
        } else {
            secureElementId = try container.decode(.secureElementId)
            casd = try container.decode(.casd)
        }

        self.cardRelationships = try container.decode(.cardRelationships)
        metadata = try container.decode([String : Any].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(links, forKey: .links, transformer: ResourceLinkTypeTransform())
        try container.encode(created, forKey: .created)
        try container.encode(createdEpoch, forKey: .createdEpoch, transformer: NSTimeIntervalTypeTransform())
        try container.encode(deviceIdentifier, forKey: .deviceIdentifier)
        try container.encode(deviceName, forKey: .deviceName)
        try container.encode(deviceType, forKey: .deviceType)
        try container.encode(serialNumber, forKey: .serialNumber)
        try container.encode(modelNumber, forKey: .modelNumber)
        try container.encode(hardwareRevision, forKey: .hardwareRevision)
        try container.encode(firmwareRevision, forKey: .firmwareRevision)
        try container.encode(softwareRevision, forKey: .softwareRevision)
        try container.encode(notificationToken, forKey: .notificationToken)
        try container.encode(osName, forKey: .osName)
        try container.encode(systemId, forKey: .systemId)
        try container.encode(licenseKey, forKey: .licenseKey)
        try container.encode(bdAddress, forKey: .bdAddress)
        try container.encode(pairing, forKey: .pairing)
        try container.encode(secureElementId, forKey: .secureElementId)
        try container.encode(casd, forKey: .casd)
        try container.encode(cardRelationships, forKey: .cardRelationships)
    }

    func applySecret(_ secret: Data, expectedKeyId: String?) {
        if let cardRelationships = self.cardRelationships {
            for modelObject in cardRelationships {
                modelObject.applySecret(secret, expectedKeyId: expectedKeyId)
            }
        }
    }

    var shortRTMRepersentation: String? {

        var dic: [String: Any] = [:]

        if let deviceType = self.deviceType {
            dic["deviceType"] = deviceType
        }

        if let deviceName = self.deviceName {
            dic["deviceName"] = deviceName
        }

        if let manufacturerName = self.manufacturerName {
            dic["manufacturerName"] = manufacturerName
        }

        if let modelNumber = self.modelNumber {
            dic["modelNumber"] = modelNumber
        }

        if let hardwareRevision = self.hardwareRevision {
            dic["hardwareRevision"] = hardwareRevision
        }

        if let firmwareRevision = self.firmwareRevision {
            dic["firmwareRevision"] = firmwareRevision
        }

        if let softwareRevision = self.softwareRevision {
            dic["softwareRevision"] = softwareRevision
        }

        if let systemId = self.systemId {
            dic["systemId"] = systemId
        }

        if let osName = self.osName {
            dic["osName"] = osName
        }

        if let licenseKey = self.licenseKey {
            dic["licenseKey"] = licenseKey
        }

        if let bdAddress = self.bdAddress {
            dic["bdAddress"] = bdAddress
        }

        if let secureElementId = self.secureElementId {
            dic["secureElement"] = ["secureElementId": secureElementId]
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return nil
        }

        return String(data: jsonData, encoding: String.Encoding.utf8)
    }
    
    /**
     Delete a single device
     
     - parameter completion: DeleteDeviceHandler closure
     */
    @objc open func deleteDeviceInfo(_ completion: @escaping RestClient.DeleteHandler) {
        let resource = DeviceInfo.selfResourceKey
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            client.deleteDevice(url, completion: completion)
        } else {
            completion(NSError.clientUrlError(domain: DeviceInfo.self, code: 0, client: client, url: url, resource: resource))
        }
    }

    /**
     Update the details of an existing device
     (For optional? parameters use nil if field doesn't need to be updated) //TODO: consider adding default nil value

     - parameter firmwareRevision?: firmware revision
     - parameter softwareRevision?: software revision
     - parameter completion:        UpdateDeviceHandler closure
     */
    @objc open func update(_ firmwareRevision: String?, softwareRevision: String?, notifcationToken: String?, completion: @escaping RestClient.DeviceHandler) {
        let resource = DeviceInfo.selfResourceKey
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            // if notification token not exists on platform then we need to create this field
            if notifcationToken != nil && self.notificationToken == nil {
                addNotificationToken(notifcationToken!) { (deviceInfo, error) in
                    // notificationToken added, check do we need to update other fields
                    if firmwareRevision == nil && softwareRevision == nil {
                        completion(deviceInfo, error)
                        return
                    }
                    
                    client.updateDevice(url, firmwareRevision: firmwareRevision, softwareRevision: softwareRevision, notificationToken: notifcationToken, completion: completion)
                }
            } else {
                client.updateDevice(url, firmwareRevision: firmwareRevision, softwareRevision: softwareRevision, notificationToken: notifcationToken, completion: completion)
            }
        } else {
            completion(nil, NSError.clientUrlError(domain: DeviceInfo.self, code: 0, client: client, url: url, resource: resource))
        }
    }

    /**
     Retrieves a collection of all events that should be committed to this device
     
     - parameter commitsAfter: the last commit successfully applied. Query will return all subsequent commits which need to be applied.
     - parameter limit:        max number of profiles per page
     - parameter offset:       start index position for list of entities returned
     - parameter completion:   CommitsHandler closure
     */
    open func listCommits(commitsAfter: String?, limit: Int, offset: Int, completion: @escaping RestClient.CommitsHandler) {
        let resource = DeviceInfo.commitsResourceKey
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            client.commits(url, commitsAfter: commitsAfter, limit: limit, offset: offset, completion: completion)
        } else {
            completion(nil, NSError.clientUrlError(domain: DeviceInfo.self, code: 0, client: client, url: url, resource: resource))
        }
    }
    
    /**
     Retrieves last acknowledge commit for device
     
     - parameter completion: CommitHandler closure
     */
    open func lastAckCommit(completion: @escaping RestClient.CommitHandler) {
        let resource = DeviceInfo.lastAckCommitResourceKey
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            client.commit(url, completion: completion)
        } else {
            completion(nil, NSError.clientUrlError(domain: DeviceInfo.self, code: 0, client: client, url: url, resource: resource))
        }
    }

    @objc open func user(_ completion: @escaping RestClient.UserHandler) {
        let resource = DeviceInfo.userResourceKey
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            client.user(url, completion: completion)
        } else {
            completion(nil, NSError.clientUrlError(domain: DeviceInfo.self, code: 0, client: client, url: url, resource: resource))
        }
    }

    internal func addNotificationToken(_ token: String, completion: @escaping RestClient.DeviceHandler) {
        let resource = DeviceInfo.selfResourceKey
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            client.addDeviceProperty(url, propertyPath: "/notificationToken", propertyValue: token, completion: completion)
        } else {
            completion(nil, NSError.clientUrlError(domain: DeviceInfo.self, code: 0, client: client, url: url, resource: resource))
        }
    }

    internal typealias NotificationTokenUpdateCompletion = (_ changed: Bool, _ error: NSError?) -> Void
    
    internal func updateNotificationTokenIfNeeded(completion: NotificationTokenUpdateCompletion? = nil) {
        let newNotificationToken = FitpayNotificationsManager.sharedInstance.notificationsToken
        if newNotificationToken != "" {
            if newNotificationToken != self.notificationToken {
                update(nil, softwareRevision: nil, notifcationToken: newNotificationToken, completion: {
                    [weak self] (device, error) in
                    if error == nil && device != nil {
                        log.debug("NOTIFICATIONS_DATA: NotificationToken updated to - \(device?.notificationToken ?? "null token")")
                        self?.notificationToken = device?.notificationToken
                        completion?(true, nil)
                    } else {
                        log.error("NOTIFICATIONS_DATA: can't update notification token for device, error: \(String(describing: error))")
                        completion?(false, error)
                    }
                    
                })
            } else {
                completion?(false, nil)
            }
        } else {
            completion?(false, nil)
        }
    }
    
}

open class CardRelationship: NSObject, ClientModel, Serializable, SecretApplyable {
    open var creditCardId: String?
    open var pan: String?
    open var expMonth: Int?
    open var expYear: Int?
    
    public weak var client: RestClient?
    
    var links: [ResourceLink]?
    var encryptedData: String?
    
    private static let selfResource = "self"

    private enum CodingKeys: String, CodingKey {
        case links = "_links"
        case creditCardId
        case encryptedData
        case pan
        case expMonth
        case expYear
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        links = try container.decode(.links, transformer: ResourceLinkTypeTransform())
        creditCardId = try container.decode(.creditCardId)
        encryptedData = try container.decode(.encryptedData)
        pan = try container.decode(.pan)
        expMonth = try container.decode(.expMonth)
        expYear = try container.decode(.expYear)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(links, forKey: .links, transformer: ResourceLinkTypeTransform())
        try container.encode(creditCardId, forKey: .creditCardId)
        try container.encode(encryptedData, forKey: .encryptedData)
        try container.encode(pan, forKey: .pan)
        try container.encode(expMonth, forKey: .expMonth)
        try container.encode(expYear, forKey: .expYear)
    }

    func applySecret(_ secret: Data, expectedKeyId: String?) {
        if let decryptedObj: CardRelationship = JWEObject.decrypt(self.encryptedData, expectedKeyId: expectedKeyId, secret: secret) {
            self.pan = decryptedObj.pan
            self.expMonth = decryptedObj.expMonth
            self.expYear = decryptedObj.expYear
        }
    }

    /**
     Get a single relationship
     
     - parameter completion:   RelationshipHandler closure
     */
    @objc open func relationship(_ completion: @escaping RestClient.RelationshipHandler) {
        let resource = CardRelationship.selfResource
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            client.relationship(url, completion: completion)
        } else {
            completion(nil, NSError.clientUrlError(domain: CardRelationship.self, code: 0, client: client, url: url, resource: resource))
        }
    }

}
