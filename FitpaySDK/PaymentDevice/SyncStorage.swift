import KeychainAccess

public class SyncStorage {
    public static let sharedInstance = SyncStorage()
    
    fileprivate var keychain: Keychain
    fileprivate let keychainFieldName: String = "FitPayLastSyncCommitId"
    
    private init() {
        self.keychain = Keychain(service: "com.masterofcode-llc.FitpaySDK")
    }

    internal func getLastCommitId(_ deviceId:String) -> String {
        if let commitId = self.keychain[deviceId] {
            return commitId
        } else {
            return String()
        }
    }

    internal func setLastCommitId(_ deviceId:String, commitId:String) -> Void {
        self.keychain[deviceId] = commitId
    }
    
    
}
