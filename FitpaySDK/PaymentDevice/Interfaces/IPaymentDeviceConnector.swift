
@objc public enum NonAPDUCommitState: Int {
    case success = 0 // will continue commits execution
    case skipped     // will continue commits execution
    case failed      // will stop sync
    
    var description: String {
        switch self {
        case .failed:
            return "FAILED"
        case .skipped:
            return "SKIPPED"
        case .success:
            return "SUCCESS"
        }
    }
}

@objc public protocol IPaymentDeviceConnector
{
    /// Connects to the payment device
    /// As result event PaymentDeviceEventTypes.onDeviceConnected should be called
    func connect()

    /// Connection check
    ///
    /// - Returns: true if phone connected to payment device and device info was collected
    func isConnected() -> Bool

    /// Async validation for connection between payment device and phone
    ///
    /// - Parameter completion: completion for async task.
    /// isValid should be true if connection is valid
    /// and device is ready for communications
    func validateConnection(completion: @escaping (_ isValid: Bool, _ error: NSError?) -> Void)

    /// Do what you need before executing apdu package
    ///
    /// - Parameters:
    ///   - apduPackage: apduPackage object
    ///   - completion: call completion when your task is done
    @objc optional func onPreApduPackageExecute(_ apduPackage: ApduPackage, completion: @escaping (_ error: NSError?) -> Void)

    /// Should execute APDU command on payment device.
    /// Should call PaymentDevice.apduResponseHandler when preocessed
    ///
    /// - Parameter apduCommand: apduCommand object
    func executeAPDUCommand(_ apduCommand: APDUCommand)
    
    /// Do what you need after executing apdu package
    ///
    /// - Parameters:
    ///   - apduPackage: apduPackage object
    ///   - completion: call completion when your task is done
    @objc optional func onPostApduPackageExecute(_ apduPackage: ApduPackage, completion: @escaping (_ error: NSError?) -> Void)

    /// If you need to process non apdu commit somehow then you need to implement this method.
    /// Don't forget to call completion, system is waiting for that completion.
    ///
    /// - Parameters:
    ///   - commit: current Commit object
    ///   - completion: state is process result. If state == failed, then it would be great if error object will be also provided.
    @objc optional func processNonAPDUCommit(_ commit: Commit, completion: @escaping (_ state: NonAPDUCommitState, _ error: NSError?) -> Void)
    
    /// - Returns: DeviceInfo if phone already connected to payment device
    func deviceInfo() -> DeviceInfo?

    func resetToDefaultState()
}
