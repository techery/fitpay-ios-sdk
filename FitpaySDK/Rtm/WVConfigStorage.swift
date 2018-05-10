import Foundation

struct WvConfigStorage {
    var paymentDevice: PaymentDevice?
    var user: User?
    var device: DeviceInfo?
    var a2aReturnLocation: String?
    
    var rtmConfig: RtmConfigProtocol?
}
