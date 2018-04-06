import Foundation
import Alamofire

class UserEventStream {
    
    init(user: User, client: RestClient) {
        guard let eventStreamLink = user.links?.url("eventStream") else { return }
        
        client.prepareAuthAndKeyHeaders { (headers, error) in
            let eventSource = EventSource(url: eventStreamLink, headers: [:])
            eventSource.onOpen {
                log.debug("USER_EVENT_STREAM: connected to event stream for user \(user.id)")
            }
            
            eventSource.onError { (error) in
                log.error("USER_EVENT_STREAM: error in event stream")
            }
            
            eventSource.onMessage { (id, event, data) in
                log.debug("USER_EVENT_STREAM: message for \(user.id) received:")
                let jwtBody = JWEObject.decryptSigned(data, expectedKeyId: client.key?.keyId, secret: client.secret)
                print(jwtBody)
                print("here")
            }
            
        }
        
    }
    
    
}
