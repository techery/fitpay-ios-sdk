@testable import FitpaySDK
import XCTest

class MockRestClient: NSObject, RestClientInterface {

    public enum ErrorCode: Int, Error, RawIntValue {
        case ok            = 200
        case badRequest    = 400
        case unauthorized  = 401
        case requestFailed = 402
        case notFound      = 404
        case serverError0  = 500
        case serverError1  = 502
        case serverError2  = 503
        case serverError3  = 504
    }
    
    static let fpKeyIdKey: String = "fp-key-id"
    
    private let defaultHeaders = [
        "Accept": "application/json",
        "X-FitPay-SDK": "iOS-\(FitpayConfig.sdkVersion)"
    ]
    
    var _session: MockRestSession
    var keyPair: MockSECP256R1KeyPair = MockSECP256R1KeyPair()
    
    var key: EncryptionKey?
    
    var secret: Data {
        let secret = self.keyPair.generateSecretForPublicKey(key?.serverPublicKey ?? "")
        
        if secret == nil || secret?.count == 0 {
            log.warning("Encription secret is empty.")
        }
        return secret ?? Data()
    }
    
    public init(session: MockRestSession) {
        _session = session;
    }
    
    func collectionItems<T>(_ url: String, completion: @escaping ResultCollectionHandler<T>) -> T? {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self?.loadDataFromJSONFile(filename: "")
            let request = Request(request: url)
            request.response = response
            
            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                guard let strongSelf = self else { return }
                let result = try? ResultCollection<T>(resultValue)
                result?.client = self
                result?.applySecret(strongSelf.secret, expectedKeyId: headers[MockRestClient.fpKeyIdKey])
                completion(result, nil)
            }
        }
        
        return nil
    }
    
    public func confirm(_ url: String, executionResult: NonAPDUCommitState, completion: @escaping ConfirmHandler) {
        self.prepareAuthAndKeyHeaders { (headers, error) in
            guard let headers = headers  else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self.loadDataFromJSONFile(filename: "") //needed
            let request = Request(request: url)
            request.response = response
            
            self.makeRequest(request: request) { (resultValue, error) in
                completion(error)
            }
        }
    }
    
    func getPlatformConfig(completion: @escaping (PlatformConfig?, ErrorResponse?) -> Void) {
        let platformConfig = PlatformConfig(isUserEventStreamsEnabled: true)
        completion(platformConfig, nil)
    }
    
    func makeDeleteCall(_ url: String, completion: @escaping RestClientInterface.DeleteHandler) {
        prepareAuthAndKeyHeaders { (headers, error) in
            guard let headers = headers else {
                completion(error)
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self.loadDataFromJSONFile(filename: "")
            
            let request = Request(request: url)
            request.response = response
            
            self.makeRequest(request: request) { (resultValue, error) in
                completion(error)
            }
        }
    }
    
    func makeGetCall<T>(_ url: String, limit: Int, offset: Int, completion: @escaping (ResultCollection<T>?, ErrorResponse?) -> Void) where T: Decodable, T: Encodable {
        let parameters = ["limit": "\(limit)", "offset": "\(offset)"]
        makeGetCall(url, parameters: parameters, completion: completion)
    }

    func makeGetCall<T>(_ url: String, parameters: [String : Any]?, completion: @escaping (ResultCollection<T>?, ErrorResponse?) -> Void) where T: Codable {
        prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            
            if url.contains("commits") {
                response.json = self?.loadDataFromJSONFile(filename: "getCommit")
            } else if url.contains("transactions") {
                response.json = self?.loadDataFromJSONFile(filename: "listTransactions")
            } else if url.contains("creditCards") {
                response.json = self?.loadDataFromJSONFile(filename: "listCreditCards")
            } else if url.contains("devices") {
                response.json = self?.loadDataFromJSONFile(filename: "listDevices")
            }
            
            let request = Request(request: url)
            request.response = response
            
            self?.makeRequest(request: request) { (resultValue, error) in
                guard let strongSelf = self else { return }
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let commit = try? ResultCollection<T>(resultValue)
                commit?.client = self
                commit?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                completion(commit, error)
            }
        }
        
    }
    
    func makeGetCall<T>(_ url: String, parameters: [String : Any]?, completion: @escaping (T?, ErrorResponse?) -> Void) where T: Serializable {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            
            if url.contains("resetDeviceTasks") {
                response.json = self?.loadDataFromJSONFile(filename: "resetDeviceTask")
            }
            
            let request = Request(request: url)
            request.response = response
            
            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let result = try? T(resultValue)
                completion(result, error)
            }
        }
    }
    
    func makeGetCall<T>(_ url: String, parameters: [String : Any]?, completion: @escaping (T?, ErrorResponse?) -> Void) where T: ClientModel, T: Serializable {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            
            if url.contains("user") {
                response.json = self?.loadDataFromJSONFile(filename: "getUser")
            } else if url.contains("issuers") {
                response.json = self?.loadDataFromJSONFile(filename: "issuers")
            }
            
            let request = Request(request: url)
            request.response = response
            
            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                var result = try? T(resultValue)
                result?.client = self
                completion(result, error)
            }
        }
    }
    
    func makeGetCall<T>(_ url: String, parameters: [String: Any]?, completion: @escaping (T?, ErrorResponse?) -> Void) where T: Serializable, T: ClientModel, T: SecretApplyable {
        prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            
            if url.contains("creditCards") {
                response.json = self?.loadDataFromJSONFile(filename: "retrieveCreditCard")
            } else if url.contains("user") {
                response.json = self?.loadDataFromJSONFile(filename: "getUser")
            }
            
            let request = Request(request: url)
            request.response = response
            
            self?.makeRequest(request: request) { (resultValue, error) in
                guard let strongSelf = self else { return }
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                var result = try? T(resultValue)
                result?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                result?.client = self
                completion(result, error)
            }
        }
    }
    
    func makeRequest(request: Request?, completion: @escaping RequestHandler) {
        request?.responseJSON() { (request) in
            
            DispatchQueue.main.async {
                if request.response?.error != nil {
                    let JSON = request.response?.json
                    var error = try? ErrorResponse(JSON)
                    if error == nil {
                        error = ErrorResponse(domain: MockRestClient.self, errorCode: request.response.data?.statusCode ?? 0 , errorMessage: request.response.error?.localizedDescription)
                    }
                    completion(nil, error)
                    
                } else if let resultValue = request.response?.json {
                    completion(resultValue, nil)
                } else {
                    completion(nil, ErrorResponse.unhandledError(domain: MockRestClient.self))
                }
            }
        }
    }
    
    
}

