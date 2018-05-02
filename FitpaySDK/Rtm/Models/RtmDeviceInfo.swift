//
//  RtmDeviceInfo.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 14.07.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

public class RtmDeviceInfo: DeviceInfo {
    public init(deviceInfo: DeviceInfo) {
        super.init()
        copyFieldsFrom(deviceInfo: deviceInfo)
    }

    private enum CodingKeys: String, CodingKey {
        case links = "_links"
        case created = "createdTs"
        case createdEpoch = "createdTsEpoch"
        case deviceIdentifier
        case deviceName
        case deviceType
        case manufacturerName
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
        case cardRelationships
        case metadata
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        links = try container.decode(.links, transformer: ResourceLinkTypeTransform())
        created = try container.decode(.created)
        if let stringNumber: String = try container.decode(.createdEpoch) {
            createdEpoch = NSTimeIntervalTypeTransform().transform(stringNumber)
        } else if let intNumber: Int = try container.decode(.createdEpoch) {
            createdEpoch = NSTimeIntervalTypeTransform().transform(intNumber)
        }
        deviceIdentifier = try container.decode(.deviceIdentifier)
        deviceName = try container.decode(.deviceName)
        deviceType = try container.decode(.deviceType)
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
        cardRelationships = try container.decode(.cardRelationships)
        metadata = try container.decode([String : Any].self)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(links, forKey: .links, transformer: ResourceLinkTypeTransform())
        try container.encode(created, forKey: .created)
        try container.encode(createdEpoch, forKey: .createdEpoch)
        try container.encode(deviceIdentifier, forKey: .deviceIdentifier)
        try container.encode(deviceName, forKey: .deviceName)
        try container.encode(deviceType, forKey: .deviceType)
        try container.encode(manufacturerName, forKey: .manufacturerName)
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
        try container.encode(cardRelationships, forKey: .cardRelationships)
    }

    func copyFieldsFrom(deviceInfo: DeviceInfo) {
        self.deviceIdentifier  = deviceInfo.deviceIdentifier
        self.deviceName        = deviceInfo.deviceName
        self.deviceType        = deviceInfo.deviceType
        self.manufacturerName  = deviceInfo.manufacturerName
        self.serialNumber      = deviceInfo.serialNumber
        self.modelNumber       = deviceInfo.modelNumber
        self.hardwareRevision  = deviceInfo.hardwareRevision
        self.firmwareRevision  = deviceInfo.firmwareRevision
        self.notificationToken = deviceInfo.notificationToken
        self.osName            = deviceInfo.osName
        self.systemId          = deviceInfo.systemId
        self.licenseKey        = deviceInfo.licenseKey
        self.bdAddress         = deviceInfo.bdAddress
        self.pairing           = deviceInfo.pairing
        self.cardRelationships = deviceInfo.cardRelationships
        self.metadata          = deviceInfo.metadata
    }

}
