import UIKit
@testable import FitpaySDK

public class Request {

    var request:String?
    var response: Response!

    init (request:String){
        self.request = request
    }

    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments, completionHandler: (Request) -> Void) {

        completionHandler(self)
    }
}

public struct Response {
    var data: HTTPURLResponse?
    var json: String?
    var error: Error?
}

