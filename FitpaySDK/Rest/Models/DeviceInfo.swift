import Foundation

@objcMembers open class DeviceInfo: NSObject, ClientModel, Serializable, SecretApplyable {
    
    open var deviceIdentifier: String?
   
    /// The name of the device model
    open var deviceName: String?
    
    open var deviceType: String?
    
    /// The manufacturer name of the device
    open var manufacturerName: String?
    
    open var state: String?
    
    /// The serial number for a particular instance of the device
    open var serialNumber: String?
    
    /// The model number that is assigned by the device vendor
    open var modelNumber: String?
    
    /// The hardware revision for the hardware within the device
    open var hardwareRevision: String?
    
    /// The firmware revision for the firmware within the device. Value may be normalized to meet payment network specifications.
    open var firmwareRevision: String?
    
    open var softwareRevision: String?
    
    open var notificationToken: String?
    
    open var createdEpoch: TimeInterval?
    
    open var created: String?
    
    /// The code name of the firmware operating system on the device
    open var osName: String?
    
    /// A structure containing an Organizationally Unique Identifier (OUI) followed
    /// by a manufacturer-defined identifier and is unique for each individual instance of the product
    open var systemId: String?
    
    open var cardRelationships: [CardRelationship]?
    
    open var licenseKey: String?
    
    /// MAC address for Bluetooth
    open var bdAddress: String?
    
    open var pairing: String?

    open var secureElement: SecureElement?
    
    // Extra metadata specific for a particural type of device
    open var metadata: [String: Any]?

    open var userAvailable: Bool {
        return self.links?.url(DeviceInfo.userResourceKey) != nil
    }

    open var listCommitsAvailable: Bool {
        return self.links?.url(DeviceInfo.commitsResourceKey) != nil
    }

    open var deviceResetUrl: String? {
        return self.links?.url(DeviceInfo.deviceResetTasksKey)
    }

    var client: RestClientInterface? {
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
    
    var links: [ResourceLink]?
    
    private static let userResourceKey = "user"
    private static let commitsResourceKey = "commits"
    private static let selfResourceKey = "self"
    private static let lastAckCommitResourceKey = "lastAckCommit"
    private static let deviceResetTasksKey = "deviceResetTasks"

    private weak var _client: RestClientInterface?
    
    override public init() {
        super.init()
    }

    init(deviceType: String, manufacturerName: String, deviceName: String, serialNumber: String?, modelNumber: String?, hardwareRevision: String?, firmwareRevision: String?, softwareRevision: String?, notificationToken: String?, systemId: String?, osName: String?, secureElement: SecureElement?) {
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
        self.secureElement = secureElement
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
        case cardRelationships
        case metadata
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        links = try container.decode(.links, transformer: ResourceLinkTypeTransform())
        created = try? container.decode(.created)
        createdEpoch = try container.decode(.createdEpoch, transformer: NSTimeIntervalTypeTransform())
        deviceIdentifier = try? container.decode(.deviceIdentifier)
        deviceName = try? container.decode(.deviceName)
        deviceType = try? container.decode(.deviceType)
        manufacturerName = try? container.decode(.manufacturerName)
        state = try? container.decode(.state)
        serialNumber = try? container.decode(.serialNumber)
        modelNumber = try? container.decode(.modelNumber)
        hardwareRevision = try? container.decode(.hardwareRevision)
        firmwareRevision =  try? container.decode(.firmwareRevision)
        softwareRevision = try? container.decode(.softwareRevision)
        notificationToken = try? container.decode(.notificationToken)
        osName = try? container.decode(.osName)
        systemId = try? container.decode(.systemId)
        licenseKey = try? container.decode(.licenseKey)
        bdAddress = try? container.decode(.bdAddress)
        pairing = try? container.decode(.pairing)
        secureElement = try? container.decode(.secureElement)
        cardRelationships = try? container.decode(.cardRelationships)
        metadata = try? container.decode([String : Any].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try? container.encode(links, forKey: .links, transformer: ResourceLinkTypeTransform())
        try? container.encode(created, forKey: .created)
        try container.encode(createdEpoch, forKey: .createdEpoch, transformer: NSTimeIntervalTypeTransform())
        try? container.encode(deviceIdentifier, forKey: .deviceIdentifier)
        try? container.encode(deviceName, forKey: .deviceName)
        try? container.encode(deviceType, forKey: .deviceType)
        try? container.encode(manufacturerName, forKey: .manufacturerName)
        try? container.encode(state, forKey: .state)
        try? container.encode(serialNumber, forKey: .serialNumber)
        try? container.encode(modelNumber, forKey: .modelNumber)
        try? container.encode(hardwareRevision, forKey: .hardwareRevision)
        try? container.encode(firmwareRevision, forKey: .firmwareRevision)
        try? container.encode(softwareRevision, forKey: .softwareRevision)
        try? container.encode(notificationToken, forKey: .notificationToken)
        try? container.encode(osName, forKey: .osName)
        try? container.encode(systemId, forKey: .systemId)
        try? container.encode(licenseKey, forKey: .licenseKey)
        try? container.encode(bdAddress, forKey: .bdAddress)
        try? container.encode(pairing, forKey: .pairing)
        try? container.encode(secureElement, forKey: .secureElement)
        try? container.encode(cardRelationships, forKey: .cardRelationships)
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

        if let secureElementId = self.secureElement?.secureElementId {
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
            completion(ErrorResponse.clientUrlError(domain: DeviceInfo.self, client: client, url: url, resource: resource))
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
            completion(nil, ErrorResponse.clientUrlError(domain: DeviceInfo.self, client: client, url: url, resource: resource))
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
            completion(nil, ErrorResponse.clientUrlError(domain: DeviceInfo.self, client: client, url: url, resource: resource))
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
            completion(nil, ErrorResponse.clientUrlError(domain: DeviceInfo.self, client: client, url: url, resource: resource))
        }
    }

    @objc open func user(_ completion: @escaping RestClient.UserHandler) {
        let resource = DeviceInfo.userResourceKey
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            client.user(url, completion: completion)
        } else {
            completion(nil, ErrorResponse.clientUrlError(domain: DeviceInfo.self, client: client, url: url, resource: resource))
        }
    }

    // MARK: - Internal
    
    func addNotificationToken(_ token: String, completion: @escaping RestClient.DeviceHandler) {
        let resource = DeviceInfo.selfResourceKey
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            client.addDeviceProperty(url, propertyPath: "/notificationToken", propertyValue: token, completion: completion)
        } else {
            completion(nil, ErrorResponse.clientUrlError(domain: DeviceInfo.self, client: client, url: url, resource: resource))
        }
    }

    typealias NotificationTokenUpdateCompletion = (_ changed: Bool, _ error: ErrorResponse?) -> Void
    func updateNotificationTokenIfNeeded(completion: NotificationTokenUpdateCompletion? = nil) {
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
