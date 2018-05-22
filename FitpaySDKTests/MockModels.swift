//
//  MockModels.swift
//  FitpaySDK
//
//  Created by Illya Kyznetsov on 5/16/18.
//  Copyright © 2018 Fitpay. All rights reserved.
//

import XCTest
@testable import FitpaySDK

class MockModels {

    func getCommitStatistic() -> CommitStatistic? {
        let commitStatistic = try? CommitStatistic("{\"commitId\":\"12345fsd\",\"processingTimeMs\":1446587257146,\"averageTimePerCommand\":3,\"errorReason\":\"bad access\"}")
        XCTAssertNotNil(commitStatistic)
        return commitStatistic
    }

    func getTransaction() -> Transaction? {
        let transaction = try? Transaction("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\"}},\"transactionId\":\"12345fsd\",\"transactionType\":\"type\",\"amount\":3.22,\"currencyCode\":\"code\",\"authorizationStatus\":\"status\",\"authorizationStatus\":\"status\",\"transactionTime\":\"time\",\"transactionTimeEpoch\":1446587257146,\"merchantName\":\"name\",\"merchantCode\":\"code\",\"merchantType\":\"type\"}")
        XCTAssertNotNil(transaction)
        return transaction
    }

    func getUser() -> User? {
        let user = try? User("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\"}},\"id\":\"12345fsd\",\"createdTs\":\"2015-11-03T21:47:37.324Z\",\"createdTsEpoch\":1446587257146,\"lastModifiedTs\":\"2015-11-03T21:47:37.324Z\",\"lastModifiedTsEpoch\":1446587257146,\"encryptedData\":\"some data\"}")
        XCTAssertNotNil(user)
        return user
    }

    func getDeviceInfo() -> DeviceInfo? {
        let cardRelationship = getCardRelationship()?.toJSONString() ?? ""
        let deviceInfo = try? DeviceInfo ("{ \"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\"}}, \"deviceIdentifier\":\"123456789\", \"deviceName\":\"noName\", \"deviceType\":\"myType\", \"manufacturerName\":\"12345fsd\", \"state\":\"12345fsd\", \"serialNumber\":\"987654321\", \"modelNumber\":\"1258PO\", \"hardwareRevision\":\"12345fsd\",  \"firmwareRevision\":\"12345fsd\", \"softwareRevision\":\"12345fsd\", \"notificationToken\":\"12345fsd\", \"createdTsEpoch\":1446587257146, \"createdTs\":\"2015-11-03T21:47:37.324Z\", \"osName\":\"Bill\", \"systemId\":\"258\", \"cardRelationships\": [\(cardRelationship)],\"licenseKey\":\"147PLO\", \"bdAddress\":\"someAddress\", \"pairing\":\"pairing\", \"secureElementId\":\"456987lo\", \"casd\":\"casd\"}")
        XCTAssertNotNil(deviceInfo)
        return deviceInfo
    }

    func getCardRelationship() -> CardRelationship? {
        let cardRelationship = try? CardRelationship ("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\", \"encryptedData\": \"2015-11-03T21:47:37.324Z\"}}, \"creditCardId\": \" 3698741\", \"pan\":\"pan\", \"expMonth\": 2, \"expYear\": 2018}")
        XCTAssertNotNil(cardRelationship)
        return cardRelationship
    }

    func getCommit() -> Commit? {
        let commit = try? Commit("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\"}},\"commitType\":\"NOT_EXIST\",\"createdTs\":1446587258151,\"commitId\":\"1\",\"previousCommit\":\"2\",\"encryptedData\":\"123\"}")
        XCTAssertNotNil(commit)
        return commit
    }

    func getCommitMetrics() -> CommitMetrics? {
        let commitStatistic = getCommitStatistic()?.toJSONString() ?? ""
        let commit = try? CommitMetrics("{\"syncId\":\"someId\",\"deviceId\":\"someId\",\"userId\":\"someId\",\"sdkVersion\":\"1\",\"osVersion\":\"2\",\"totalProcessingTimeMs\":1446587257146,\"initiator\":\"PLATFORM\",\"commits\":[\(commitStatistic)]}")
        XCTAssertNotNil(commit)
        return commit
    }

