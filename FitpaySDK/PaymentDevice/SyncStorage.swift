import KeychainAccess

public protocol SyncStorageProtocol {
    func getLastCommitId(_ deviceId:String) -> String
    func setLastCommitId(_ deviceId:String, commitId:String) -> Void
}

public class SyncStorage: SyncStorageProtocol {
    public static let sharedInstance = SyncStorage()
    
    fileprivate var keychain: Keychain
    fileprivate let keychainFieldName: String = "FitPayLastSyncCommitId"
    
    init() {
        self.keychain = Keychain(service: "com.masterofcode-llc.FitpaySDK")
    }

    public func getLastCommitId(_ deviceId:String) -> String {
        if let commitId = self.keychain[deviceId] {
            return commitId
        } else {
            return String()
        }
    }

    public func setLastCommitId(_ deviceId:String, commitId:String) -> Void {
        self.keychain[deviceId] = commitId
    }
}
