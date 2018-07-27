import Foundation
import Alamofire

public protocol RestRequestable {
    typealias RequestHandler = (_ resultValue: Any?, _ error: ErrorResponse?) -> Void

    func makeRequest(request: DataRequest?, completion: @escaping RequestHandler)
}

class RestRequest: RestRequestable {
    
    func makeRequest(request: DataRequest?, completion: @escaping RequestHandler) {
        request?.validate(statusCode: 200..<300).responseJSON() { (response) in
            if let resultValue = response.result.value {
                completion(resultValue, nil)
                
            } else if response.response?.statusCode == 202 {
                completion(nil, nil)
                
            } else if response.result.error != nil {
                let JSON = response.data!.UTF8String
                let error = (try? ErrorResponse(JSON)) ?? ErrorResponse(domain: RestClient.self, errorCode: response.response?.statusCode ?? 0 , errorMessage: response.result.error?.localizedDescription)
                completion(nil, error)
                
            } else {
                completion(nil, ErrorResponse.unhandledError(domain: RestClient.self))
            }
        }
    }
    
}

class MockRestRequest: RestRequestable {
    
    func makeRequest(request: DataRequest?, completion: @escaping RequestHandler) {
        guard let urlString = request?.request?.url?.absoluteString else {
            completion(nil, ErrorResponse.unhandledError(domain: RestClient.self))
            return
        }
        
        var data: Any? = nil
        
        if urlString.contains("commits") {
            data = loadDataFromJSONFile(filename: "getCommit")
            
        } else if urlString.contains("transactions") {
            data = loadDataFromJSONFile(filename: "listTransactions")
            
        } else if urlString.contains("select") {
            data = loadDataFromJSONFile(filename: "selectVerificationType")
            
        } else if urlString.contains("deactivate") {
            data = loadDataFromJSONFile(filename: "deactivateCreditCard")
            
        } else if urlString.contains("reactivate") {
            data = loadDataFromJSONFile(filename: "reactivateCreditCard")
            
        } else if urlString.contains("verify") {
            data = loadDataFromJSONFile(filename: "verified")

        } else if urlString.contains("acceptTerms") {
            data = loadDataFromJSONFile(filename: "acceptTermsForCreditCard")
            
        } else if urlString.contains("declineTerms") {
            data = loadDataFromJSONFile(filename: "declineTerms")
            
        }  else if urlString.contains("creditCards") && request?.request?.httpMethod == "POST"  {
            data = loadDataFromJSONFile(filename: "createCreditCard")
            
        }  else if urlString.contains("creditCards?") && request?.request?.httpMethod == "GET" {
            data = loadDataFromJSONFile(filename: "listCreditCards")
            
        }  else if urlString.contains("creditCards") && request?.request?.httpMethod == "GET" {
            data = loadDataFromJSONFile(filename: "retrieveCreditCard")
            
        } else if urlString.contains("devices") && request?.request?.httpMethod == "POST" {
            data = loadDataFromJSONFile(filename: "createDevice")
            
        } else if urlString.contains("devices") && request?.request?.httpMethod == "GET" {
            data = loadDataFromJSONFile(filename: "listDevices")
            
        } else if urlString.contains("/config/encryptionKeys") {
            data = loadDataFromJSONFile(filename: "getEncryptionKeyJson")

        } else if urlString.contains("users") {
            data = loadDataFromJSONFile(filename: "getUser")
            
        } else if urlString.contains("issuers") {
            data = loadDataFromJSONFile(filename: "issuers")
            
        } else if urlString.contains("/oauth/authorize") {
            data = loadDataFromJSONFile(filename: "AuthorizationDetails")
            
        } else if urlString.contains("transactions") {
            data = loadDataFromJSONFile(filename: "listTransactions")
            
        } else if urlString.contains("resetDeviceTasks") {
            data = loadDataFromJSONFile(filename: "resetDeviceTask")

        } 

        if let data = data {
            completion(data, nil)
        } else {
            completion(nil, ErrorResponse.unhandledError(domain: RestClient.self))
        }

    }
    
    private func loadDataFromJSONFile(filename: String) -> String? {
        let bundle = Bundle(for: type(of: self))
        guard let filepath = bundle.path(forResource: filename, ofType: "json") else {
            return nil
        }
        
        let contents = try? String(contentsOfFile: filepath)
        return contents
        
    }
}
