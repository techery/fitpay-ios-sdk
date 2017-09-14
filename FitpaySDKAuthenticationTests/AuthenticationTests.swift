//
//  AuthenticationTests.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 12.09.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import WebKit
import XCTest
import RxSwift

@testable import FitpaySDK

class AuthenticationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        if shouldLoadEnvironmentVariables {
            sdkConfig = FitpaySDKConfiguration(clientId:clientId, redirectUri:redirectUri, baseAuthURL: AUTHORIZE_BASE_URL, baseAPIURL: API_BASE_URL)
            
            if let error = sdkConfig.loadEnvironmentVariables() {
                print("Can't load config from environment. Error: \(error)")
            } else {
                clientId = sdkConfig.clientId
            }
        } else {
            sdkConfig = FitpaySDKConfiguration(clientId:clientId, redirectUri:redirectUri, baseAuthURL: baseAuthUrl, baseAPIURL: baseApiUrl)
            clientId = sdkConfig.clientId
        }
        
        self.session = RestSession(configuration: sdkConfig)
        self.client = RestClient(session: self.session!)
        self.testHelper = TestHelpers(clientId: clientId, redirectUri: sdkConfig.redirectUri, session: self.session, client: self.client)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testProgrammaticAuthorization() {
        let expectation = super.expectation(description: "")
        self.email = TestHelpers.randomEmail()
        self.testHelper.createUser(expectation, email: self.email, pin: self.password) { (user) in
            
            // retrieving token here
            self.session.login(username: self.email, password: self.password, completion: { (error) in
                
                XCTAssertNil(error, "Can't login. Error: \(error!)")
                guard error == nil else {
                    expectation.fulfill()
                    return
                }
                
                // here is our token
                XCTAssertNotNil(self.session.accessToken)
                
                expectation.fulfill()
            })
        }
        
        super.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLaunchWebViewWithToken() {
        let expectation = super.expectation(description: "")
        let wvWrapper = self.getWVWrapper()
        self.email = TestHelpers.randomEmail()
        self.testHelper.createAndLoginUser(expectation, email: self.email, pin: self.password) { (user) in
            
            // here is our token
            XCTAssertNotNil(self.session.accessToken)
            
            let rtmConfig = RtmConfig(clientId: self.clientId,
                                      redirectUri: self.sdkConfig.webViewURL,
                                      userEmail: self.email,
                                      deviceInfo: MockPaymentDeviceConnector(paymentDevice: PaymentDevice()).deviceInfo(),
                                      hasAccount: true)
            rtmConfig.customCSSUrl = "https://fitpaycss.github.io/pagare.css"
            rtmConfig.accessToken = self.session.accessToken
            rtmConfig.useWebCardScanner = false

            self.wvConfig = WvConfig(paymentDevice: PaymentDevice(), rtmConfig: rtmConfig)
            self.wvConfig.demoModeEnabled = true
            
            UIApplication.shared.keyWindow!.addSubview(wvWrapper.webView)

            self.wvConfig!.setWebView(wvWrapper.webView)
            wvWrapper.webView.load(self.wvConfig!.wvRequest())

            wvWrapper.waitUnitWalletScreenWillBeLoadded().subscribe { event in
                switch event {
                case .completed:
                    expectation.fulfill()
                    break
                default: break
                }
                
                user?.deleteUser({ (_) in
                })
            }.disposed(by: self.disposeBag)
        }
        
        super.waitForExpectations(timeout: 200, handler: nil)

    }
    
    func testLaunchWebViewForAccountCreating() {
        let expectation = super.expectation(description: "")
        let wvWrapper = self.getWVWrapper()
        self.email = TestHelpers.randomEmail()
        
        
        let rtmConfig = RtmConfig(clientId: self.clientId,
                                  redirectUri: self.sdkConfig.webViewURL,
                                  userEmail: self.email,
                                  deviceInfo: MockPaymentDeviceConnector(paymentDevice: PaymentDevice()).deviceInfo(),
                                  hasAccount: false)
        rtmConfig.customCSSUrl = "https://fitpaycss.github.io/pagare.css"
        rtmConfig.useWebCardScanner = false
        
        self.wvConfig = WvConfig(paymentDevice: PaymentDevice(), rtmConfig: rtmConfig)
        self.wvConfig.demoModeEnabled = true
        
        UIApplication.shared.keyWindow!.addSubview(wvWrapper.webView)
        
        self.wvConfig!.setWebView(wvWrapper.webView)
        wvWrapper.webView.load(self.wvConfig!.wvRequest())
        
        wvWrapper.waitUnitNewAccountScreenWillBeLoadded().subscribe { event in
            switch event {
            case .completed:
                expectation.fulfill()
                break
            default: break
            }
            wvWrapper.webView.removeFromSuperview()
            
        }.disposed(by: self.disposeBag)
        
        super.waitForExpectations(timeout: 200, handler: nil)
    }
    
    func testLaunchWebViewForLoginWithPIN() {
        let expectation = super.expectation(description: "")
        let wvWrapper = self.getWVWrapper()
        self.email = TestHelpers.randomEmail()
        self.testHelper.createAndLoginUser(expectation, email: self.email, pin: self.password) { (user) in
            
            // here is our token
            XCTAssertNotNil(self.session.accessToken)
            
            let rtmConfig = RtmConfig(clientId: self.clientId,
                                      redirectUri: self.sdkConfig.webViewURL,
                                      userEmail: self.email,
                                      deviceInfo: MockPaymentDeviceConnector(paymentDevice: PaymentDevice()).deviceInfo(),
                                      hasAccount: true)
            rtmConfig.customCSSUrl = "https://fitpaycss.github.io/pagare.css"
            rtmConfig.useWebCardScanner = false
            
            self.wvConfig = WvConfig(paymentDevice: PaymentDevice(), rtmConfig: rtmConfig)
            self.wvConfig.demoModeEnabled = true
            
            UIApplication.shared.keyWindow!.addSubview(wvWrapper.webView)
            
            self.wvConfig!.setWebView(wvWrapper.webView)
            wvWrapper.webView.load(self.wvConfig!.wvRequest())
            
            wvWrapper.waitUnitPINScreenWillBeLoadded().subscribe { event in
                switch event {
                case .completed:
                    expectation.fulfill()
                    break
                default: break
                }
                wvWrapper.webView.removeFromSuperview()
                
                user?.deleteUser({ (_) in
                })
            }.disposed(by: self.disposeBag)
        }
        
        super.waitForExpectations(timeout: 200, handler: nil)

    }
    
    fileprivate func getWVWrapper() -> WebViewWrapper {
        return WebViewWrapper(webView: WKWebView(frame: CGRect(x: 0, y: 20, width: UIApplication.shared.keyWindow!.bounds.width, height: UIApplication.shared.keyWindow!.bounds.height - 20)))
    }
    
    fileprivate var clientId = "fp_webapp_pJkVp2Rl"
    fileprivate let redirectUri = "https://webapp.fit-pay.com"
    fileprivate var email: String!
    fileprivate let password = "1029"
    fileprivate let shouldLoadEnvironmentVariables = true
    
    fileprivate var wvConfig: WvConfig!
    fileprivate var sdkConfig: FitpaySDKConfiguration!

    
    // if shouldLoadEnvironmentVariables == false then we will use next urls:
    fileprivate let baseAuthUrl = "https://some.url"
    fileprivate let baseApiUrl = "https://some.url/api"
    
    fileprivate var session:RestSession!
    fileprivate var client:RestClient!
    fileprivate var testHelper:TestHelpers!
    
    fileprivate var disposeBag = DisposeBag()
}
