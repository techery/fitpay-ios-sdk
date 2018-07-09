@testable import FitpaySDK

extension MockRestClient {

    //MARK: - Completion Handlers

    public typealias DevicesHandler = (_ result: ResultCollection<DeviceInfo>?, _ error: ErrorResponse?) -> Void

    public typealias DeviceHandler = (_ device: DeviceInfo?, _ error: ErrorResponse?) -> Void

    public typealias CommitsHandler = (_ result: ResultCollection<Commit>?, _ error: ErrorResponse?) -> Void

    public typealias CommitHandler = (_ commit: Commit?, _ error: ErrorResponse?) -> Void

    //MARK: - Functions

    func createNewDevice(_ url: String, deviceInfo: DeviceInfo, completion: @escaping RestClientInterface.DeviceHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(nil, error) }
                return
            }
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self?.loadDataFromJSONFile(filename: "createDevice")
            let request = Request(request: url)
            request.response = response

            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let deviceInfo = try? DeviceInfo(resultValue)
                deviceInfo?.client = self
                completion(deviceInfo, error)
            }
        }
    }

    func updateDevice(_ url: String, firmwareRevision: String?, softwareRevision: String?,
                      notificationToken: String?, completion: @escaping DeviceHandler) {
        
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(nil, error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self?.loadDataFromJSONFile(filename: "updateDevice")
            let request = Request(request: url)
            request.response = response
            
            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let deviceInfo = try? DeviceInfo(resultValue)
                deviceInfo?.client = self
                completion(deviceInfo, error)
            }
        }
    }

    func addDeviceProperty(_ url: String, propertyPath: String, propertyValue: String, completion: @escaping DeviceHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async {  completion(nil, error) }
                return
            }

            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self?.loadDataFromJSONFile(filename: "createDevice")
            let request = Request(request: url)
            request.response = response

            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let deviceInfo = try? DeviceInfo(resultValue)
                deviceInfo?.client = self
                completion(deviceInfo, error)
            }
        }
    }

    open func commits(_ url: String, commitsAfter: String?, limit: Int, offset: Int, completion: @escaping CommitsHandler) {
        var parameters = ["limit": "\(limit)", "offset": "\(offset)"]

        if (commitsAfter != nil && commitsAfter!.isEmpty == false) {
            parameters["commitsAfter"] = commitsAfter!
        }

        makeGetCall(url, parameters: parameters, completion: completion)
    }

}
