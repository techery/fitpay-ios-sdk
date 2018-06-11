import Foundation

open class DeviceRelationships: NSObject, ClientModel, Serializable {
    
    open var deviceType: String?
    open var deviceIdentifier: String?
    open var manufacturerName: String?
    open var deviceName: String?
    open var serialNumber: String?
    open var modelNumber: String?
    open var hardwareRevision: String?
    open var firmwareRevision: String?
    open var softwareRevision: String?
    open var created: String?
    open var createdEpoch: TimeInterval?
    open var osName: String?
    open var systemId: String?
    
    var client: RestClient?
    var links: [ResourceLink]?
    
    private static let selfResourceKey = "self"
    
    private enum CodingKeys: String, CodingKey {
        case deviceType
        case links = "_links"
        case deviceIdentifier
        case manufacturerName
        case deviceName
        case serialNumber
        case modelNumber
        case hardwareRevision
        case firmwareRevision
        case softwareRevision
        case created = "createdTs"
        case createdEpoch = "createdTsEpoch"
        case osName
        case systemId
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        links = try container.decode(.links, transformer: ResourceLinkTypeTransform())
        deviceType = try? container.decode(.deviceType)
        deviceIdentifier = try? container.decode(.deviceIdentifier)
        manufacturerName = try? container.decode(.manufacturerName)
        deviceName = try? container.decode(.deviceName)
        serialNumber = try? container.decode(.serialNumber)
        modelNumber = try? container.decode(.modelNumber)
        hardwareRevision = try? container.decode(.hardwareRevision)
        firmwareRevision =  try? container.decode(.firmwareRevision)
        softwareRevision = try? container.decode(.softwareRevision)
        created = try? container.decode(.created)
        createdEpoch = try container.decode(.createdEpoch, transformer: NSTimeIntervalTypeTransform())
        osName = try? container.decode(.osName)
        systemId = try? container.decode(.systemId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try? container.encode(links, forKey: .links, transformer: ResourceLinkTypeTransform())
        try? container.encode(deviceType, forKey: .deviceType)
        try? container.encode(deviceIdentifier, forKey: .deviceIdentifier)
        try? container.encode(manufacturerName, forKey: .manufacturerName)
        try? container.encode(deviceName, forKey: .deviceName)
        try? container.encode(serialNumber, forKey: .serialNumber)
        try? container.encode(modelNumber, forKey: .modelNumber)
        try? container.encode(hardwareRevision, forKey: .hardwareRevision)
        try? container.encode(firmwareRevision, forKey: .firmwareRevision)
        try? container.encode(softwareRevision, forKey: .softwareRevision)
        try? container.encode(created, forKey: .created)
        try? container.encode(createdEpoch, forKey: .createdEpoch, transformer: NSTimeIntervalTypeTransform())
        try? container.encode(osName, forKey: .osName)
        try? container.encode(systemId, forKey: .systemId)
    }
    
    @objc func relationship(_ completion: @escaping RestClient.RelationshipHandler) {
        let resource = DeviceRelationships.selfResourceKey
        let url = self.links?.url(resource)
        if let url = url, let client = self.client {
            client.relationship(url, completion: completion)
        } else {
            completion(nil, ErrorResponse.clientUrlError(domain: DeviceRelationships.self, client: client, url: url, resource: resource))
        }
    }
}
