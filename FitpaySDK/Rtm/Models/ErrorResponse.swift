//
//  ErrorResponse.swift
//  FitpaySDK
//
//  Created by Illya Kyznetsov on 5/8/18.
//  Copyright © 2018 Fitpay. All rights reserved.
//

open class ErrorResponse: NSError, Serializable {
    open let status: Int?
    open let created: Int?
    open let requestId: String?
    open let path: String?
    open let summary: String?
    open let messageDescription: String?
    private(set) open var message: String?
    private(set) open var details: String?

    enum CodingKeys: String, CodingKey {
        case status
        case created
        case requestId
        case path
        case summary
        case messageDescription = "description"
        case details
        case message
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(.status)
        created = try container.decode(.created)
        requestId = try container.decode(.requestId)
        path = try container.decode(.path)
        summary = try container.decode(.summary)
        messageDescription = try container.decode(.messageDescription)

        if let detailsJson: String = try container.decode(.details), let data = detailsJson.data(using: .utf8) {
            let dict: [String: Any]? = (try? JSONSerialization.jsonObject(with: data, options: []) as! [[String : Any]])?.first
            details = dict?["message"] as? String
        }

        if let messageJson: String = try container.decode(.message), let data = messageJson.data(using: .utf8) {
            let dict: [String: Any]? = (try? JSONSerialization.jsonObject(with: data, options: []) as! [[String : Any]])?.first
            message = dict?["message"] as? String
        }
        super.init(domain: "", code: status ?? 0, userInfo: [NSLocalizedDescriptionKey : messageDescription ?? ""])
    }

    init(domain: AnyClass, errorCode: Int?, errorMessage: String?) {
        status = errorCode
        created = nil
        requestId = nil
        path = nil
        summary = nil
        messageDescription = errorMessage
        super.init(domain: "", code: errorCode ?? 0, userInfo: [NSLocalizedDescriptionKey : errorMessage ?? ""])
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func unhandledError(domain: AnyClass) -> ErrorResponse {
        return ErrorResponse(domain: domain, errorCode: 0, errorMessage: "Unhandled error")
    }

    class func clientUrlError(domain: AnyClass, client: RestClient?, url: String?, resource: String) -> ErrorResponse? {
        if let _ = client
        {
            if let _ = url
            {
                return nil
            }
            else
            {
                return ErrorResponse(domain: domain, errorCode: 0, errorMessage: "Failed to retrieve url for resource '\(resource)'")
            }
        }
        else
        {
            return ErrorResponse(domain: domain, errorCode: 0, errorMessage: "\(RestClient.self) is not set.")
        }
    }

}
