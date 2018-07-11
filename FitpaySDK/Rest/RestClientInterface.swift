import Foundation
import Alamofire

protocol RestClientInterface: class {
    
    //MARK: - Completion handlers
    
    /**
     Completion handler
     
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias DeleteHandler = (_ error: ErrorResponse?) -> Void
    
    /**
     Confirm handlers
     
     - parameter ErrorType?:   Provides error object, or nil if no error occurs
     */
    typealias ConfirmHandler = (_ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter transactions: Provides ResultCollection<Transaction> object, or nil if error occurs
     - parameter error:        Provides error object, or nil if no error occurs
     */
    typealias TransactionsHandler = (_ result: ResultCollection<Transaction>?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter encryptionKey?: Provides EncryptionKey object, or nil if error occurs
     - parameter error?:         Provides error object, or nil if no error occurs
     */
    typealias EncryptionKeyHandler = (_ encryptionKey: EncryptionKey?, _ error: ErrorResponse?) -> Void
    
    typealias AuthHeaderHandler = (_ headers: [String: String]?, _ error: ErrorResponse?) -> Void
    
    typealias IssuersHandler = (_ issuers: Issuers?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter asset: Provides Asset object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    typealias AssetsHandler = (_ asset: Asset?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter error: Provides error object, or nil if no error occurs
     */
    typealias ResetHandler = (_ resetDeviceTask: ResetDeviceResult?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter resultValue: Provides request object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    typealias RequestHandler = (_ resultValue: Any?, _ error: ErrorResponse?) -> Void
    
    //MARK: - RestClientUser
    
    /**
     Completion handler
     
     - parameter user: Provides User object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    typealias UserHandler = (_ user: User?, _ error: ErrorResponse?) -> Void
    
    //MARK: - RestClientDevice
    
    /**
     Completion handler
     
     - parameter result: Provides ResultCollection<DeviceInfo> object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    typealias DevicesHandler = (_ result: ResultCollection<DeviceInfo>?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter device: Provides existing DeviceInfo object, or nil if error occurs
     - parameter error: Provides error object, or nil if no error occurs
     */
    typealias DeviceHandler = (_ device: DeviceInfo?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter commits: Provides ResultCollection<Commit> object, or nil if error occurs
     - parameter error:   Provides error object, or nil if no error occurs
     */
    typealias CommitsHandler = (_ result: ResultCollection<Commit>?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter commit:    Provides Commit object, or nil if error occurs
     - parameter error:     Provides error object, or nil if no error occurs
     */
    typealias CommitHandler = (_ commit: Commit?, _ error: ErrorResponse?) -> Void
    
    //MARK: - RestClientCreditCard
    
    /**
     Completion handler
     
     - parameter result: Provides collection of credit cards, or nil if error occurs
     - parameter error:  Provides error object, or nil if no error occurs
     */
    typealias CreditCardsHandler = (_ result: ResultCollection<CreditCard>?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter creditCard: Provides credit card object, or nil if error occurs
     - parameter error:  Provides error object, or nil if no error occurs
     */
    typealias CreditCardHandler = (_ creditCard: CreditCard?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter pending: Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that CreditCard object is nil in this case
     - parameter card?:   Provides updated CreditCard object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error?:  Provides error object, or nil if no error occurs
     */
    typealias CreditCardTransitionHandler = (_ pending: Bool, _ card: CreditCard?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler
     
     - parameter pending:            Provides pending flag, indicating that transition was accepted, but current status can be reviewed later. Note that VerificationMethod object is nil in this case
     - parameter verificationMethod: Provides VerificationMethod object, or nil if pending (Bool) flag is true or if error occurs
     - parameter error:              Provides error object, or nil if no error occurs
     */
    typealias VerifyHandler = (_ pending: Bool, _ verificationMethod: VerificationMethod?, _ error: ErrorResponse?) -> Void
    
    /**
     Completion handler

     - parameter verificationMethod: Provides VerificationMethod object, or nil if error occurs
     - parameter error:              Provides error object, or nil if no error occurs
     */
    typealias VerifyMethodHandler = (_ verificationMethod: VerificationMethod?, _ error: ErrorResponse?) -> Void

    /**
     Completion handler

     - parameter verificationMethods: Provides VerificationMethods objects, or nil if error occurs
     - parameter error:              Provides error object, or nil if no error occurs
     */
    typealias VerifyMethodsHandler = (_ verificationMethods: ResultCollection<VerificationMethod>?, _ error: ErrorResponse?) -> Void
    
    // MARK: - Variables
    
    var key: EncryptionKey? { get set }
    
    var secret: Data { get }
    
    // MARK: - Methods
    
    func collectionItems<T>(_ url: String, completion: @escaping (_ resultCollection: ResultCollection<T>?, _ error: ErrorResponse?) -> Void) -> T?
    
    func confirm(_ url: String, executionResult: NonAPDUCommitState, completion: @escaping ConfirmHandler)
    
    func getPlatformConfig(completion: @escaping (_ platform: PlatformConfig?, _ error: ErrorResponse?) -> Void)
    
    /**
     Endpoint to allow for returning responses to APDU execution
     
     - parameter package:    ApduPackage object
     - parameter completion: ConfirmAPDUPackageHandler closure
     */
    func confirmAPDUPackage(_ url: String, package: ApduPackage, completion: @escaping ConfirmHandler)
        
    /**
     Creates a new encryption key pair
     
     - parameter clientPublicKey: client public key
     - parameter completion:      CreateEncryptionKeyHandler closure
     */
    func createEncryptionKey(clientPublicKey: String, completion: @escaping EncryptionKeyHandler)
    
    /**
     Retrieve and individual key pair
     
     - parameter keyId:      key id
     - parameter completion: EncryptionKeyHandler closure
     */
    func encryptionKey(_ keyId: String, completion: @escaping EncryptionKeyHandler)
    
    /**
     Deletes encryption key
     
     - parameter keyId:      key id
     - parameter completion: DeleteHandler
     */
    func deleteEncryptionKey(_ keyId: String, completion: @escaping DeleteHandler)
    
    func createKeyIfNeeded(_ completion: @escaping EncryptionKeyHandler)
    
    func createAuthHeaders(_ completion: AuthHeaderHandler)
        
    func prepareAuthAndKeyHeaders(_ completion: @escaping AuthHeaderHandler)
    
    func preparKeyHeader(_ completion: @escaping AuthHeaderHandler)
    
    func issuers(completion: @escaping IssuersHandler)
    
    func assets(_ url: String, completion: @escaping AssetsHandler)

    /// Creates a request for resetting a device
    ///
    /// - Parameters:
    ///   - url: url string
    ///   - completion: ResetHandler
    func resetDeviceTasks(_ url: String, completion: @escaping ResetHandler)
    
    /// Creates a request for getting reset status
    ///
    /// - Parameters:
    ///   - url: url string
    ///   - completion: Reset Handler
    func resetDeviceStatus(_ url: String, completion: @escaping ResetHandler)
    
    //MARK: - RestClientUser
    
    /**
     Creates a new user within your organization
     
     - parameter firstName:  first name of the user
     - parameter lastName:   last name of the user
     - parameter birthDate:  birth date of the user in date format [YYYY-MM-DD]
     - parameter email:      email of the user
     - parameter completion: CreateUserHandler closure
     */
    func createUser(_ email: String, password: String, firstName: String?, lastName: String?,
                    birthDate: String?, termsVersion: String?, termsAccepted: String?, origin: String?,
                    originAccountCreated: String?, completion: @escaping UserHandler)
    
    /**
     Retrieves the details of an existing user. You need only supply the unique user identifier that was returned upon user creation
     
     - parameter id:         user id
     - parameter completion: UserHandler closure
     */
    func user(id: String, completion: @escaping UserHandler)
    
    /**
     Update the details of an existing user
     
     - parameter id:                   user id
     - parameter firstName:            first name or nil if no change is required
     - parameter lastName:             last name or nil if no change is required
     - parameter birthDate:            birth date in date format [YYYY-MM-DD] or nil if no change is required
     - parameter originAccountCreated: origin account created in date format [TODO: specify date format] or nil if no change is required
     - parameter termsAccepted:        terms accepted in date format [TODO: specify date format] or nil if no change is required
     - parameter termsVersion:         terms version formatted as [0.0.0]
     - parameter completion:           UpdateUserHandler closure
     */
    func updateUser(_ url: String,  firstName: String?, lastName: String?,
                    birthDate: String?, originAccountCreated: String?, termsAccepted: String?,
                    termsVersion: String?, completion: @escaping UserHandler)
    
    //MARK: - RestClientDevice
    
    func createNewDevice(_ url: String, deviceInfo: DeviceInfo, completion: @escaping DeviceHandler)
    
    func updateDevice(_ url: String,
                      firmwareRevision: String?,
                      softwareRevision: String?,
                      notificationToken: String?,
                      completion: @escaping DeviceHandler)
    
    func addDeviceProperty(_ url: String, propertyPath: String, propertyValue: String, completion: @escaping DeviceHandler)
    
    func commits(_ url: String, commitsAfter: String?, limit: Int, offset: Int, completion: @escaping CommitsHandler)
    
    //MARK: - RestClientCreditCard
    
    func createCreditCard(_ url: String, cardInfo: CardInfo, deviceId: String?, completion: @escaping CreditCardHandler)
    
    func creditCards(_ url: String, excludeState: [String], limit: Int, offset: Int, deviceId: String?, completion: @escaping CreditCardsHandler)
        
    func updateCreditCard(_ url: String, name: String?, address: Address, completion: @escaping CreditCardHandler)
    
    func acceptCall(_ url: String, completion: @escaping CreditCardTransitionHandler)
    
    func selectVerificationType(_ url: String, completion: @escaping VerifyHandler)
    
    func verify(_ url: String, verificationCode: String, completion: @escaping VerifyHandler)
    
    func activationCall(_ url: String, causedBy: CreditCardInitiator, reason: String, completion: @escaping CreditCardTransitionHandler)
        
    func makeDefault(_ url: String, completion: @escaping CreditCardTransitionHandler)
    
    func handleVerifyResponse(_ response: ErrorResponse?, completion: @escaping VerifyHandler)
            
    func handleTransitionResponse(_ response: ErrorResponse?, completion: @escaping CreditCardTransitionHandler)
    

    // MARK: - Generic
    
    typealias ResultHandler<T> = (_ result: T?, _ error: ErrorResponse?) -> Void
    
    typealias ResultCollectionHandler<T: Codable> = (_ result: ResultCollection<T>?, _ error: ErrorResponse?) -> Void

    func makeDeleteCall(_ url: String, completion: @escaping DeleteHandler)

    func makePostCall(_ url: String, parameters: [String: Any]?, completion: @escaping ConfirmHandler)
    
    func makeGetCall<T: Codable>(_ url: String, limit: Int, offset: Int, completion: @escaping ResultCollectionHandler<T>)
    
    func makeGetCall<T:Codable>(_ url: String, parameters: [String: Any]?, completion: @escaping ResultCollectionHandler<T>)
    
    func makeGetCall<T: Serializable>(_ url: String, parameters: [String: Any]?, completion: @escaping ResultHandler<T>)
    
    func makeGetCall<T: Serializable & ClientModel & SecretApplyable>(_ url: String, parameters: [String: Any]?, completion: @escaping ResultHandler<T>)

    func makeGetCall<T: Serializable & ClientModel>(_ url: String, parameters: [String: Any]?, completion: @escaping ResultHandler<T>)

}
