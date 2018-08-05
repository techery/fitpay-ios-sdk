import Foundation

public struct PlatformConfig: Serializable {
    
    public let isUserEventStreamsEnabled: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isUserEventStreamsEnabled = "userEventStreamsEnabled"
    }
}
