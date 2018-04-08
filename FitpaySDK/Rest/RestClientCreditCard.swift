//
//  RestClientCreditCard.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 22.05.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

extension RestClient {
    
    /**
     Completion handler
     
     - parameter result: Provides collection of credit cards, or nil if error occurs
     - parameter error:  Provides error object, or nil if no error occurs
     */
    public typealias CreditCardsHandler = (_ result: ResultCollection<CreditCard>?, _ error: NSError?) -> Void
    
    /**
     Completion handler
     
     - parameter creditCard: Provides credit card object, or nil if error occurs
     - parameter error:  Provides error object, or nil if no error occurs
     */
    public typealias CreditCardHandler = (_ creditCard: CreditCard?, _ error: NSError?) -> Void
    
    /**
     Completion handler
     
     - parameter pending: Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter card?:   Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error?:  Provides error object, or nil if no error occurs
     */
    public typealias AcceptTermsHandler = (_ pending: Bool, _ card: CreditCard?, _ error: NSError?) -> Void
    
    /**
     Completion handler
     
     - parameter pending: Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter card:    Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:   Provides error object, or nil if no error occurs
     */
    public typealias DeclineTermsHandler = (_ pending: Bool, _ card: CreditCard?, _ error: NSError?) -> Void
    
    /**
     Completion handler
     
     - parameter pending:     Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter creditCard:  Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:       Provides error object, or nil if no error occurs
     */
    public typealias MakeDefaultHandler = (_ pending: Bool, _ creditCard: CreditCard?, _ error: NSError?) -> Void
    
    /**
     Completion handler
     
     - parameter pending:    Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter creditCard: Provides deactivated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:      Provides error object, or nil if no error occurs
     */
    public typealias DeactivateHandler = (_ pending: Bool, _ creditCard: CreditCard?, _ error: NSError?) -> Void
    
    /**
     Completion handler
     
     - parameter Bool:        Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter CreditCard?: Provides reactivated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter ErrorType?:  Provides error object, or nil if no error occurs
     */
    public typealias ReactivateHandler = (_ pending: Bool, _ creditCard: CreditCard?, _ error: NSError?) -> Void
    
    /**
     Completion handler
     - parameter pending:             Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter verificationMethod:  Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:               Provides error object, or nil if no error occurs
     */
    public typealias SelectVerificationTypeHandler = (_ pending: Bool, _ verificationMethod: VerificationMethod?, _ error: NSError?) -> Void
    