    func getApduPackage() -> ApduPackage? {
        let apduCommand = getApduCommand()?.toJSONString() ?? ""
        let apduPackage = try? ApduPackage("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\"}}, \"seIdType\": \"newType\", \"targetDeviceType\": \"deviceType\", \"targetDeviceId\": \"1111111\", \"packageId\": \"222222\", \"seId\": \"147\", \"commandApdus\": [\(apduCommand)], \"state\": \"PROCESSED\", \"executedEpoch\": 1446587257146, \"executedDuration\": 5.0, \"validUntil\": \"2015-11-03T21:47:37.324Z\", \"validUntilEpoch\": \"2015-11-03T21:47:37.324Z\", \"apduPackageUrl\": \"www.example.com\"}")
        XCTAssertNotNil(apduPackage)
        return apduPackage
    }

    func getApduCommand() -> APDUCommand? {
        let apduCommand = try? APDUCommand("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\", \"encryptedData\": \"2015-11-03T21:47:37.324Z\"}}, \"commandId\": \"896poi\", \"groupId\": 1, \"sequence\": 1, \"command\": \"command\", \"type\": \"new\"}")
        XCTAssertNotNil(apduCommand)
        return apduCommand
    }

    func getEncryptionKey() -> EncryptionKey? {
        let encryptionKey = try? EncryptionKey("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\", \"encryptedData\": \"2015-11-03T21:47:37.324Z\"}}, \"keyId\": \"896poi\", \"createdTs\": \"2015-11-03T21:47:37.324Z\", \"createdTsEpoch\": 1446587257146, \"expirationTs\": \"2015-11-03T21:47:37.324Z\", \"expirationTsEpoch\": 1446587257146, \"serverPublicKey\": \"someKey\", \"clientPublicKey\": \"someKey\", \"active\": true}")
        XCTAssertNotNil(encryptionKey)
        return encryptionKey
    }

    func getVerificationMethod() -> VerificationMethod? {
        let a2AContext = getA2AContext()?.toJSONString() ?? ""
        let encryptionKey = try? VerificationMethod("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\", \"encryptedData\": \"2015-11-03T21:47:37.324Z\"}}, \"verificationId\": \"896poi\", \"state\": \"AVAILABLE_FOR_SELECTION\", \"methodType\": \"TEXT_TO_CARDHOLDER_NUMBER\", \"value\": \"someValue\", \"verificationResult\": \"SUCCESS\", \"createdTs\": \"2015-11-03T21:47:37.324Z\", \"createdTsEpoch\": 1446587257146, \"lastModifiedTs\": \"2015-11-03T21:47:37.324Z\", \"lastModifiedTsEpoch\": 1446587257146, \"verifiedTs\": \"2015-11-03T21:47:37.324Z\", \"verifiedTsEpoch\": 1446587257146, \"appToAppContext\":\(a2AContext)}")
        XCTAssertNotNil(encryptionKey)
        return encryptionKey
    }

    func getA2AContext() -> A2AContext? {
        let a2AContext = try? A2AContext("{\"applicationId\": \"896poi\", \"action\": \"someAction\", \"payload\": \"somePayload\"}")
        XCTAssertNotNil(a2AContext)
        return a2AContext
    }

    open var pan: String?
    open var expMonth: Int?
    open var expYear: Int?
    open var cvv: String?
    open var creditCardId: String?
    open var name: String?
    open var address: Address?

    func getCreditCardInfo() -> CardInfo? {
        let address = getAddress()?.toJSONString() ?? ""
        let cardInfo = try? CardInfo("{\"pan\":\"pan\", \"expMonth\": 2, \"expYear\": 2018, \"cvv\":\"cvv\", \"creditCardId\": \"someId\", \"name\": \"someName\",\"address\": \(address)}")
        return cardInfo
    }

