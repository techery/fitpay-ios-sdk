@testable import FitpaySDK

extension MockRestClient {

    //MARK - Completion Handlers

    public typealias CreditCardsHandler = (_ result: ResultCollection<CreditCard>?, _ error: ErrorResponse?) -> Void

    public typealias CreditCardHandler = (_ creditCard: CreditCard?, _ error: ErrorResponse?) -> Void

    public typealias CreditCardTransitionHandler = (_ pending: Bool, _ card: CreditCard?, _ error: ErrorResponse?) -> Void

    public typealias VerifyHandler = (_ pending: Bool, _ verificationMethod: VerificationMethod?, _ error: ErrorResponse?) -> Void

    public typealias VerifyMethodHandler = (_ verificationMethod: VerificationMethod?, _ error: ErrorResponse?) -> Void

    public typealias VerifyMethodsHandler = (_ verificationMethods: ResultCollection<VerificationMethod>?, _ error: ErrorResponse?) -> Void

    //MARK - Internal Functions

    func createCreditCard(_ url: String, cardInfo: CardInfo, deviceId: String?, completion: @escaping RestClientInterface.CreditCardHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self?.loadDataFromJSONFile(filename: "createCreditCard")
            let request = Request(request: url)
            request.response = response

            self?.makeRequest(request: request) { (resultValue, error) in
                guard let strongSelf = self else { return }
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let card = try? CreditCard(resultValue)
                card?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                card?.client = self
                completion(card, error)
            }
        }
    }

    func creditCards(_ url: String, excludeState: [String], limit: Int, offset: Int, deviceId: String?, completion: @escaping CreditCardsHandler) {
        var parameters: [String: Any] = ["excludeState": excludeState.joined(separator: ","), "limit": limit, "offset": offset]
        if let deviceId = deviceId {
            parameters["deviceId"] = deviceId
        }
        makeGetCall(url, parameters: parameters, completion: completion)
    }

    func updateCreditCard(_ url: String, name: String?, address: Address, completion: @escaping RestClientInterface.CreditCardHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers  else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self?.loadDataFromJSONFile(filename: "updateCreditCard")
            let request = Request(request: url)
            request.response = response

            self?.makeRequest(request: request) { (resultValue, error) in
                guard let strongSelf = self else { return }
                guard let resultValue = resultValue else {
                    completion(nil, error)
                    return
                }
                let card = try? CreditCard(resultValue)
                card?.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                card?.client = self
                completion(card, error)
            }
        }
    }

    func acceptCall(_ url: String, completion: @escaping RestClientInterface.CreditCardTransitionHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(false, nil, error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            if url.contains("accept") {
                response.json = self?.loadDataFromJSONFile(filename: "acceptTermsForCreditCard")
            } else {
                response.json = self?.loadDataFromJSONFile(filename: "declineTerms")
            }
            let request = Request(request: url)
            request.response = response
            
            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    self?.handleTransitionResponse(error, completion: completion)
                    return
                }
                let card = try? CreditCard(resultValue)
                card?.client = self
                completion(false, card, nil)
            }
        }
    }

    func selectVerificationType(_ url: String, completion: @escaping VerifyHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers  else {
                DispatchQueue.main.async { completion(false, nil, error) }
                return
            }

            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self?.loadDataFromJSONFile(filename: "selectVerificationType")
            let request = Request(request: url)
            request.response = response

            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    self?.handleVerifyResponse(error, completion: completion)
                    return
                }
                let verificationMethod = try? VerificationMethod(resultValue)
                verificationMethod?.client = self
                completion(false, verificationMethod, error)
            }
        }
    }

    func verify(_ url: String, verificationCode: String, completion: @escaping VerifyHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(false, nil, error) }
                return
            }

            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self?.loadDataFromJSONFile(filename: "verified")
            let request = Request(request: url)
            request.response = response

            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    self?.handleVerifyResponse(error, completion: completion)
                    return
                }
                let verificationMethod = try? VerificationMethod(resultValue)
                verificationMethod?.client = self
                completion(false, verificationMethod, error)
            }
        }
    }

    func activationCall(_ url: String, causedBy: CreditCardInitiator, reason: String, completion: @escaping RestClientInterface.CreditCardTransitionHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(false, nil, error) }
                return
            }
            
            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            if url.contains("de") {
                response.json = self?.loadDataFromJSONFile(filename: "deactivateCreditCard")
            } else {
                response.json = self?.loadDataFromJSONFile(filename: "reactivateCreditCard")
            }
            
            let request = Request(request: url)
            request.response = response
            
            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    self?.handleTransitionResponse(error, completion: completion)
                    return
                }
                let card = try? CreditCard(resultValue)
                card?.client = self
                completion(false, card, error)
            }
        }
    }
    
    func makeDefault(_ url: String, completion: @escaping CreditCardTransitionHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let headers = headers else {
                DispatchQueue.main.async { completion(false, nil, error) }
                return
            }

            var response = Response()
            response.data = HTTPURLResponse(url: URL(string: url)! , statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)
            response.json = self?.loadDataFromJSONFile(filename: "makeCreditCardDefault")
            let request = Request(request: url)
            request.response = response

            self?.makeRequest(request: request) { (resultValue, error) in
                guard let resultValue = resultValue else {
                    self?.handleTransitionResponse(error, completion: completion)
                    return
                }
                let card = try? CreditCard(resultValue)
                card?.client = self
                completion(false, card, error)
            }
        }
    }

    // MARK: - Private Functions
    
    func handleVerifyResponse(_ response: ErrorResponse?, completion: @escaping VerifyHandler) {
        guard let statusCode = response?.status else {
            completion(false, nil, ErrorResponse.unhandledError(domain: RestClient.self))
            return
        }

        switch statusCode {
        case 202:
            completion(true, nil, nil)
        default:
            completion(false, nil, response)
        }
    }

    func handleTransitionResponse(_ response: ErrorResponse?, completion: @escaping CreditCardTransitionHandler) {
        guard let statusCode = response?.status else {
            completion(false, nil, ErrorResponse.unhandledError(domain: RestClient.self))
            return
        }

        switch statusCode {
        case 202:
            completion(true, nil, nil)
        default:
            completion(false, nil, response)
        }

    }
}
