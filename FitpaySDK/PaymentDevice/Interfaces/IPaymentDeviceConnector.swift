
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

    /// - Returns: DeviceInfo if phone already connected to payment device
    func deviceInfo() -> DeviceInfo?

    func resetToDefaultState()
}