    func getCreditCard() -> CreditCard? {
        let cardMetadata = getCreditCardMetadata()?.toJSONString() ?? ""
        let termsAssetReferences = getTermsAssetReferences()?.toJSONString() ?? ""
        let deviceRelationship = getDeviceRelationship()?.toJSONString() ?? ""
        let verificationMethod = getVerificationMethod()?.toJSONString() ?? ""
        let address = getAddress()?.toJSONString() ?? ""
        let apduCommand = getApduCommand()?.toJSONString() ?? ""
        let creditCardInfo = getCreditCardInfo()

        let creditCard = try? CreditCard("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\", \"encryptedData\": \"2015-11-03T21:47:37.324Z\"}}, \"creditCardId\": \"896poi\",\"userId\": \"896poi\", \"default\": true,  \"createdTs\": \"2015-11-03T21:47:37.324Z\", \"createdTsEpoch\": 1446587257146, \"state\": \"NOT_ELIGIBLE\", \"cardType\": \"someType\", \"cardMetaData\": \(cardMetadata), \"termsAssetId\": \"2324Z\", \"termsAssetReferences\": [\(termsAssetReferences)], \"eligibilityExpiration\": \"2015-11-03T21:47:37.324Z\", \"eligibilityExpirationEpoch\": 1446587257146, \"deviceRelationships\": [\(deviceRelationship)], \"encryptedData\":\"someData\", \"targetDeviceId\": \"896poi\", \"targetDeviceType\": \"someType\", \"verificationMethods\": [\(verificationMethod)], \"externalTokenReference\": \"someToken\", \"pan\": \"1234\", \"expMonth\": 12, \"expYear\": 2018, \"cvv\": \"123\", \"name\": \"someName\", \"address\": \(address), \"offlineSeActions.topOfWallet.apduCommands\": [\(apduCommand)]}")
        creditCard?.info = creditCardInfo
        XCTAssertNotNil(creditCard)
        return creditCard
    }

     func getCreditCardMetadata() -> CardMetadata? {
        let image = getImage()?.toJSONString() ?? ""
        let creditCardMetadata = try? CardMetadata("{\"labelColor\":\"00000\",\"issuerName\":\"JPMorgan Chase\",\"shortDescription\":\"Chase Freedom Visa\",\"longDescription\":\"Chase Freedom Visa with the super duper rewards\",\"contactUrl\":\"www.chase.com\",\"contactPhone\":\"18001234567\",\"contactEmail\":\"goldcustomer@chase.com\",\"termsAndConditionsUrl\":\"http://visa.com/terms\",\"privacyPolicyUrl\":\"http://visa.com/privacy\",\"brandLogo\":[\(image)],\"cardBackground\":[\(image)],\"cardBackgroundCombined\":[\(image)],\"icon\":[\(image),[\(image)]],\"issuerLogo\":[\(image)]}")
        XCTAssertNotNil(creditCardMetadata)
        return creditCardMetadata
    }

    func getTermsAssetReferences() -> TermsAssetReferences? {
        let termsAssetReferences = try? TermsAssetReferences("{\"_links\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\", \"encryptedData\": \"2015-11-03T21:47:37.324Z\"},\"mimeType\":\"text/html\"}")
        XCTAssertNotNil(termsAssetReferences)
        return termsAssetReferences
    }

    func getDeviceRelationship() -> DeviceRelationships? {
        let deviceRelationship = try? DeviceRelationships("{\"deviceType\":\"ACTIVITY_TRACKER\",\"deviceIdentifier\":\"677af018-01b1-47d9-9b08-0c18d89aa2e3\",\"manufacturerName\":\"Pebble\",\"deviceName\":\"Pebble Time\",\"serialNumber\":\"074DCC022E14\",\"modelNumber\":\"FB404\",\"hardwareRevision\":\"1.0.0.0\",\"firmwareRevision\":\"1030.6408.1309.0001\",\"softwareRevision\":\"2.0.242009.6\",\"createdTs\":\"2015-11-03T21:47:37.146+0000\",\"createdTsEpoch\":1446587257146,\"osName\":\"ANDROID\",\"systemId\":\"0x123456FFFE9ABCDE\"}")
        XCTAssertNotNil(deviceRelationship)
        return deviceRelationship

    }

    func getAddress() -> Address? {
        let address = try? Address("{\"street1\":\"1035 Pearl St\",\"street2\":\"5th Floor\",\"street3\":\"8th Floor\",\"city\":\"Boulder\",\"state\":\"CO\",\"postalCode\":\"80302\",\"countryCode\":\"US\"}")
        XCTAssertNotNil(address)
        return address
    }

