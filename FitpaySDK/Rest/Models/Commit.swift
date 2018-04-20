
import ObjectMapper

open class Commit : NSObject, ClientModel, Serializable, SecretApplyable
{
    var links:[ResourceLink]?
    open var commitType:CommitType? {
        return CommitType(rawValue: commitTypeString ?? "") ?? .UNKNOWN
    }
    open var commitTypeString: String?
    open var payload:Payload?
    open var created:CLong?
    open var previousCommit:String?
    open var commit:String?
    open var executedDuration:Int?
    
    fileprivate static let apduResponseResource = "apduResponse"
    fileprivate static let confirmResource = "confirm"
    
    public weak var client: RestClient? {
        didSet {
            payload?.creditCard?.client = self.client
        }
    }
    
    internal var encryptedData:String?

    private enum CodingKeys: String, CodingKey {
        case links = "_links"
        case commitTypeString
        case created = "createdTs"
        case previousCommit
        case commit = "commitId"
        case encryptedData
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        links = try container.decode(.links, transformer: ResourceLinkTypeTransform())
        commitTypeString = try container.decode(.commitTypeString)
        created = try container.decode(.created)
        previousCommit = try container.decode(.previousCommit)
        commit = try container.decode(.commit)
        encryptedData = try container.decode(.encryptedData)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(links, forKey: .links)
        try container.encode(commitTypeString, forKey: .commitTypeString)
        try container.encode(created, forKey: .created)
        try container.encode(previousCommit, forKey: .previousCommit)
        try container.encode(commit, forKey: .commit)
        try container.encode(encryptedData, forKey: .encryptedData)
    }
    
    internal func applySecret(_ secret:Data, expectedKeyId:String?) {
        self.payload = JWEObject.decrypt(self.encryptedData, expectedKeyId: expectedKeyId, secret: secret)
        self.payload?.creditCard?.client = self.client
    }
    
    internal func confirmNonAPDUCommitWith(result: NonAPDUCommitState, completion: @escaping RestClient.ConfirmCommitHandler) {
        log.verbose("Confirming commit - \(self.commit ?? "")")
        
        guard self.commitType != CommitType.APDU_PACKAGE else {
            log.error("Trying send confirm for APDU commit but should be non APDU.")
            completion(NSError.unhandledError(Commit.self))
            return
        }
        
        let resource = Commit.confirmResource
        guard let url = self.links?.url(resource) else {
            completion(nil)
            return
        }
        
        guard let client = self.client else {
            completion(NSError.clientUrlError(domain:Commit.self, code:0, client: nil, url: url, resource: resource))
            return
        }
        
        client.confirm(url, executionResult: result, completion: completion)
    }
    
    internal func confirmAPDU(_ completion:@escaping RestClient.ConfirmAPDUPackageHandler) {
        log.verbose("in the confirmAPDU method")
        guard self.commitType == CommitType.APDU_PACKAGE else {
            completion(NSError.unhandledError(Commit.self))
            return
        }
        
        let resource = Commit.apduResponseResource
        guard let url = self.links?.url(resource) else {
            completion(NSError.clientUrlError(domain:Commit.self, code:0, client: client, url: nil, resource: resource))
            return
        }
        
        guard let client = self.client else {
            completion(NSError.clientUrlError(domain:Commit.self, code:0, client: nil, url: url, resource: resource))
            return
        }
        
        guard let apduPackage = self.payload?.apduPackage else {
            completion(NSError.unhandledError(Commit.self))
            return
        }
        
        log.verbose("apdu package \(apduPackage)")
        client.confirmAPDUPackage(url, package: apduPackage, completion: completion)
    }
}

public enum CommitType : String
{
    case CREDITCARD_CREATED          = "CREDITCARD_CREATED"
    case CREDITCARD_DEACTIVATED      = "CREDITCARD_DEACTIVATED"
    case CREDITCARD_ACTIVATED        = "CREDITCARD_ACTIVATED"
    case CREDITCARD_REACTIVATED      = "CREDITCARD_REACTIVATED"
    case CREDITCARD_DELETED          = "CREDITCARD_DELETED"
    case RESET_DEFAULT_CREDITCARD    = "RESET_DEFAULT_CREDITCARD"
    case SET_DEFAULT_CREDITCARD      = "SET_DEFAULT_CREDITCARD"
    case APDU_PACKAGE                = "APDU_PACKAGE"
    case CREDITCARD_PROVISION_FAILED = "CREDITCARD_PROVISION_FAILED"
    case CREDITCARD_METADATA_UPDATED = "CREDITCARD_METADATA_UPDATED"
    case UNKNOWN                     = "UNKNOWN"
}

open class Payload : NSObject, Mappable
{
    open var creditCard:CreditCard?
    internal var payloadDictionary:[String : AnyObject]?
    internal var apduPackage:ApduPackage?
    
    public required init?(map: Map)
    {
        
    }
    
    open func mapping(map: Map)
    {
        let info = map.JSON
        
        if let _ = info["creditCardId"]
        {
            self.creditCard = CreditCard(info)
        }
        else if let _ = info["packageId"]
        {
            self.apduPackage = try? ApduPackage(info)
        }
        
        self.payloadDictionary = info as [String : AnyObject]?
    }
}
