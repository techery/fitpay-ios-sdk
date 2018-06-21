# FitPay iOS SDK 

We are gradually moving content regarding consumption of this SDK to our [documentation](https://docs.fit-pay.com). The intended audience for this README is developers contributing to this repository.

[![GitHub license](https://img.shields.io/github/license/fitpay/fitpay-ios-sdk.svg)](https://github.com/fitpay/fitpay-ios-sdk/blob/develop/LICENSE)
[![Build Status](https://travis-ci.org/fitpay/fitpay-ios-sdk.svg?branch=develop)](https://travis-ci.org/fitpay/fitpay-ios-sdk)
[![Latest pod release](https://img.shields.io/cocoapods/v/FitpaySDK.svg)](https://cocoapods.org/pods/FitpaySDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Documentation coverage](docs/badge.svg)](docs/badge.svg)

## Running Tests From the Commandline
By default the tests will run in the iPhone 7 simulator.
```
./bin/test
```
To test on a different simulator, pass in a valid simulator same.
```
./bin/test "iPhone 5s"
```

## Card Scanning
By default the FitPay WebView utilizes a web based card scanning service which is currently being EOL'ed, that means the ability to scan a card during card entry now must be handled natively by the SDK implementation.  The SDK provides an interface `IFitPayCardScanner` where a scanning implementation can be provided.   An full working example using the [Card.IO](https://www.card.io/) utility can be seen in our [reference implementation](https://github.com/fitpay/Pagare_iOS_WV/).
 
## Logging
In order to remain flexible with the various mobile logging strategies, the SDK provides a mechanism to utilize custom logging implementations. For custom implementation there is protocol `LogsOutputProtocol` which should be implemented, and after that object of that protocol implementation should be added to logs ouput.

Code example:

```
        class ErrorPusherOutput: LogsOutputProtocol {
            func send(level: LogLevel, message: String, file: String, function: String, line: Int) {
                if level == .error {
                    print("Going to push next message:", message)
                    // code for pushing here
                }
            }
        }
        
        let log = FitpaySDKLogger.sharedInstance
        log.addOutput(output: ConsoleOutput())
        log.addOutput(output: ErrorPusherOutput())
        log.minLogLevel = .debug

```

# Migration from 0.x to 1.x

This content has been moved to our [documentation](https://docs.fit-pay.com/SDK/iOS/migration/)


# Contributing to the SDK
We welcome contributions to the SDK. For your first few contributions please fork the repo, make your changes and submit a pull request. Internally we branch off of develop, test, and PR-review the branch before merging to develop (moderately stable). Releases to Master happen less frequently, undergo more testing, and can be considered stable. For more information, please read:  [http://nvie.com/posts/a-successful-git-branching-model/](http://nvie.com/posts/a-successful-git-branching-model/)

# License
This code is licensed under the MIT license. More information can be found in the [LICENSE](LICENSE) file contained in this repository.

# Questions? Comments? Concerns?
Please contact [FitPay Support](https://support.fit-pay.com)


# Fit Pay Internal Instructions 
### Publishing Updated SDKs
* Please add a name to each release using the following convention: `FitPay SDK for iOS vX.X.X`
* Please also include notes using proper markdown about each major PR in the release.
* [How-to publish (deploy) a new version of the iOS FitPay SDK](https://fitpay.atlassian.net/wiki/spaces/ENG/pages/92798977/How-to+publish+deploy+a+new+version+of+the+iOS+FitPay+SDK)