    func getImage() -> Image? {
        let image = try? Image("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\", \"encryptedData\": \"2015-11-03T21:47:37.324Z\"}},\"mimeType\":\"image/gif\",\"height\":20,\"width\":60}")
        XCTAssertNotNil(image)
        return image
    }

    func getRtmConfig() -> RtmConfig? {
        let info = getDeviceInfo()?.toJSONString() ?? ""
        let rtmConfig = try? RtmConfig("{\"clientId\":\"someId\",\"redirectUri\":\"https://api.fit-pay.com\",\"userEmail\":\"someEmail\",\"paymentDevice\":\(info),\"account\":false,\"version\":\"2\",\"demoMode\":false,\"themeOverrideCssUrl\":\"https://api.fit-pay.com\",\"demoCardGroup\":\"someGroup\",\"accessToken\":\"someToken\",\"language\":\"en\",\"baseLangUrl\":\"https://api.fit-pay.com\",\"useWebCardScanner\":false}")
        XCTAssertNotNil(rtmConfig)
        return rtmConfig
    }

    func getRtmMessageResponse() -> RtmMessageResponse? {
        let rtmMessage = try? RtmMessageResponse("{\"callBackId\":1,\"data\":{\"data\":\"someData\"},\"type\":\"someType\", \"isSuccess\":true}")
        XCTAssertNotNil(rtmMessage)
        return rtmMessage
    }

    func getRtmDeviceInfo() -> RtmDeviceInfo? {
        let cardRelationship = getCardRelationship()?.toJSONString() ?? ""
        let deviceInfo = try? RtmDeviceInfo("{ \"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\"}}, \"deviceIdentifier\":\"123456789\", \"deviceName\":\"noName\", \"deviceType\":\"myType\", \"manufacturerName\":\"12345fsd\", \"state\":\"12345fsd\", \"serialNumber\":\"987654321\", \"modelNumber\":\"1258PO\", \"hardwareRevision\":\"12345fsd\",  \"firmwareRevision\":\"12345fsd\", \"softwareRevision\":\"12345fsd\", \"notificationToken\":\"12345fsd\", \"createdTsEpoch\":1446587257146, \"createdTs\":\"2015-11-03T21:47:37.324Z\", \"osName\":\"Bill\", \"systemId\":\"258\", \"cardRelationships\": [\(cardRelationship)],\"licenseKey\":\"147PLO\", \"bdAddress\":\"someAddress\", \"pairing\":\"pairing\", \"secureElementId\":\"456987lo\", \"casd\":\"casd\"}")
        XCTAssertNotNil(deviceInfo)
        return deviceInfo
    }

    func getRtmSecureDeviceInfo() -> RtmSecureDeviceInfo? {
        let deviceInfo = getDeviceInfo()?.toJSONString() ?? ""
        let rtmSecureDeviceInfo = try? RtmSecureDeviceInfo (deviceInfo)
        XCTAssertNotNil(rtmSecureDeviceInfo)
        return rtmSecureDeviceInfo
    }

    func getRelationship() -> Relationship? {
        let deviceInfo = getDeviceInfo()?.toJSONString() ?? ""
        let cardInfo = getCreditCard()?.info?.toJSONString() ?? ""
        let relationship = try? Relationship("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\"}}, \"card\":\(cardInfo), \"device\":\(deviceInfo)}")
        XCTAssertNotNil(relationship)
        return relationship
    }

    func getIssuers() -> Issuers? {
        let issuers = try? Issuers("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\"}}, \"countries\": {\"cardNetworks\":{\"issuers\":[\"someNetwork\"]}}}")
    XCTAssertNotNil(issuers)
    return issuers
    }

    func getResultCollection() -> ResultCollection<DeviceInfo>? {
    let info = getDeviceInfo()?.toJSONString() ?? ""
    let resultCollection = try? ResultCollection<DeviceInfo>("{\"_links\":{\"self\":{\"href\":\"https://api.fit-pay.com/users/9469bfe0-3fa1-4465-9abf-f78cacc740b2/devices/677af018-01b1-47d9-9b08-0c18d89aa2e3/commits/57717bdb6d213e810137ee21adb7e883fe0904e9\"}}, \"limit\":1, \"offset\":1, \"totalResults\":1, \"results\":[\(info)]}")
    XCTAssertNotNil(resultCollection)
    return resultCollection
    }

}
