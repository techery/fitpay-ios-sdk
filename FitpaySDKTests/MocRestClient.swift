//
//  MocRestClient.swift
//  FitpaySDK
//
//  Created by Illya Kyznetsov on 5/29/18.
//  Copyright © 2018 Fitpay. All rights reserved.
//

import UIKit

 class MocRestClient: RestClient {

    // MARK: - Confirm package

    override func confirm(_ url: String, executionResult: NonAPDUCommitState, completion: @escaping ConfirmCommitHandler) {
        self.prepareAuthAndKeyHeaders { (headers, error) in
            guard let headers = headers  else {
                DispatchQueue.main.async { completion(error) }
                return
            }

            let params = ["result": executionResult.description]
            let request = self._manager.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            self.makeRequest(request: request) { (resultValue, error) in
                completion(error)
            }
        }
    }

    /**
     Endpoint to allow for returning responses to APDU execution

     - parameter package:    ApduPackage object
     - parameter completion: ConfirmAPDUPackageHandler closure
     */
    @objc override func confirmAPDUPackage(_ url: String, package: ApduPackage, completion: @escaping ConfirmAPDUPackageHandler) {
        guard package.packageId != nil else {
            completion(ErrorResponse(domain: RestClient.self, errorCode: ErrorCode.badRequest.rawValue, errorMessage: "packageId should not be nil"))
            return
        }

        self.prepareAuthAndKeyHeaders { (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(error) }
                return
            }

            let request = self._manager.request(url, method: .post, parameters: package.responseDictionary, encoding: JSONEncoding.default, headers: headers)
            self.makeRequest(request: request) { (resultValue, error) in
                completion(error)
            }
        }
    }


    // MARK: - Transactions

    @objc override func transactions(_ url: String, limit: Int, offset: Int, completion: @escaping TransactionsHandler) {
        let parameters = ["limit": "\(limit)", "offset": "\(offset)"]
        self.transactions(url, parameters: parameters, completion: completion)
    }

    @objc override func transactions(_ url: String, parameters: [String: Any]?, completion: @escaping TransactionsHandler) {
        self.prepareAuthAndKeyHeaders { (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let request = self._manager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            self.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let transaction = try? ResultCollection<Transaction>(resultValue)
                transaction?.client = self
                completion(transaction, error)
            }
        }
    }



    // MARK: - Encryption

    /**
     Creates a new encryption key pair

     - parameter clientPublicKey: client public key
     - parameter completion:      CreateEncryptionKeyHandler closure
     */
    @objc override func createEncryptionKey(clientPublicKey: String, completion: @escaping CreateEncryptionKeyHandler) {
        let headers = self.defaultHeaders
        let parameters = ["clientPublicKey": clientPublicKey]

        let request = _manager.request(FitpayConfig.apiURL + "/config/encryptionKeys", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        self.makeRequest(request: request) { (resultValue, error) in
            guard let resultValue = resultValue else {
                completion(nil, error)
                return
            }
            completion(try? EncryptionKey(resultValue), error)
        }
    }

    /**
     Retrieve and individual key pair

     - parameter keyId:      key id
     - parameter completion: EncryptionKeyHandler closure
     */
    @objc override func encryptionKey(_ keyId: String, completion: @escaping EncryptionKeyHandler) {
        let headers = self.defaultHeaders
        let request = _manager.request(FitpayConfig.apiURL + "/config/encryptionKeys/" + keyId, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        self.makeRequest(request: request) { (resultValue, error) in
            guard let resultValue = resultValue else {
                completion(nil, error)
                return
            }
            completion(try? EncryptionKey(resultValue), error)
        }
    }

    /**
     Deletes encryption key

     - parameter keyId:      key id
     - parameter completion: DeleteEncryptionKeyHandler
     */
    @objc override func deleteEncryptionKey(_ keyId: String, completion: @escaping DeleteEncryptionKeyHandler) {
        let headers = self.defaultHeaders
        let request = _manager.request(FitpayConfig.apiURL + "/config/encryptionKeys/" + keyId, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        request.validate().responseString { (response: DataResponse<String>) in
            DispatchQueue.main.async {
                completion(response.result.error)
            }
        }
    }

    @objc override func createKeyIfNeeded(_ completion: @escaping CreateKeyIfNeededHandler) {
        if let key = self.key, !key.isExpired() {
            completion(key, nil)
        } else {
            self.createEncryptionKey(clientPublicKey: self.keyPair.publicKey!) { [weak self] (encryptionKey, error) in
                if let error = error {
                    completion(nil, error)
                } else if let encryptionKey = encryptionKey {
                    self?.key = encryptionKey
                    completion(self?.key, nil)
                }
            }
        }
    }



    // MARK: Request Signature Helpers

    @objc override func createAuthHeaders(_ completion: CreateAuthHeaders) {
        if self._session.isAuthorized {
            completion(defaultHeaders + ["Authorization": "Bearer " + _session.accessToken!], nil)
        } else {
            completion(nil, ErrorResponse(domain: RestClient.self, errorCode: ErrorCode.unauthorized.rawValue, errorMessage: "\(ErrorCode.unauthorized)"))
        }
    }

    @objc override func skipAuthHeaders(_ completion: CreateAuthHeaders) {
        // do nothing
        completion(self.defaultHeaders, nil)
    }

    @objc override func prepareAuthAndKeyHeaders(_ completion: @escaping PrepareAuthAndKeyHeaders) {
        self.createAuthHeaders { [weak self] (headers, error) in
            if let error = error {
                completion(nil, error)
            } else {
                self?.createKeyIfNeeded { (encryptionKey, keyError) in
                    if let keyError = keyError {
                        completion(nil, keyError)
                    } else {
                        completion(headers! + [RestClient.fpKeyIdKey: encryptionKey!.keyId!], nil)
                    }
                }
            }
        }
    }

    @objc override func preparKeyHeader(_ completion: @escaping PrepareAuthAndKeyHeaders) {
        self.skipAuthHeaders { [weak self] (headers, error) in
            if let error = error {
                completion(nil, error)
            } else {
                self?.createKeyIfNeeded { (encryptionKey, keyError) in
                    if let keyError = keyError {
                        completion(nil, keyError)
                    } else {
                        completion(headers! + [RestClient.fpKeyIdKey: encryptionKey!.keyId!], nil)
                    }
                }
            }
        }
    }



    // MARK: Issuers
    @objc override func issuers(completion: @escaping IssuersHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let strongSelf = self else { return }
            guard let headers = headers  else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let request = strongSelf._manager.request(FitpayConfig.apiURL + "/issuers",
                                                      method: .get,
                                                      parameters: nil,
                                                      encoding: JSONEncoding.default,
                                                      headers: headers)
            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let issuers = try? Issuers(resultValue)
                issuers?.client = self
                completion(issuers, error)
            }
        }
    }

    @objc override func assets(_ url: String, completion: @escaping AssetsHandler) {
        let request = self._manager.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)

        DispatchQueue.global().async {
            request.responseData { (response: DataResponse<Data>) in
                if response.result.error != nil {
                    let error = try? ErrorResponse(response.data)

                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                } else if let resultValue = response.result.value {
                    var asset: Asset?
                    if let image = UIImage(data: resultValue) {
                        asset = Asset(image: image)
                    } else if let string = resultValue.UTF8String {
                        asset = Asset(text: string)
                    } else {
                        asset = Asset(data: resultValue)
                    }

                    DispatchQueue.main.async {
                        completion(asset, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, ErrorResponse.unhandledError(domain: RestClient.self))
                    }
                }
            }
        }
    }

    @objc override func makePostCall(_ url: String, parameters: [String: Any]?, completion: @escaping SyncHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(error) }
                return
            }

            let request = self?._manager.request(url, method: .post, parameters: parameters, encoding: CustomJSONArrayEncoding.default, headers: headers)
            DispatchQueue.global().async {
                request?.response { (response: DefaultDataResponse) in
                    if response.error != nil {
                        DispatchQueue.main.async {
                            if let _ = response.error {
                                let error = try? ErrorResponse(response.data)
                                completion(error)
                            }
                            else {
                                completion(nil)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }

    /**
     Creates a request for resetting a device

     - parameter deviceId:  device id
     - parameter userId: user id
     - parameter completion:      ResetHandler closure
     */
    @objc override func resetDeviceTasks(_ resetUrl: URL, completion: @escaping ResetHandler) {
        self.prepareAuthAndKeyHeaders { [unowned self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async(execute: {
                    completion(nil, error)
                })
                return
            }
            let request = self._manager.request(resetUrl, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            request.validate().responseJSON { (response) in
                DispatchQueue.main.async {
                    if response.result.error != nil {
                        let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                        completion(nil, error)
                    } else if let resultValue = response.result.value {
                        completion(try? ResetDeviceResult(resultValue), nil)
                    } else {
                        completion(nil, NSError.unhandledError(RestClient.self))
                    }
                }
            }
        }
    }

    /**
     Creates a request for getting reset status

     - parameter resetId:  reset device task id
     - parameter completion:   ResetHandler closure
     */
    @objc override func resetDeviceStatus(_ resetUrl: URL, completion: @escaping ResetHandler) {
        self.prepareAuthAndKeyHeaders { [unowned self] (headers, error) in
            if let headers = headers {
                let request = self._manager.request(resetUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                request.validate().responseJSON { (response) in
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            completion(nil, error)
                        } else if let resultValue = response.result.value {
                            completion(try? ResetDeviceResult(resultValue), nil)
                        } else {
                            completion(nil, NSError.unhandledError(RestClient.self))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async(execute: {
                    completion(nil, error)
                })
            }
        }
    }

    @objc override func makeRequest(request: DataRequest?, completion: @escaping RequestHandler) {
        request?.validate().responseJSON(queue: DispatchQueue.global()) { (response) in

            DispatchQueue.main.async {
                if response.result.error != nil {
                    let JSON = response.data!.UTF8String
                    var error = try? ErrorResponse(JSON)
                    if error == nil {
                        error = ErrorResponse(domain: RestClient.self, errorCode: response.response?.statusCode ?? 0 , errorMessage: response.result.error?.localizedDescription)
                    }
                    completion(nil, error)

                } else if let resultValue = response.result.value {
                    completion(resultValue, nil)
                } else {
                    completion(nil, ErrorResponse.unhandledError(domain: RestClient.self))
                }
            }
        }
    }
}

