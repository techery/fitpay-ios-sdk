import Foundation

enum JWEAlgorithm: String {
    case A256GCMKW = "A256GCMKW"
}

enum JWEEncryption: String {
    case A256GCM = "A256GCM"
}

enum JWEObjectError: Error {
    case unsupportedAlgorithm
    case unsupportedEncryption
    
    case headerNotSpecified
    case encryptionNotSpecified
    case algorithmNotSpecified
    case headersIVNotSpecified
    case headersTagNotSpecified
}

class JWEObject {
    
    static let AuthenticationTagSize = 16
    static let CekSize = 32
    static let CekIVSize = 12
    static let PayloadIVSize = 16
    
    var header: JWEHeader?
    
    private var cekCt: Data?
    private var iv: Data?
    private var ct: Data?
    private var tag: Data?
    
    private(set) var encryptedPayload: String?
    private(set) var decryptedPayload: String?
    private var payloadToEncrypt: String?
    
    static func parse(payload: String) -> JWEObject? {
        let jweObject = JWEObject()
        jweObject.encryptedPayload = payload
        
        let jwe = payload.components(separatedBy: ".")
        jweObject.header = JWEHeader(headerPayload: jwe[0])
        jweObject.cekCt = jwe[1].base64URLdecoded()
        jweObject.iv = jwe[2].base64URLdecoded()
        jweObject.ct = jwe[3].base64URLdecoded()
        jweObject.tag = jwe[4].base64URLdecoded()

        return jweObject
    }
    
    static func createNewObject(_ alg: JWEAlgorithm, enc: JWEEncryption, payload: String, keyId: String?) throws -> JWEObject {
        let jweObj = JWEObject()
        jweObj.header = JWEHeader(encryption: enc, algorithm: alg)
        jweObj.header!.kid = keyId
        jweObj.payloadToEncrypt = payload
        
        return jweObj
    }
    
    func encrypt(_ sharedSecret: Data) throws -> String? {
        guard payloadToEncrypt != nil else {
            return nil
        }
        
        guard header != nil else {
            throw JWEObjectError.headerNotSpecified
        }
        
        if (header?.alg == JWEAlgorithm.A256GCMKW && header?.enc == JWEEncryption.A256GCM) {
            let cek = String.random(JWEObject.CekSize).data(using: String.Encoding.utf8)
            let cekIV = String.random(JWEObject.CekIVSize).data(using: String.Encoding.utf8)
            
            let (cekCtCt, cekCTTag) = A256GCMEncryptData(sharedSecret, data: cek!, iv: cekIV!, aad: nil)
            let encodedCekCt = cekCtCt!.base64URLencoded()
            
            let payloadIV = String.random(JWEObject.PayloadIVSize).data(using: String.Encoding.utf8)
            let encodedPayloadIV = payloadIV?.base64URLencoded()
            
            let encodedHeader : Data!
            let base64UrlHeader : String!
            do {
                header?.tag = cekCTTag
                header?.iv = cekIV
                
                base64UrlHeader = try header?.serialize()
                encodedHeader = base64UrlHeader.data(using: String.Encoding.utf8)
            } catch let error {
                throw error
            }
            
            let (encryptedPayloadCt, encryptedPayloadTag) = A256GCMEncryptData(cek!, data: payloadToEncrypt!.data(using: String.Encoding.utf8)!, iv: payloadIV!, aad: encodedHeader)
            
            let encodedCipherText = encryptedPayloadCt?.base64URLencoded()
            let encodedAuthTag = encryptedPayloadTag?.base64URLencoded()
            
            guard base64UrlHeader != nil && encodedPayloadIV != nil && encodedCipherText != nil && encodedAuthTag != nil else {
                return nil
            }
            
            encryptedPayload = "\(base64UrlHeader!).\(encodedCekCt).\(encodedPayloadIV!).\(encodedCipherText!).\(encodedAuthTag!)"
        }
        
        return encryptedPayload
    }
    
    func decrypt(_ sharedSecret: Data) throws -> String? {
        guard header != nil else {
            throw JWEObjectError.headerNotSpecified
        }
        
        if (header?.alg == JWEAlgorithm.A256GCMKW && header?.enc == JWEEncryption.A256GCM) {
            
            guard header!.iv != nil else {
                throw JWEObjectError.headersIVNotSpecified
            }
            
            guard header!.tag != nil else {
                throw JWEObjectError.headersTagNotSpecified
            }
            
            guard ct != nil && tag != nil else {
                return nil
            }
            
            guard let cek = A256GCMDecryptData(sharedSecret, data: cekCt!, iv: header!.iv! as Data, tag: header!.tag! as Data, aad: nil) else {
                return nil
            }
            let jwe = encryptedPayload!.components(separatedBy: ".")
            let aad = jwe[0].data(using: String.Encoding.utf8)
            
            // ensure that we have 16 bytes in Authentication Tag
            if ((tag?.count)! < JWEObject.AuthenticationTagSize) {
                let concatedCtAndTag = NSMutableData(data: ct!)
                concatedCtAndTag.append(tag!)
                if (concatedCtAndTag.length > JWEObject.AuthenticationTagSize) {
                    ct = concatedCtAndTag.subdata(with: NSRange(location: 0, length: concatedCtAndTag.length-JWEObject.AuthenticationTagSize))
                    tag = concatedCtAndTag.subdata(with: NSRange(location: concatedCtAndTag.length-JWEObject.AuthenticationTagSize, length: JWEObject.AuthenticationTagSize))
                }
            }
            
            let data = A256GCMDecryptData(cek, data: ct!, iv: iv!, tag: tag!, aad: aad)
            decryptedPayload = String(data: data!, encoding: String.Encoding.utf8)
        }
        
        return decryptedPayload
    }
    
    private init() {
        
    }
    
    private func A256GCMDecryptData(_ cipherKey: Data, data: Data, iv: Data, tag: Data, aad: Data?) -> Data? {
        // cryptAuth expects that data will be with tag
        // so appending tag to data
        var dataWithTag = data
        dataWithTag.append(tag)
        
        var decryptedData: Data? = nil
        do {
            decryptedData = try CC.cryptAuth(.decrypt,
                                             blockMode: .gcm,
                                             algorithm: .aes,
                                             data: dataWithTag,
                                             aData: aad ?? Data(),
                                             key: cipherKey,
                                             iv: iv,
                                             tagLength: JWEObject.AuthenticationTagSize)
        } catch {
            log.error("Can't decrypt data with a256gcm. Error: \(error).")
        }
        
        return decryptedData
    }
    
    private func A256GCMEncryptData(_ key: Data, data: Data, iv: Data, aad: Data?) -> (Data?, Data?) {
        var encryptResult: (Data?, Data?) = (nil, nil)
        
        do {
            let encryptedWithTag = try CC.cryptAuth(.encrypt,
                                                    blockMode: .gcm,
                                                    algorithm: .aes,
                                                    data: data,
                                                    aData: aad ?? Data(),
                                                    key: key,
                                                    iv: iv,
                                                    tagLength: JWEObject.AuthenticationTagSize)
            
            let cipherText = encryptedWithTag.subdata(in: 0..<(encryptedWithTag.count-JWEObject.AuthenticationTagSize))
            let tag = encryptedWithTag.subdata(in: (encryptedWithTag.count-JWEObject.AuthenticationTagSize)..<encryptedWithTag.count)
            
            encryptResult = (cipherText, tag)
        } catch  {
            log.error("Can't encrypt data with a256gcm. Error: \(error).")
        }
        
        return encryptResult
    }
}
