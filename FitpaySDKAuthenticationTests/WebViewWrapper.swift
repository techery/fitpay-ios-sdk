//
//  WebViewWrapper.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 12.09.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import WebKit
import RxSwift

class WebViewWrapper {
    private(set) var webView: WKWebView
    
    func waitUnitWalletScreenWillBeLoadded() -> Observable<Void> {
        return waitUntilCompletionReturnsTrue(completion: isOnWalletScreen)
    }
    
    func waitUnitNewAccountScreenWillBeLoadded() -> Observable<Void> {
        return waitUntilCompletionReturnsTrue(completion: isOnNewAccountScreen)
    }
    
    func waitUnitPINScreenWillBeLoadded() -> Observable<Void> {
        return waitUntilCompletionReturnsTrue(completion: isOnPINScreen)
    }

    init(webView: WKWebView) {
        self.webView = webView
    }
    
    fileprivate func waitUntilCompletionReturnsTrue(completion: @escaping (_ completion: @escaping (Bool) -> Void) -> ()) -> Observable<Void> {
        return Observable<Void>.create { (observer) in
            completion { (isTrue) in
                enum err: Error {
                    case wrongResponse
                }
                
                if isTrue {
                    observer.onNext()
                    observer.onCompleted()
                } else {
                    observer.onError(err.wrongResponse)
                }
            }
            
            return Disposables.create()
            }.retryWhen { some in
                return some.delay(1, scheduler: MainScheduler.instance)
        }
    }
    
    fileprivate func isOnWalletScreen(completion: @escaping (Bool) -> Void) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            guard let htmlString = html as? String else {
                completion(false)
                return
            }
            
            completion(htmlString.contains("Your Wallet is Empty"))
        }
    }
    
    fileprivate func isOnNewAccountScreen(completion: @escaping (Bool) -> Void) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            guard let htmlString = html as? String else {
                completion(false)
                return
            }
            
            print(htmlString)
            
            completion(htmlString.contains("I already have a PIN"))
        }
    }
    
    fileprivate func isOnPINScreen(completion: @escaping (Bool) -> Void) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            guard let htmlString = html as? String else {
                completion(false)
                return
            }
            
            print(htmlString)
            
            completion(htmlString.contains("Enter Security PIN"))
        }
    }

}
