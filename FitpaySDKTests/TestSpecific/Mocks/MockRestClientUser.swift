@testable import FitpaySDK

extension MockRestClient {

    // MARK: - Completion Handlers

    public typealias UserHandler = (_ user: User?, _ error: ErrorResponse?) -> Void

    //MARK: - Public Functions

    @objc public func createUser(_ email: String, password: String, firstName: String?, lastName: String?,
                                 birthDate: String?, termsVersion: String?, termsAccepted: String?, origin: String?,
                                 originAccountCreated: String?, completion: @escaping UserHandler) {
        log.verbose("request create user: \(email)")

        self.preparKeyHeader { [weak self] (headers, error) in
            guard let strongSelf = self else { return }
            guard let headers = headers else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            log.verbose("got headers: \(headers)")
            var parameters: [String: Any] = [:]
            
            if let termsVersion = termsVersion {
                parameters["termsVersion"] = termsVersion
            }

            if let termsAccepted = termsAccepted {
                parameters["termsAcceptedTsEpoch"] = termsAccepted
            }

            if let origin = origin {
                parameters["origin"] = origin
            }

            if let originAccountCreated = originAccountCreated {
                parameters["originAccountCreatedTsEpoch"] = originAccountCreated
            }

            parameters["client_id"] = FitpayConfig.clientId

            var rawUserInfo: [String: Any] = ["email": email, "pin": password]

            if let firstName = firstName {
                rawUserInfo["firstName"] = firstName
            }

            if let lastName = lastName {
                rawUserInfo["lastName"] = lastName
            }

            if let birthDate = birthDate {
                rawUserInfo["birthDate"] = birthDate
            }
            
            if let userInfoJSON = rawUserInfo.JSONString,
                let jweObject = try? JWEObject.createNewObject(JWEAlgorithm.A256GCMKW,
                                                               enc: JWEEncryption.A256GCM,
                                                               payload: userInfoJSON,
                                                               keyId: headers[RestClient.fpKeyIdKey]!),
                let encrypted = try? jweObject.encrypt(strongSelf.secret) {
                parameters["encryptedData"] = encrypted
            }

            var response = Response()
            let url = FitpayConfig.apiURL + "/users"
            response.data = HTTPURLResponse(url: URL(string: url)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self?.loadDataFromJSONFile(filename: "getUser")
            let request = Request(request: url)
            request.response = response
            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let user = try? User(resultValue)
                user?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                user?.client = self
                completion(user, error)
            }
        }
    }

    @objc open func user(id: String, completion: @escaping UserHandler) {
        makeGetCall(FitpayConfig.apiURL + "/users/" + id, parameters: nil, completion: completion)
    }

    @objc public func updateUser(_ url: String,  firstName: String?, lastName: String?,
                                 birthDate: String?, originAccountCreated: String?, termsAccepted: String?,
                                 termsVersion: String?, completion: @escaping UserHandler) {
        self.prepareAuthAndKeyHeaders { (headers, error) in
            guard let headers = headers else {
                completion(nil, error)
                return
            }

            var operations = [Any]()

            if let firstName = firstName {
                operations.append(["op": "replace", "path": "/firstName", "value": firstName])
            }

            if let lastName = lastName {
                operations.append(["op": "replace", "path": "/lastName", "value": lastName])
            }

            if let birthDate = birthDate {
                operations.append(["op": "replace", "path": "/birthDate", "value": birthDate])
            }

            if let originAccountCreated = originAccountCreated {
                operations.append(["op": "replace", "path": "/originAccountCreatedTs", "value": originAccountCreated])
            }

            if let termsAccepted = termsAccepted {
                operations.append(["op": "replace", "path": "/termsAcceptedTs", "value": termsAccepted])
            }

            if let termsVersion = termsVersion {
                operations.append(["op": "replace", "path": "/termsVersion", "value": termsVersion])
            }

            var parameters = [String: Any]()

            if let updateJSON = operations.JSONString {
                if let jweObject = try? JWEObject.createNewObject(JWEAlgorithm.A256GCMKW, enc: JWEEncryption.A256GCM, payload: updateJSON, keyId: headers[RestClient.fpKeyIdKey]!) {
                    if let encrypted = try? jweObject.encrypt(self.secret)! {
                        parameters["encryptedData"] = encrypted
                    }
                }
            }

            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self.loadDataFromJSONFile(filename: "Error")
            response.error = ErrorResponse.unhandledError(domain: MockRestClient.self)
            let request = Request(request: url)
            request.response = response
            self.makeRequest(request: request) { [weak self] (resultValue, error) in
                guard let strongSelf = self else { return }
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let user = try? User(resultValue)
                user?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                user?.client = self
                completion(user, error)
            }
        }

    }
    
}
