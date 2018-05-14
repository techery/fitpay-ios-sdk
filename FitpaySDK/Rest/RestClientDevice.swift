import Foundation
import Alamofire

extension RestClient {
    
    //MARK: - Completion Handlers
    
    /**
     Completion handler
     
     - parameter result: Provides ResultCollection<DeviceInfo> object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias DevicesHandler = (_ result: ResultCollection<DeviceInfo>?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter device: Provides existing DeviceInfo object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias DeviceHandler = (_ device: DeviceInfo?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter commits: Provides ResultCollection<Commit> object, or nil if error occurs
     - parameter error:   Provides error object, or nil if no error occurs
     */
    public typealias CommitsHandler = (_ result: ResultCollection<Commit>?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter commit:    Provides Commit object, or nil if error occurs
     - parameter error:     Provides error object, or nil if no error occurs
     */
    public typealias CommitHandler = (_ commit: Commit?, _ error: ErrorResponse?) -> Void
    
    //MARK: - Functions
    
    internal func devices(_ url: String, limit: Int, offset: Int, completion: @escaping DevicesHandler) {
        let parameters = ["limit": "\(limit)", "offset": "\(offset)"]
        self.devices(url, parameters: parameters, completion: completion)
    }
    
    internal func devices(_ url: String, parameters: [String: Any]?, completion: @escaping DevicesHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(nil, error) }
                return
            }
            
            let request = self?._manager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            self?.makeRequest(request: request, completion: { (resultValue, error) in
                guard let strongSelf = self else { return }
                
                if let resultValue = resultValue {
                    let deviceInfo = try? ResultCollection<DeviceInfo>(resultValue)
                    deviceInfo?.client = self
                    deviceInfo?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                    completion(deviceInfo, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    internal func createNewDevice(_ url: String, deviceType: String, manufacturerName: String, deviceName: String,
                                  serialNumber: String?, modelNumber: String?, hardwareRevision: String?, firmwareRevision: String?,
                                  softwareRevision: String?, notificationToken: String?, systemId: String?, osName: String?,
                                  secureElementId: String?, casd: String?, completion: @escaping DeviceHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(nil, error) }
                return
            }
            var params: [String: Any] = [
                "deviceType": deviceType,
                "manufacturerName": manufacturerName,
                "deviceName": deviceName,
                "serialNumber": serialNumber ?? NSNull(),
                "modelNumber": modelNumber ?? NSNull(),
                "hardwareRevision": hardwareRevision ?? NSNull(),
                "firmwareRevision": firmwareRevision ?? NSNull(),
                "softwareRevision": softwareRevision ?? NSNull(),
                "notificationToken": notificationToken ?? NSNull(),
                "systemId": systemId ?? NSNull(),
                "osName": osName ?? NSNull()]
            
            if (secureElementId != nil || casd != nil) {
                params["secureElement"] = [
                    "secureElementId": secureElementId ?? NSNull(),
                    "casdCert": casd ?? NSNull()
                    ] as [String: Any]
            }
            
            
            let request = self?._manager.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            self?.makeRequest(request: request, completion: { (resultValue, error) in
                guard let strongSelf = self else { return }
                
                if let resultValue = resultValue {
                    let deviceInfo = try? DeviceInfo(resultValue)
                    deviceInfo?.client = self
                    deviceInfo?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                    completion(deviceInfo, error)                        
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    internal func deleteDevice(_ url: String, completion: @escaping DeleteHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(error) }
                return
            }
            
            let request = self?._manager.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            self?.makeRequest(request: request, completion: { (resultValue, error) in
                completion(error)
            })
        }
    }
    
    internal func updateDevice(_ url: String,
                               firmwareRevision: String?,
                               softwareRevision: String?,
                               notificationToken: String?,
                               completion: @escaping DeviceHandler) {
        var paramsArray = [Any]()
        if let firmwareRevision = firmwareRevision {
            paramsArray.append(["op": "replace", "path": "/firmwareRevision", "value": firmwareRevision])
        }
        
        if let softwareRevision = softwareRevision {
            paramsArray.append(["op": "replace", "path": "/softwareRevision", "value": softwareRevision])
        }
        
        if let notificationToken = notificationToken {
            paramsArray.append(["op": "replace", "path": "/notificationToken", "value": notificationToken])
        }
        
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(nil, error) }
                return
            }
            
            let params = ["params": paramsArray]
            let request = self?._manager.request(url, method: .patch, parameters: params, encoding: CustomJSONArrayEncoding.default, headers: headers)
            self?.makeRequest(request: request, completion: { (resultValue, error) in
                guard let strongSelf = self else { return }
                
                if let resultValue = resultValue {
                    let deviceInfo = try? DeviceInfo(resultValue)
                    deviceInfo?.client = self
                    deviceInfo?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])                        
                    completion(deviceInfo, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    internal func addDeviceProperty(_ url: String, propertyPath: String, propertyValue: String, completion: @escaping DeviceHandler) {
        var paramsArray = [Any]()
        paramsArray.append(["op": "add", "path": propertyPath, "value": propertyValue])
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(nil, error) }
                return
            }
            
            let params = ["params": paramsArray]
            let request = self?._manager.request(url, method: .patch, parameters: params, encoding: CustomJSONArrayEncoding.default, headers: headers)
            self?.makeRequest(request: request, completion: { (resultValue, error) in
                guard let strongSelf = self else { return }
                
                if let resultValue = resultValue {
                    let deviceInfo = try? DeviceInfo(resultValue)
                    deviceInfo?.client = self
                    deviceInfo?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                    completion(deviceInfo, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    open func commits(_ url: String, commitsAfter: String?, limit: Int, offset: Int, completion: @escaping CommitsHandler) {
        var parameters = ["limit": "\(limit)", "offset": "\(offset)"]
        
        if (commitsAfter != nil && commitsAfter!.isEmpty == false) {
            parameters["commitsAfter"] = commitsAfter!
        }
        
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(nil, error) }
                return
            }
            
            let request = self?._manager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            self?.makeRequest(request: request, completion: { (resultValue, error) in
                guard let strongSelf = self else { return }

                if let resultValue = resultValue {
                    let commit = try? ResultCollection<Commit>(resultValue)
                    commit?.client = self
                    commit?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                    completion(commit, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    internal func commits(_ url: String, parameters: [String: Any]?,  completion: @escaping CommitsHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(nil, error) }
                return
            }
            
            let request = self?._manager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            self?.makeRequest(request: request, completion: { (resultValue, error) in
                guard let strongSelf = self else { return }

                if let resultValue = resultValue {
                    let commit = try? ResultCollection<Commit>(resultValue)
                    commit?.client = self
                    commit?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                    completion(commit, error)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    internal func commit(_ url: String, completion: @escaping CommitHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(nil, error) }
                return
            }
            
            let request = self?._manager.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers)
            self?.makeRequest(request: request, completion: { (resultValue, error) in
                guard let strongSelf = self else { return }

                if let resultValue = resultValue {
                    let commit = try? Commit(resultValue)
                    commit?.client = self
                    commit?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                    completion(commit, error)

                } else {
                    completion(nil, error)
                }
            })
        }
    }
}
