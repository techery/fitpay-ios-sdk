import Foundation
import Alamofire

extension RestClient {
    
    // MARK: - Completion Handlers
    
    /**
     Completion handler
     
     - parameter ResultCollection<User>?: Provides ResultCollection<User> object, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias ListUsersHandler = (ResultCollection<User>?, Error?) -> Void
    
    /**
     Completion handler
     
     - parameter user: Provides User object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias UserHandler = (_ user: User?, _ error: ErrorResponse?) -> Void
    
    //MARK: - Public Functions
    
    /**
     Creates a new user within your organization
     
     - parameter firstName:  first name of the user
     - parameter lastName:   last name of the user
     - parameter birthDate:  birth date of the user in date format [YYYY-MM-DD]
     - parameter email:      email of the user
     - parameter completion: CreateUserHandler closure
     */
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
            if (termsVersion != nil) {
                parameters += ["termsVersion": termsVersion!]
            }
            
            if (termsAccepted != nil) {
                parameters += ["termsAcceptedTsEpoch": termsAccepted!]
            }
            
            if (origin != nil) {
                parameters += ["origin": origin!]
            }
            
            if (termsVersion != nil) {
                parameters += ["originAccountCreatedTsEpoch": originAccountCreated!]
            }
            
            parameters["client_id"] = FitpayConfig.clientId
            
            var rawUserInfo: [String: Any] = ["email": email, "pin": password ]
            
            if (firstName != nil) {
                rawUserInfo += ["firstName": firstName!]
            }
            
            if (lastName != nil) {
                rawUserInfo += ["lastName": lastName!]
            }
            
            if (birthDate != nil) {
                rawUserInfo += ["birthDate": birthDate!]
            }
            
            if let userInfoJSON = rawUserInfo.JSONString {
                if let jweObject = try? JWEObject.createNewObject(JWEAlgorithm.A256GCMKW,
                                                                  enc: JWEEncryption.A256GCM,
                                                                  payload: userInfoJSON,
                                                                  keyId: headers[RestClient.fpKeyIdKey]!) {
                    if let encrypted = try? jweObject.encrypt(strongSelf.secret) {
                        parameters["encryptedData"] = encrypted
                    }
                }
            }
            
            log.verbose("user creation url: \(FitpayConfig.apiURL)/users")
            log.verbose("Headers: \(headers)")
            log.verbose("user creation json: \(parameters)")
            
            let request = strongSelf._manager.request(FitpayConfig.apiURL + "/users", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            
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
    
    /**
     Retrieves the details of an existing user. You need only supply the unique user identifier that was returned upon user creation
     
     - parameter id:         user id
     - parameter completion: UserHandler closure
     */
    @objc open func user(id: String, completion: @escaping UserHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let strongSelf = self else { return }
            
            guard let headers = headers  else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            let request = strongSelf._manager.request(FitpayConfig.apiURL + "/users/" + id,
                                                      method: .get,
                                                      parameters: nil,
                                                      encoding: JSONEncoding.default,
                                                      headers: headers)
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
    
    /**
     Update the details of an existing user
     
     - parameter id:                   user id
     - parameter firstName:            first name or nil if no change is required
     - parameter lastName:             last name or nil if no change is required
     - parameter birthDate:            birth date in date format [YYYY-MM-DD] or nil if no change is required
     - parameter originAccountCreated: origin account created in date format [TODO: specify date format] or nil if no change is required
     - parameter termsAccepted:        terms accepted in date format [TODO: specify date format] or nil if no change is required
     - parameter termsVersion:         terms version formatted as [0.0.0]
     - parameter completion:           UpdateUserHandler closure
     */
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
            
            let request = self._manager.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
    
    /**
     Delete a single user from your organization
     
     - parameter id:         user id
     - parameter completion: DeleteHandler closure
     */
    @objc public func deleteUser(_ url: String, completion: @escaping DeleteHandler) {
        self.prepareAuthAndKeyHeaders { (headers, error) in
            guard let headers = headers else {
                completion(error)
                return
            }
            
            let request = self._manager.request(url, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: headers)
            self.makeRequest(request: request) { (resultValue, error) in
                completion(error)
            }
        }
    }
    
    // MARK: - Internal Functions
    
    @objc public func user(_ url: String, completion: @escaping UserHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let request = self?._manager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            self?.makeRequest(request: request) { (resultValue, error) in
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
