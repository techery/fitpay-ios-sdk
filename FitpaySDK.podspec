Pod::Spec.new do |s|
  s.requires_arc = true
  s.name = 'FitpaySDK'
  s.version = '0.4.22'
  s.license = 'MIT'
  s.summary = 'Swift based library for the Fitpay Platform'
  s.homepage = 'https://github.com/fitpay/fitpay-ios-sdk'
  s.authors = { 'Fit Pay, Inc' => 'sdk@fit-pay.com' }
  s.source = { :git => 'https://github.com/fitpay/fitpay-ios-sdk.git', :tag => 'v0.4.22' }

  s.dependency 'Alamofire', '4.6.0'
  s.dependency 'ObjectMapper', '3.1.0'
  s.dependency 'AlamofireObjectMapper', '5.0.0'
  s.dependency 'JWTDecode', '2.1.1'
  s.dependency 'KeychainAccess', '3.1.0'
  s.dependency 'RxSwift', '4.1.2'

  s.ios.deployment_target = '9.0'
  s.source_files  = "{FitpaySDK,Common}/**/*.swift"


end
