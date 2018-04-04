import Foundation

open class UserEventStreamManager {
    open static let sharedInstance = UserEventStreamManager()
    
    private var client: RestClient?
    private var userEventStream: UserEventStream?
    
    open func subscribe(userId: String, sessionData: SessionData, config: FitpaySDKConfiguration) {
        let session = RestSession(configuration: config, sessionData: sessionData)
        client = RestClient(session: session)

        client!.user(id: userId) { (user, error) in
            guard let user = user else { return }
            
            self.userEventStream = UserEventStream(user: user)
        }
    }
}
