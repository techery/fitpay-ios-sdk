import Foundation
import Alamofire

class UserEventStream {
    
    init(user: User) {
        guard let eventStreamLink = user.links?.url("eventStream") else { return }
        

        let eventSource = EventSource(url: eventStreamLink, headers: [:])

        eventSource.onOpen {
            print("!!----- onOpen")
        }

        eventSource.onError { (error) in
            print("!!----- onError \(String(describing: error))")
        }

        eventSource.onMessage { (id, event, data) in
            print("!!----- onMessage")
        }

    }
    
    
}