// MARK: - Confirm package

extension MockRestClient {

    public func confirmAPDUPackage(_ url: String, package: ApduPackage, completion: @escaping ConfirmHandler) {
        guard package.packageId != nil else {
            completion(ErrorResponse(domain: MockRestClient.self, errorCode: ErrorCode.badRequest.rawValue, errorMessage: "packageId should not be nil"))
            return
        }
        
        self.prepareAuthAndKeyHeaders { (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self.loadDataFromJSONFile(filename: "confirmJson")
            let request = Request(request: url)
            request.response = response
            
            self.makeRequest(request: request) { (resultValue, error) in
                completion(error)
            }
        }
    }
    
}

// MARK: - Encryption

extension MockRestClient {

    func createEncryptionKey(clientPublicKey: String, completion: @escaping EncryptionKeyHandler) {
        let headers = self.defaultHeaders
        var response = Response()
        let url = FitpayConfig.apiURL + "/config/encryptionKeys"
        response.data = HTTPURLResponse(url: URL(string: url)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
        response.json = self.loadDataFromJSONFile(filename: "getEncryptionKeyJson")
        let request = Request(request: url)
        request.response = response
        self.makeRequest(request: request) { (resultValue, error) in
            guard let resultValue = resultValue else {
                completion(nil, error)
                return
            }
            completion(try? EncryptionKey(resultValue), error)
        }
    }
    
    func encryptionKey(_ keyId: String, completion: @escaping EncryptionKeyHandler) {
        let headers = self.defaultHeaders
        var response = Response()
        let url = FitpayConfig.apiURL + "/config/encryptionKeys/" + keyId
        response.data = HTTPURLResponse(url: URL(string: url)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
        response.json = self.loadDataFromJSONFile(filename: "getEncryptionKeyJson")
        let request = Request(request: url)
        request.response = response
        if keyId == "some_fake_id" {
            response.json = self.loadDataFromJSONFile(filename: "Error")
            request.response.error = ErrorResponse.unhandledError(domain: MockRestClient.self)
        }
        
        self.makeRequest(request: request) { (resultValue, error) in
            guard let resultValue = resultValue else {
                completion(nil, error)
                return
            }
            completion(try? EncryptionKey(resultValue), error)
        }
    }

    func deleteEncryptionKey(_ keyId: String, completion: @escaping DeleteHandler) {
        let headers = self.defaultHeaders
        var response = Response()
        let url = FitpayConfig.apiURL + "/config/encryptionKeys/" + keyId
        response.data = HTTPURLResponse(url: URL(string: url)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
        response.json = self.loadDataFromJSONFile(filename: "")
        let request = Request(request: url)
        request.response = response
        
        self.makeRequest(request: request) { (resultValue, error) in
            completion(error)
        }
    }
    
    func createKeyIfNeeded(_ completion: @escaping EncryptionKeyHandler) {
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
    
}

// MARK: - Request Signature Helpers

extension MockRestClient {
    
    func createAuthHeaders(_ completion: AuthHeaderHandler) {
        if self._session.isAuthorized {
            completion(self.defaultHeaders + ["Authorization": "Bearer " + self._session.accessToken!], nil)
        } else {
            completion(nil, ErrorResponse(domain: MockRestClient.self, errorCode: ErrorCode.unauthorized.rawValue, errorMessage: "\(ErrorCode.unauthorized)"))
        }
    }
    
    func prepareAuthAndKeyHeaders(_ completion: @escaping AuthHeaderHandler) {
        self.createAuthHeaders { [weak self] (headers, error) in
            if let error = error {
                completion(nil, error)
            } else {
                self?.createKeyIfNeeded { (encryptionKey, keyError) in
                    if let keyError = keyError {
                        completion(nil, keyError)
                    } else {
                        completion(headers! + [MockRestClient.fpKeyIdKey: encryptionKey!.keyId!], nil)
                    }
                }
            }
        }
    }
    
    func preparKeyHeader(_ completion: @escaping AuthHeaderHandler) {
        createKeyIfNeeded { (encryptionKey, keyError) in
            if let keyError = keyError {
                completion(nil, keyError)
            } else {
                completion(self.defaultHeaders + [MockRestClient.fpKeyIdKey: encryptionKey!.keyId!], nil)
            }
        }
        
    }
    
}

// MARK: - Issuers

extension MockRestClient {
    
    public func issuers(completion: @escaping IssuersHandler) {
        makeGetCall(FitpayConfig.apiURL + "/issuers", parameters: nil, completion: completion)
    }
    
}

// MARK: - Assets

extension MockRestClient {
    
    func assets(_ url: String, completion: @escaping AssetsHandler) {
        let asset = Asset(image: UIImage())
        completion(asset, nil)
    }
    
}

// MARK: - Sync Statistics

extension MockRestClient {
    
    func makePostCall(_ url: String, parameters: [String: Any]?, completion: @escaping ConfirmHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            
            response.json = self?.loadDataFromJSONFile(filename: "")
            
            let request = Request(request: url)
            request.response = response
            
            self?.makeRequest(request: request) { (resultValue, error) in
                completion(error)
            }
        }
    }
    
}

// MARK: - Reset Device Tasks

extension MockRestClient {

    typealias ResetHandler = (_ resetDeviceTask: ResetDeviceResult?, _ error: ErrorResponse?) -> Void
    
    func resetDeviceTasks(_ url: String, completion: @escaping ResetHandler) {
        makeGetCall(url, parameters: nil, completion: completion)
    }

    func resetDeviceStatus(_ url: String, completion: @escaping ResetHandler) {
        makeGetCall(url, parameters: nil, completion: completion)
    }
    
}

// MARK: - Test Functions

extension MockRestClient {

    func loadDataFromJSONFile(filename: String) -> String? {
        let bundle = Bundle(for: type(of: self))
        guard let filepath = bundle.path(forResource: filename, ofType: "json") else {
            XCTAssert(false, "File not found")
            return nil
        }
        
        do {
            let contents = try String(contentsOfFile: filepath)
            XCTAssertNotNil(contents)
            return contents
        } catch {
            XCTAssert(false, "Can't read from file")
        }
        
        return nil
    }

}
