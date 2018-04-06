import ObjectMapper
import JWT

extension JWEObject {
    
    class func decrypt<T: Mappable>(_ encryptedData: String?, expectedKeyId: String?, secret: Data) -> T? {
        guard let encryptedData = encryptedData else { return nil }
        
        let jweResult = JWEObject.parse(payload: encryptedData)
        
        if let expectedKeyId = expectedKeyId {
            guard jweResult?.header?.kid == expectedKeyId else { return nil }
        }
        
        if let decryptResult = try? jweResult?.decrypt(secret) {
            return Mapper<T>().map(JSONString: decryptResult!)
        }
        
        return nil
    }
    
    class func decryptSigned(_ encryptedData: String?, expectedKeyId: String?, secret: Data) -> String? {
        guard let encryptedData = encryptedData else { return nil }
        
        let jweResult = JWEObject.parse(payload: encryptedData)
        
        if let expectedKeyId = expectedKeyId {
            guard jweResult?.header?.kid == expectedKeyId else { return nil }
        }
        
        guard let decryptResult = try? jweResult?.decrypt(secret) else { return nil }
        guard jweResult?.header?.cty == "JWT" else { return nil }
        
        let claimSet = try? JWT.decode(decryptResult!, algorithm: .none, verify: false, audience: nil, issuer: nil, leeway: 10)
        //verify signature and key
        
        let payload = claimSet?["data"] as? String
        return payload

    }
    
}