    /**
     Completion handler
     
     - parameter pending:            Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter verificationMethod: Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:              Provides error object, or nil if no error occurs
     */
    public typealias VerifyHandler = (_ pending: Bool, _ verificationMethod: VerificationMethod?, _ error: NSError?) -> Void
    
    
    internal func createCreditCard(_ url: String, pan: String, expMonth: Int, expYear: Int, cvv: String, name: String,
                                   street1: String, street2: String, street3: String, city: String, state: String, postalCode: String, country: String,
                                   completion: @escaping CreditCardHandler)
    {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let strongSelf = self else { return }
            
            if let headers = headers {
                var parameters: [String: String] = [:]
                
                let rawCard = [
                    "pan": pan as AnyObject,
                    "expMonth": expMonth as AnyObject,
                    "expYear": expYear as AnyObject,
                    "cvv": cvv as AnyObject,
                    "name": name as AnyObject,
                    "address": [
                        "street1": street1,
                        "street2": street2,
                        "street3": street3,
                        "city": city,
                        "state": state,
                        "postalCode": postalCode,
                        "country": country
                    ]
                    ] as [String: Any]
                
                if let cardJSON = rawCard.JSONString {
                    if let jweObject = try? JWEObject.createNewObject(JWEAlgorithm.A256GCMKW, enc: JWEEncryption.A256GCM, payload: cardJSON, keyId: headers[RestClient.fpKeyIdKey]!) {
                        if let encrypted = try? jweObject.encrypt(strongSelf.secret) {
                            parameters["encryptedData"] = encrypted
                        }
                    }
                }
                
                let request = strongSelf._manager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                
                request.validate().responseObject(queue: DispatchQueue.global()) { [weak self] (response: DataResponse<CreditCard>) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            
                            completion(nil, error)
                        } else if let resultValue = response.result.value {
                            resultValue.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                            resultValue.client = self
                            completion(resultValue, nil)
                        } else {
                            completion(nil, NSError.unhandledError(RestClient.self))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    internal func creditCards(_ url: String, excludeState: [String], limit: Int, offset: Int, completion: @escaping CreditCardsHandler)
    {
        let parameters: [String: AnyObject] = ["excludeState": excludeState.joined(separator: ",") as AnyObject, "limit": limit as AnyObject, "offest": offset as AnyObject]
        self.creditCards(url, parameters: parameters, completion: completion)
    }
    
    internal func creditCards(_ url: String, parameters: [String: AnyObject]?, completion: @escaping CreditCardsHandler)
    {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let strongSelf = self else { return }
            
            if let headers = headers {
                let request = strongSelf._manager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
                
                request.validate().responseObject(queue: DispatchQueue.global()) { [weak self] (response: DataResponse<ResultCollection<CreditCard>>) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            
                            completion(nil, error)
                        } else if let resultValue = response.result.value {
                            resultValue.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                            
                            resultValue.client = self
                            
                            completion(resultValue, nil)
                        } else {
                            completion(nil, NSError.unhandledError(RestClient.self))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    internal func deleteCreditCard(_ url: String, completion: @escaping DeleteHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let strongSelf = self else { return }
            
            if let headers = headers {
                let request = strongSelf._manager.request(url, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: headers)
                request.validate().responseData(queue: DispatchQueue.global()) { (response: DataResponse<Data>) in
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            completion(error)
                        } else if let _ = response.result.value {
                            completion(nil)
                        } else {
                            completion(NSError.unhandledError(RestClient.self))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    internal func updateCreditCard(_ url: String, name: String?, street1: String?, street2: String?, city: String?, state: String?, postalCode: String?, countryCode: String?, completion: @escaping CreditCardHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            guard let strongSelf = self else { return }
            
            if let headers = headers {
                var operations: [[String: String]] = []
                
                var parameters: [String: Any] = [:]
                
                if let name = name {
                    operations.append([
                        "op": "replace", "path": "/name", "value": name
                        ])
                }
                
                if let street1 = street1 {
                    operations.append([
                        "op": "replace", "path": "/address/street1", "value": street1
                        ])
                }
                
                if let street2 = street2 {
                    operations.append([
                        "op": "replace", "path": "/address/street2", "value": street2
                        ])
                }
                
                if let city = city {
                    operations.append([
                        "op": "replace", "path": "/address/city", "value": city
                        ])
                }
                
                if let state = state {
                    operations.append([
                        "op": "replace", "path": "/address/state", "value": state
                        ])
                }
                
                if let postalCode = postalCode {
                    operations.append([
                        "op": "replace", "path": "/address/postalCode", "value": postalCode
                        ])
                }
                
                if let countryCode = countryCode {
                    operations.append([
                        "op": "replace", "path": "/address/countryCode", "value": countryCode
                        ])
                }
                
                if let updateJSON = operations.JSONString {
                    if let jweObject = try? JWEObject.createNewObject(JWEAlgorithm.A256GCMKW, enc: JWEEncryption.A256GCM, payload: updateJSON, keyId: headers[RestClient.fpKeyIdKey]!) {
                        if let encrypted = try? jweObject.encrypt(strongSelf.secret)! {
                            parameters["encryptedData"] = encrypted
                        }
                    }
                }
                
                let request = strongSelf._manager.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                
                request.validate().responseObject(queue: DispatchQueue.global()) { [weak self] (response: DataResponse<CreditCard>) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            
                            completion(nil, error)
                        } else if let resultValue = response.result.value {
                            resultValue.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                            resultValue.client = self
                            completion(resultValue, nil)
                        } else {
                            completion(nil, NSError.unhandledError(RestClient.self))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    internal func acceptTerms(_ url: String, completion: @escaping AcceptTermsHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            if let headers = headers {
                let request = self?._manager.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                request?.validate().responseObject(queue: DispatchQueue.global()) { [weak self] (response: DataResponse<CreditCard>) in
                    
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            
                            completion(false, nil, error)
                        } else if let value = response.result.value {
                            value.client = self
                            completion(false, value, nil)
                        } else if (response.response != nil && response.response!.statusCode == 202) {
                            completion(true, nil, nil)
                        } else {
                            completion(false, nil, NSError.unhandledError(RestClient.self))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
        }
    }
    
    internal func declineTerms(_ url: String, completion: @escaping DeclineTermsHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            if let headers = headers {
                let request = self?._manager.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                request?.validate().responseObject(queue: DispatchQueue.global()) { (response: DataResponse<CreditCard>) in
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            completion(false, nil, error)
                        } else if let value = response.result.value {
                            value.client = self
                            completion(false, value, nil)
                        } else if (response.response != nil && response.response!.statusCode == 202) {
                            completion(true, nil, nil)
                        } else {
                            completion(false, nil, NSError.unhandledError(RestClient.self))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
        }
    }
    
    internal func selectVerificationType(_ url: String, completion: @escaping SelectVerificationTypeHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            if let headers = headers {
                let request = self?._manager.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                request?.validate().responseObject(queue: DispatchQueue.global()) { [weak self] (response: DataResponse<VerificationMethod>) in
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            
                            completion(false, nil, error)
                        } else if let resultValue = response.result.value {
                            resultValue.client = self
                            completion(false, resultValue, nil)
                        } else {
                            if let statusCode = response.response?.statusCode {
                                switch statusCode {
                                case 202:
                                    completion(true, nil, nil)
                                default:
                                    completion(false, nil, NSError.unhandledError(RestClient.self))
                                }
                            } else {
                                completion(false, nil, NSError.unhandledError(RestClient.self))
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
        }
    }
    
    internal func verify(_ url: String, verificationCode: String, completion: @escaping VerifyHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            if let headers = headers {
                let params = ["verificationCode": verificationCode]
                
                let request = self?._manager.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                request?.validate().responseObject(queue: DispatchQueue.global()) { [weak self] (response: DataResponse<VerificationMethod>) in
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            completion(false, nil, error)
                        } else if let resultValue = response.result.value {
                            resultValue.client = self
                            completion(false, resultValue, nil)
                        } else {
                            if let statusCode = response.response?.statusCode {
                                switch statusCode
                                {
                                case 202:
                                    completion(true, nil, nil)
                                    
                                default:
                                    completion(false, nil, NSError.unhandledError(RestClient.self))
                                }
                            } else
                            {
                                completion(false, nil, NSError.unhandledError(RestClient.self))
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
        }
    }
    
    internal func deactivate(_ url: String, causedBy: CreditCardInitiator, reason: String, completion: @escaping DeactivateHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            if let headers = headers {
                let parameters = ["causedBy": causedBy.rawValue, "reason": reason]
                let request = self?._manager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                request?.validate().responseObject(queue: DispatchQueue.global()) { [weak self](response: DataResponse<CreditCard>) in
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            
                            completion(false, nil, error)
                        } else if let resultValue = response.result.value {
                            resultValue.client = self
                            completion(false, resultValue, nil)
                        } else {
                            if let statusCode = response.response?.statusCode {
                                switch statusCode {
                                case 202:
                                    completion(true, nil, nil)
                                    
                                default:
                                    completion(false, nil, NSError.unhandledError(RestClient.self))
                                }
                            } else {
                                completion(false, nil, NSError.unhandledError(RestClient.self))
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
        }
    }
    
    internal func reactivate(_ url: String, causedBy: CreditCardInitiator, reason: String, completion: @escaping ReactivateHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            if let headers = headers {
                let parameters = ["causedBy": causedBy.rawValue, "reason": reason]
                let request = self?._manager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                request?.validate().responseObject(queue: DispatchQueue.global()) { [weak self] (response: DataResponse<CreditCard>) in
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            
                            completion(false, nil, error)
                        } else if let resultValue = response.result.value {
                            resultValue.client = self
                            completion(false, resultValue, nil)
                        } else {
                            if let statusCode = response.response?.statusCode {
                                switch statusCode {
                                case 202:
                                    completion(true, nil, nil)
                                    
                                default:
                                    completion(false, nil, NSError.unhandledError(RestClient.self))
                                }
                            } else {
                                completion(false, nil, NSError.unhandledError(RestClient.self))
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
        }
    }
    
    internal func retrieveCreditCard(_ url: String, completion: @escaping CreditCardHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            if let headers = headers {
                let request = self?._manager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                request?.validate().responseObject(queue: DispatchQueue.global()) { [weak self] (response: DataResponse<CreditCard>) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            completion(nil, error)
                        } else if let resultValue = response.result.value
                        {
                            resultValue.client = self
                            resultValue.applySecret(strongSelf.secret, expectedKeyId: headers[RestClient.fpKeyIdKey])
                            completion(resultValue, nil)
                        } else {
                            completion(nil, NSError.unhandledError(RestClient.self))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    internal func makeDefault(_ url: String, completion: @escaping MakeDefaultHandler) {
        self.prepareAuthAndKeyHeaders { [weak self] (headers, error) in
            if let headers = headers {
                let request = self?._manager.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                request?.validate().responseObject(queue: DispatchQueue.global()) { [weak self] (response: DataResponse<CreditCard>) in
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            completion(false, nil, error)
                        } else if let resultValue = response.result.value {
                            resultValue.client = self
                            completion(false, resultValue, nil)
                        } else {
                            if let statusCode = response.response?.statusCode {
                                switch statusCode {
                                case 202:
                                    completion(true, nil, nil)
                                    
                                default:
                                    completion(false, nil, NSError.unhandledError(RestClient.self))
                                }
                            } else {
                                completion(false, nil, NSError.unhandledError(RestClient.self))
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
        }
    }
}
