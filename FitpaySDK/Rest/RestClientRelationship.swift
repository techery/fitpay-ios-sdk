//
//  RestClientRelationship.swift
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
     
     - parameter relationship: Provides created Relationship object, or nil if error occurs
     - parameter error:        Provides error object, or nil if no error occurs
     */
    public typealias CreateRelationshipHandler = (_ relationship: Relationship?, _ error: NSError?) -> Void
    
    /**
     Completion handler
     
     - parameter error: Provides error object, or nil if no error occurs
     */
    public typealias DeleteRelationshipHandler = (_ error: NSError?) -> Void
    
    /**
     Completion handler
     
     - parameter relationship: Provides Relationship object, or nil if error occurs
     - parameter error:        Provides error object, or nil if no error occurs
     */
    public typealias RelationshipHandler = (_ relationship: Relationship?, _ error: NSError?) -> Void

    /**
     Creates a relationship between a device and a creditCard
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   CreateRelationshipHandler closure
     */
    internal func createRelationship(_ url: String, creditCardId: String, deviceId: String, completion: @escaping CreateRelationshipHandler)
    {
        self.prepareAuthAndKeyHeaders { (headers, error) in
            if let headers = headers {
                let parameters = [
                    "creditCardId": "\(creditCardId)",
                    "deviceId": "\(deviceId)"
                ]
                let request = self._manager.request(url + "/relationships", method: .put, parameters: parameters, encoding: URLEncoding.queryString, headers: headers)
                request.validate().responseObject(queue: DispatchQueue.global()) { (response: DataResponse<Relationship>) in
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            
                            completion(nil, error)
                        } else if let resultValue = response.result.value {
                            resultValue.client = self
                            completion(resultValue, response.result.error as NSError?)
                        } else {
                            completion(nil, NSError.unhandledError(RestClient.self))
                        }
                    }
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    internal func relationship(_ url: String, completion: @escaping RelationshipHandler)
    {
        self.prepareAuthAndKeyHeaders { (headers, error) in
            if let headers = headers {
                let request = self._manager.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers)
                request.validate().responseObject(queue: DispatchQueue.global()) { (response: DataResponse<Relationship>) in
                    DispatchQueue.main.async {
                        if response.result.error != nil {
                            let error = NSError.errorWith(dataResponse: response, domain: RestClient.self)
                            
                            completion(nil, error)
                        } else if let resultValue = response.result.value {
                            resultValue.client = self
                            completion(resultValue, response.result.error as NSError?)
                        } else {
                            completion(nil, NSError.unhandledError(RestClient.self))
                        }
                    }
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    internal func deleteRelationship(_ url: String, completion: @escaping DeleteRelationshipHandler)
    {
        self.prepareAuthAndKeyHeaders { (headers, error) in
            if let headers = headers {
                let request = self._manager.request(url, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: headers)
                request.validate().responseString { (response: DataResponse<String>) in
                    DispatchQueue.main.async {
                        completion(response.result.error as NSError?)
                    }
                }
            } else {
                completion(error)
            }
        }
    }
}
