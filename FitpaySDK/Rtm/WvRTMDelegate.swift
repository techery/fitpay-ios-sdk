import Foundation

@objc public protocol WvRTMDelegate: NSObjectProtocol {
    /**
     This method will be called after successful user authorization.
     */
    @objc optional func didAuthorizeWithEmail(_ email: String?)
    
    /**
     This method can be used for user messages customization.
     
     Will be called when status has changed and system going to show message.
     
     - parameter status:         New device status
     - parameter defaultMessage: Default message for new status
     - parameter error:          If we had an error during status change than it will be here.
     For now error will be used with SyncError status
     
     - returns:                  Message string which will be shown on status board.
     */
    @objc optional func willDisplayStatusMessage(_ status: WvConfig.WVDeviceStatuses, defaultMessage: String, error: NSError?) -> String
    
    /**
     Called when the message from wv was delivered to SDK.
     
     - parameter message: message from web view
     */
    @objc optional func onWvMessageReceived(message: RtmMessage)
    
}
