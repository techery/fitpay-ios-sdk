import Foundation
import Alamofire

extension RestClient {
    
    //MARK - Completion Handlers
    
    /**
     Completion handler
     
     - parameter relationship: Provides Relationship object, or nil if error occurs
     - parameter error:        Provides error object, or nil if no error occurs
     */
    public typealias RelationshipHandler = (_ relationship: Relationship?, _ error: ErrorResponse?) -> Void
    
    //MARK - Functions
    
    /**
     Creates a relationship between a device and a creditCard
     
     - parameter userId:       user id
     - parameter creditCardId: credit card id
     - parameter deviceId:     device id
     - parameter completion:   CreateRelationshipHandler closure
     */
    public func createRelationship(_ url: String, creditCardId: String, deviceId: String, completion: @escaping RelationshipHandler) {
        let parameters = ["creditCardId": creditCardId, "deviceId": deviceId]
        self.makeGetCall(url, parameters: parameters, completion: completion)
    }
    
}
