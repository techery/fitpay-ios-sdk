//
//  ModelsParsingTests.swift
//  FitpaySDK
//
//  Created by Illya Kyznetsov on 5/15/18.
//  Copyright © 2018 Fitpay. All rights reserved.
//

import XCTest
@testable import FitpaySDK

class ModelsParsingTests: XCTestCase {
    let mockModels = MockModels()

    func testCommitStatistic() {
        let commitStatistic = mockModels.getCommitStatistic()

        XCTAssertNotNil(commitStatistic?.commitId)
        XCTAssertNotNil(commitStatistic?.processingTimeMs)
        XCTAssertNotNil(commitStatistic?.averageTimePerCommand)
        XCTAssertNotNil(commitStatistic?.errorReason)

        let json = commitStatistic?.toJSON()
        XCTAssertNotNil(json?["commitId"])
        XCTAssertNotNil(json?["processingTimeMs"])
        XCTAssertNotNil(json?["averageTimePerCommand"])
        XCTAssertNotNil(json?["errorReason"])
    }

    func testTransaction() {
        let transaction = mockModels.getTransaction()

        XCTAssertNotNil(transaction?.links)
        XCTAssertNotNil(transaction?.transactionId)
        XCTAssertNotNil(transaction?.transactionType)
        XCTAssertNotNil(transaction?.amount)
        XCTAssertNotNil(transaction?.currencyCode)
        XCTAssertNotNil(transaction?.authorizationStatus)
        XCTAssertNotNil(transaction?.transactionTime)
        XCTAssertNotNil(transaction?.transactionTimeEpoch)
        XCTAssertNotNil(transaction?.merchantName)
        XCTAssertNotNil(transaction?.merchantCode)
        XCTAssertNotNil(transaction?.merchantType)

        let json = transaction?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["transactionId"])
        XCTAssertNotNil(json?["transactionType"])
        XCTAssertNotNil(json?["amount"])
        XCTAssertNotNil(json?["currencyCode"])
        XCTAssertNotNil(json?["authorizationStatus"])
        XCTAssertNotNil(json?["transactionTime"])
        XCTAssertNotNil(json?["transactionTimeEpoch"])
        XCTAssertNotNil(json?["merchantName"])
        XCTAssertNotNil(json?["merchantCode"])
        XCTAssertNotNil(json?["merchantType"])
    }

    func testUser() {
        let user = mockModels.getUser()

        XCTAssertNotNil(user?.links)
        XCTAssertNotNil(user?.id)
        XCTAssertNotNil(user?.created)
        XCTAssertNotNil(user?.createdEpoch)
        XCTAssertNotNil(user?.encryptedData)
        XCTAssertNotNil(user?.lastModifiedEpoch)

        let json = user?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["id"])
        XCTAssertNotNil(json?["createdTs"])
        XCTAssertNotNil(json?["createdTsEpoch"])
        XCTAssertNotNil(json?["lastModifiedTs"])
        XCTAssertNotNil(json?["lastModifiedTsEpoch"])
        XCTAssertNotNil(json?["encryptedData"])
    }

    func testDeviceInfo() {
        func checkProperties(deviceInfo: RtmDeviceInfo?) {
            XCTAssertNotNil(deviceInfo?.links)
            XCTAssertNotNil(deviceInfo?.deviceIdentifier)
            XCTAssertNotNil(deviceInfo?.deviceName)
            XCTAssertNotNil(deviceInfo?.deviceType)
            XCTAssertNotNil(deviceInfo?.manufacturerName)
            XCTAssertNotNil(deviceInfo?.state)
            XCTAssertNotNil(deviceInfo?.serialNumber)
            XCTAssertNotNil(deviceInfo?.modelNumber)
            XCTAssertNotNil(deviceInfo?.hardwareRevision)
            XCTAssertNotNil(deviceInfo?.firmwareRevision)
            XCTAssertNotNil(deviceInfo?.softwareRevision)
            XCTAssertNotNil(deviceInfo?.notificationToken)
            XCTAssertNotNil(deviceInfo?.createdEpoch)
            XCTAssertNotNil(deviceInfo?.created)
            XCTAssertNotNil(deviceInfo?.osName)
            XCTAssertNotNil(deviceInfo?.systemId)
            XCTAssertNotNil(deviceInfo?.cardRelationships)
            XCTAssertNotNil(deviceInfo?.licenseKey)
            XCTAssertNotNil(deviceInfo?.bdAddress)
            XCTAssertNotNil(deviceInfo?.pairing)
            XCTAssertNotNil(deviceInfo?.secureElementId)
            XCTAssertNotNil(deviceInfo?.casd)
            XCTAssertNotNil(deviceInfo?.shortRTMRepersentation)

            let json = deviceInfo?.toJSON()
            XCTAssertNotNil(json?["_links"])
            XCTAssertNotNil(json?["deviceIdentifier"])
            XCTAssertNotNil(json?["deviceName"])
            XCTAssertNotNil(json?["deviceType"])
            XCTAssertNotNil(json?["manufacturerName"])
            XCTAssertNotNil(json?["state"])
            XCTAssertNotNil(json?["serialNumber"])
            XCTAssertNotNil(json?["modelNumber"])
            XCTAssertNotNil(json?["hardwareRevision"])
            XCTAssertNotNil(json?["firmwareRevision"])
            XCTAssertNotNil(json?["softwareRevision"])
            XCTAssertNotNil(json?["notificationToken"])
            XCTAssertNotNil(json?["createdTsEpoch"])
            XCTAssertNotNil(json?["createdTs"])
            XCTAssertNotNil(json?["osName"])
            XCTAssertNotNil(json?["systemId"])
            XCTAssertNotNil(json?["_links"])
            XCTAssertNotNil(json?["deviceIdentifier"])
            XCTAssertNotNil(json?["deviceName"])
            XCTAssertNotNil(json?["deviceType"])
            XCTAssertNotNil(json?["manufacturerName"])
            XCTAssertNotNil(json?["state"])
            XCTAssertNotNil(json?["serialNumber"])
            XCTAssertNotNil(json?["modelNumber"])
            XCTAssertNotNil(json?["hardwareRevision"])
            XCTAssertNotNil(json?["firmwareRevision"])
            XCTAssertNotNil(json?["softwareRevision"])
            XCTAssertNotNil(json?["notificationToken"])
            XCTAssertNotNil(json?["createdTsEpoch"])
            XCTAssertNotNil(json?["createdTs"])
            XCTAssertNotNil(json?["osName"])
            XCTAssertNotNil(json?["systemId"])
            XCTAssertNotNil(json?["cardRelationships"])
            XCTAssertNotNil(json?["licenseKey"])
            XCTAssertNotNil(json?["bdAddress"])
            XCTAssertNotNil(json?["pairing"])
            XCTAssertNotNil(json?["secureElementId"])
            XCTAssertNotNil(json?["casd"])
        }

        let rtmDeviceInfo = mockModels.getRtmDeviceInfo()
        checkProperties(deviceInfo: rtmDeviceInfo)

        guard let deviceInfo = mockModels.getDeviceInfo() else { XCTAssert(false, "Bad parsing."); return }
        let rtmDeviceInfoFromDeviceInfo = RtmDeviceInfo(deviceInfo: deviceInfo)
        checkProperties(deviceInfo: rtmDeviceInfoFromDeviceInfo)

        guard let secureDeviceInfo = mockModels.getRtmSecureDeviceInfo() else { XCTAssert(false, "Bad parsing."); return }
        checkProperties(deviceInfo: secureDeviceInfo)
        secureDeviceInfo.copyFieldsFrom(deviceInfo: deviceInfo)
        checkProperties(deviceInfo: secureDeviceInfo)
    }

    func testCardRelationship() {
        let cardRelationship = mockModels.getCardRelationship()

        XCTAssertNotNil(cardRelationship?.links)
        XCTAssertNotNil(cardRelationship?.creditCardId)
        XCTAssertNotNil(cardRelationship?.pan)
        XCTAssertNotNil(cardRelationship?.expMonth)
        XCTAssertNotNil(cardRelationship?.expYear)

        let cardRelationshipJson = cardRelationship?.toJSON()
        XCTAssertNotNil(cardRelationshipJson?["_links"])
        XCTAssertNotNil(cardRelationshipJson?["creditCardId"])
        XCTAssertNotNil(cardRelationshipJson?["pan"])
        XCTAssertNotNil(cardRelationshipJson?["expMonth"])
        XCTAssertNotNil(cardRelationshipJson?["expYear"])
    }

    func testCommit() {
        let commit = mockModels.getCommit()

        XCTAssertNotNil(commit?.links)
        XCTAssertNotNil(commit?.commitTypeString)
        XCTAssertNotNil(commit?.created)
        XCTAssertNotNil(commit?.previousCommit)
        XCTAssertNotNil(commit?.commit)
        XCTAssertNotNil(commit?.encryptedData)

        let json = commit?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["commitType"])
        XCTAssertNotNil(json?["createdTs"])
        XCTAssertNotNil(json?["previousCommit"])
        XCTAssertNotNil(json?["commitId"])
        XCTAssertNotNil(json?["encryptedData"])
    }

    func testCommitMetrics() {
        let commitMetrics = mockModels.getCommitMetrics()

        XCTAssertNotNil(commitMetrics?.syncId)
        XCTAssertNotNil(commitMetrics?.deviceId)
        XCTAssertNotNil(commitMetrics?.userId)
        XCTAssertNotNil(commitMetrics?.sdkVersion)
        XCTAssertNotNil(commitMetrics?.osVersion)
        XCTAssertNotNil(commitMetrics?.initiator)
        XCTAssertNotNil(commitMetrics?.totalProcessingTimeMs)
        XCTAssertNotNil(commitMetrics?.commitStatistics)

        let json = commitMetrics?.toJSON()
        XCTAssertNotNil(json?["syncId"])
        XCTAssertNotNil(json?["deviceId"])
        XCTAssertNotNil(json?["userId"])
        XCTAssertNotNil(json?["sdkVersion"])
        XCTAssertNotNil(json?["osVersion"])
        XCTAssertNotNil(json?["initiator"])
        XCTAssertNotNil(json?["totalProcessingTimeMs"])
        XCTAssertNotNil(json?["commits"])
    }

    func testApduPackage() {
        let apduPackage = mockModels.getApduPackage()

        XCTAssertNotNil(apduPackage?.links)
        XCTAssertNotNil(apduPackage?.seIdType)
        XCTAssertNotNil(apduPackage?.targetDeviceType)
        XCTAssertNotNil(apduPackage?.targetDeviceId)
        XCTAssertNotNil(apduPackage?.packageId)
        XCTAssertNotNil(apduPackage?.seId)
        XCTAssertNotNil(apduPackage?.apduCommands)
        XCTAssertNotNil(apduPackage?.validUntil)
        XCTAssertNotNil(apduPackage?.validUntilEpoch)
        XCTAssertNotNil(apduPackage?.apduPackageUrl)
        XCTAssertNotNil(apduPackage?.responseDictionary)
        XCTAssertTrue(apduPackage?.isExpired ?? false)

        let json = apduPackage?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["seIdType"])
        XCTAssertNotNil(json?["targetDeviceType"])
        XCTAssertNotNil(json?["targetDeviceId"])
        XCTAssertNotNil(json?["packageId"])
        XCTAssertNotNil(json?["seId"])
        XCTAssertNotNil(json?["commandApdus"])
        XCTAssertNotNil(json?["validUntil"])
        XCTAssertNotNil(json?["apduPackageUrl"])
    }

    func testAPDUCommand() {
        let apduCommand = mockModels.getApduCommand()

        XCTAssertNotNil(apduCommand?.links)
        XCTAssertNotNil(apduCommand?.commandId)
        XCTAssertNotNil(apduCommand?.groupId)
        XCTAssertNotNil(apduCommand?.sequence)
        XCTAssertNotNil(apduCommand?.command)
        XCTAssertNotNil(apduCommand?.type)
        XCTAssertNotNil(apduCommand?.continueOnFailure)
        XCTAssertNotNil(apduCommand?.responseDictionary)

        let json = apduCommand?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["commandId"])
        XCTAssertNotNil(json?["groupId"])
        XCTAssertNotNil(json?["sequence"])
        XCTAssertNotNil(json?["command"])
        XCTAssertNotNil(json?["type"])
        XCTAssertNotNil(json?["continueOnFailure"])
    }

    func testEncryptionKey() {
        let encryptionKey = mockModels.getEncryptionKey()

        XCTAssertNotNil(encryptionKey?.links)
        XCTAssertNotNil(encryptionKey?.keyId)
        XCTAssertNotNil(encryptionKey?.created)
        XCTAssertNotNil(encryptionKey?.createdEpoch)
        XCTAssertNotNil(encryptionKey?.expiration)
        XCTAssertNotNil(encryptionKey?.expirationEpoch)
        XCTAssertNotNil(encryptionKey?.serverPublicKey)
        XCTAssertNotNil(encryptionKey?.clientPublicKey)
        XCTAssertNotNil(encryptionKey?.active)

        let json = encryptionKey?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["keyId"])
        XCTAssertNotNil(json?["createdTs"])
        XCTAssertNotNil(json?["createdTsEpoch"])
        XCTAssertNotNil(json?["expirationTs"])
        XCTAssertNotNil(json?["expirationTsEpoch"])
        XCTAssertNotNil(json?["serverPublicKey"])
        XCTAssertNotNil(json?["clientPublicKey"])
        XCTAssertNotNil(json?["active"])
    }

    func testVerificationMethod() {
        let verificationMethod = mockModels.getVerificationMethod()

        XCTAssertNotNil(verificationMethod?.links)
        XCTAssertNotNil(verificationMethod?.verificationId)
        XCTAssertNotNil(verificationMethod?.state)
        XCTAssertNotNil(verificationMethod?.methodType)
        XCTAssertNotNil(verificationMethod?.value)
        XCTAssertNotNil(verificationMethod?.created)
        XCTAssertNotNil(verificationMethod?.createdEpoch)
        XCTAssertNotNil(verificationMethod?.lastModified)
        XCTAssertNotNil(verificationMethod?.lastModifiedEpoch)
        XCTAssertNotNil(verificationMethod?.verified)
        XCTAssertNotNil(verificationMethod?.verifiedEpoch)
        XCTAssertNotNil(verificationMethod?.appToAppContext)

        let json = verificationMethod?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["verificationId"])
        XCTAssertNotNil(json?["state"])
        XCTAssertNotNil(json?["methodType"])
        XCTAssertNotNil(json?["value"])
        XCTAssertNotNil(json?["verificationResult"])
        XCTAssertNotNil(json?["createdTsEpoch"])
        XCTAssertNotNil(json?["lastModifiedTs"])
        XCTAssertNotNil(json?["lastModifiedTsEpoch"])
        XCTAssertNotNil(json?["verifiedTs"])
        XCTAssertNotNil(json?["verifiedTsEpoch"])
        XCTAssertNotNil(json?["appToAppContext"])
    }

    func testCreditCard() {
        let creditCard = mockModels.getCreditCard()

        XCTAssertNotNil(creditCard?.links)
        XCTAssertNotNil(creditCard?.creditCardId)
        XCTAssertNotNil(creditCard?.userId)
        XCTAssertNotNil(creditCard?.isDefault)
        XCTAssertNotNil(creditCard?.created)
        XCTAssertNotNil(creditCard?.createdEpoch)
        XCTAssertNotNil(creditCard?.state)
        XCTAssertNotNil(creditCard?.cardType)
        XCTAssertNotNil(creditCard?.cardMetaData)
        XCTAssertNotNil(creditCard?.termsAssetId)
        XCTAssertNotNil(creditCard?.termsAssetReferences)
        XCTAssertNotNil(creditCard?.eligibilityExpiration)
        XCTAssertNotNil(creditCard?.deviceRelationships)
        XCTAssertNotNil(creditCard?.encryptedData)
        XCTAssertNotNil(creditCard?.targetDeviceId)
        XCTAssertNotNil(creditCard?.targetDeviceType)
        XCTAssertNotNil(creditCard?.verificationMethods)
        XCTAssertNotNil(creditCard?.externalTokenReference)
        XCTAssertNotNil(creditCard?.pan)
        XCTAssertNotNil(creditCard?.expMonth)
        XCTAssertNotNil(creditCard?.expYear)
        XCTAssertNotNil(creditCard?.cvv)
        XCTAssertNotNil(creditCard?.name)
        XCTAssertNotNil(creditCard?.address)
        XCTAssertNotNil(creditCard?.topOfWalletAPDUCommands)

        let json = creditCard?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["creditCardId"])
        XCTAssertNotNil(json?["default"])
        XCTAssertNotNil(json?["createdTs"])
        XCTAssertNotNil(json?["createdTsEpoch"])
        XCTAssertNotNil(json?["state"])
        XCTAssertNotNil(json?["cardType"])
        XCTAssertNotNil(json?["cardMetaData"])
        XCTAssertNotNil(json?["termsAssetId"])
        XCTAssertNotNil(json?["termsAssetReferences"])
        XCTAssertNotNil(json?["eligibilityExpiration"])
        XCTAssertNotNil(json?["eligibilityExpirationEpoch"])
        XCTAssertNotNil(json?["deviceRelationships"])
        XCTAssertNotNil(json?["encryptedData"])
        XCTAssertNotNil(json?["targetDeviceId"])
        XCTAssertNotNil(json?["targetDeviceType"])
        XCTAssertNotNil(json?["verificationMethods"])
        XCTAssertNotNil(json?["externalTokenReference"])
        XCTAssertNotNil(json?["pan"])
        XCTAssertNotNil(json?["expMonth"])
        XCTAssertNotNil(json?["expYear"])
        XCTAssertNotNil(json?["cvv"])
        XCTAssertNotNil(json?["name"])
        XCTAssertNotNil(json?["address"])
        XCTAssertNotNil(json?["offlineSeActions.topOfWallet.apduCommands"])
    }

    func testAddress() {
        let address = mockModels.getAddress()

        XCTAssertNotNil(address?.street1)
        XCTAssertNotNil(address?.street2)
        XCTAssertNotNil(address?.street3)
        XCTAssertNotNil(address?.city)
        XCTAssertNotNil(address?.state)
        XCTAssertNotNil(address?.postalCode)
        XCTAssertNotNil(address?.countryCode)

        let json = address?.toJSON()
        XCTAssertNotNil(json?["street1"])
        XCTAssertNotNil(json?["street2"])
        XCTAssertNotNil(json?["street3"])
        XCTAssertNotNil(json?["city"])
        XCTAssertNotNil(json?["state"])
        XCTAssertNotNil(json?["postalCode"])
        XCTAssertNotNil(json?["countryCode"])
    }

    func testImage() {
        let image = mockModels.getImage()

        XCTAssertNotNil(image?.links)
        XCTAssertNotNil(image?.mimeType)
        XCTAssertNotNil(image?.height)
        XCTAssertNotNil(image?.width)

        let json = image?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["mimeType"])
        XCTAssertNotNil(json?["height"])
        XCTAssertNotNil(json?["width"])
    }

    func testRtmConfig() {
        let rtmConfig = mockModels.getRtmConfig()
        
        XCTAssertNotNil(rtmConfig?.clientId)
        XCTAssertNotNil(rtmConfig?.redirectUri)
        XCTAssertNotNil(rtmConfig?.userEmail)
        XCTAssertNotNil(rtmConfig?.deviceInfo)
        XCTAssertNotNil(rtmConfig?.hasAccount)
        XCTAssertNotNil(rtmConfig?.version)
        XCTAssertNotNil(rtmConfig?.demoMode)
        XCTAssertNotNil(rtmConfig?.customCSSUrl)
        XCTAssertNotNil(rtmConfig?.demoCardGroup)
        XCTAssertNotNil(rtmConfig?.accessToken)
        XCTAssertNotNil(rtmConfig?.language)
        XCTAssertNotNil(rtmConfig?.baseLanguageUrl)
        XCTAssertNotNil(rtmConfig?.useWebCardScanner)

        let dict = rtmConfig?.jsonDict()
        XCTAssertNotNil(dict)

        let json = rtmConfig?.toJSON()
        XCTAssertNotNil(json?["clientId"])
        XCTAssertNotNil(json?["redirectUri"])
        XCTAssertNotNil(json?["userEmail"])
        XCTAssertNotNil(json?["paymentDevice"])
        XCTAssertNotNil(json?["account"])
        XCTAssertNotNil(json?["version"])
        XCTAssertNotNil(json?["demoMode"])
        XCTAssertNotNil(json?["themeOverrideCssUrl"])
        XCTAssertNotNil(json?["demoCardGroup"])
        XCTAssertNotNil(json?["accessToken"])
        XCTAssertNotNil(json?["language"])
        XCTAssertNotNil(json?["baseLangUrl"])
        XCTAssertNotNil(json?["useWebCardScanner"])

        rtmConfig?.update(value: "someProperty", forKey: "clientId")
        XCTAssertEqual(rtmConfig?.clientId, "someProperty")
        rtmConfig?.update(value: "someProperty", forKey: "redirectUri")
        XCTAssertEqual(rtmConfig?.redirectUri, "someProperty")
        rtmConfig?.update(value: "someProperty", forKey: "userEmail")
        XCTAssertEqual(rtmConfig?.userEmail, "someProperty")
        rtmConfig?.update(value: "DeviceInfo", forKey: "paymentDevice")
        XCTAssertEqual(rtmConfig?.deviceInfo, nil)
        rtmConfig?.update(value: false, forKey: "account")
        XCTAssertEqual(rtmConfig?.hasAccount, false)
        rtmConfig?.update(value: "someProperty", forKey: "version")
        XCTAssertEqual(rtmConfig?.version, "someProperty")
        rtmConfig?.update(value: false, forKey: "demoMode")
        XCTAssertEqual(rtmConfig?.demoMode, false)
        rtmConfig?.update(value: "someProperty", forKey: "themeOverrideCssUrl")
        XCTAssertEqual(rtmConfig?.customCSSUrl, "someProperty")
        rtmConfig?.update(value: "someProperty", forKey: "demoCardGroup")
        XCTAssertEqual(rtmConfig?.demoCardGroup, "someProperty")
        rtmConfig?.update(value: "someProperty", forKey: "accessToken")
        XCTAssertEqual(rtmConfig?.accessToken, "someProperty")
        rtmConfig?.update(value: "someProperty", forKey: "language")
        XCTAssertEqual(rtmConfig?.language, "someProperty")
        rtmConfig?.update(value: "someProperty", forKey: "baseLangUrl")
        XCTAssertEqual(rtmConfig?.baseLanguageUrl, "someProperty")
        rtmConfig?.update(value: false, forKey: "useWebCardScanner")
        XCTAssertEqual(rtmConfig?.useWebCardScanner, false)
    }

    func testRtmMessage() {
        let rtmMessage = mockModels.getRtmMessageResponse()

        XCTAssertNotNil(rtmMessage?.callBackId)
        XCTAssertNotNil(rtmMessage?.data)
        XCTAssertNotNil(rtmMessage?.type)
        XCTAssertNotNil(rtmMessage?.success)

        let json = rtmMessage?.toJSON()
        XCTAssertNotNil(json?["callBackId"])
        XCTAssertNotNil(json?["type"])
        XCTAssertNotNil(json?["isSuccess"])
    }

    func testRelationship() {
        let relationship = mockModels.getRelationship()

        XCTAssertNotNil(relationship?.links)
        XCTAssertNotNil(relationship?.card)
        XCTAssertNotNil(relationship?.device)

        let json = relationship?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["card"])
        XCTAssertNotNil(json?["device"])
    }

    func testIssuers() {
        let issuers = mockModels.getIssuers()

        XCTAssertNotNil(issuers?.links)
        XCTAssertNotNil(issuers?.countries)

        let json = issuers?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["countries"])
    }

    func testA2AIssuerRequestEncodingString() {
        let a2AIssuerRequest = A2AIssuerRequest(response: A2AStepupResult.Approved, authCode: "someCode")
        XCTAssertNotNil(a2AIssuerRequest.getEncodedString())
    }

    func testResultCollection() {
        let resultCollection = mockModels.getResultCollection()
        
        XCTAssertNotNil(resultCollection?.links)
        XCTAssertNotNil(resultCollection?.limit)
        XCTAssertNotNil(resultCollection?.offset)
        XCTAssertNotNil(resultCollection?.totalResults)
        XCTAssertNotNil(resultCollection?.results)

        let json = resultCollection?.toJSON()
        XCTAssertNotNil(json?["_links"])
        XCTAssertNotNil(json?["limit"])
        XCTAssertNotNil(json?["offset"])
        XCTAssertNotNil(json?["totalResults"])
    }
}
