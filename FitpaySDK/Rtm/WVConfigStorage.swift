import Foundation

class WvConfigStorage {
    var paymentDevice: PaymentDevice?
    var user: User?
    var device: DeviceInfo?
    var a2aReturnLocation: String? = nil
    
    var rtmConfig: RtmConfigProtocol?
}
