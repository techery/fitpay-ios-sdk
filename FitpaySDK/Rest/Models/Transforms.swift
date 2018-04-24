//
//  Transforms.swift
//  FitpaySDK
//
//  Created by Jakub Borowski on 6/2/16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import Foundation

import ObjectMapper

internal class NSTimeIntervalTransform: TransformType
{
    typealias Object = TimeInterval
    typealias JSON = Int64
    
    init() {}
    
    func transformFromJSON(_ value: Any?) -> Double? {
        if let timeInt = value as? NSNumber {
            return TimeInterval(timeInt.int64Value/1000)
        }
        
        if let timeStr = value as? String {
            return TimeInterval(atof(timeStr)/1000)
        }
        return nil
    }
    
    func transformToJSON(_ value: TimeInterval?) -> Int64? {
        if let epoch = value {
            let timeInt = Int64(epoch*1000)
            return timeInt
        }
        return nil
    }
}

internal class DecimalNumberTransform: TransformType {
    public typealias Object = NSDecimalNumber
    public typealias JSON = String
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> NSDecimalNumber? {
        if let string = value as? String {
            return NSDecimalNumber(string: string)
        } else if let number = value as? NSNumber {
            let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 3, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
            return NSDecimalNumber(decimal: number.decimalValue).rounding(accordingToBehavior: handler)
        } else if let double = value as? Double {
            return NSDecimalNumber(floatLiteral: double)
        }
        return nil
    }
    
    public func transformToJSON(_ value: NSDecimalNumber?) -> String? {
        guard let value = value else { return nil }
        return value.description
    }
}

internal class NSTimeIntervalTypeTransform: CodingContainerTransformer {
    typealias Output = TimeInterval
    typealias Input = Any

    func transform(_ decoded: Input?) -> Output? {
        if let timeInt = decoded as? NSNumber {
            return TimeInterval(timeInt.int64Value/1000)
        }

        if let timeStr = decoded as? String {
            return TimeInterval(atof(timeStr)/1000)
        }
        return nil
    }

    func transform(_ encoded: Output?) -> Input? {
        if let epoch = encoded {
            let timeInt = Int64(epoch*1000)
            return timeInt as NSTimeIntervalTypeTransform.Input
        }
        return nil
    }
}

internal class DecimalNumberTypeTransform: CodingContainerTransformer {
    typealias Output = NSDecimalNumber
    typealias Input = Any

    func transform(_ decoded: Input?) -> Output? {
        if let string = decoded as? String {
            return NSDecimalNumber(string: string)
        } else if let number = decoded as? NSNumber {
            let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 3, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
            return NSDecimalNumber(decimal: number.decimalValue).rounding(accordingToBehavior: handler)
        } else if let double = decoded as? Double {
            return NSDecimalNumber(floatLiteral: double)
        }
        return nil
    }

    func transform(_ encoded: Output?) -> Input? {
        guard let value = encoded else { return nil }
        return value.description
    }
}

internal class CustomDateFormatTransform: CodingContainerTransformer {
    typealias Output = Date
    typealias Input = String

    let dateFormatter: DateFormatter

    public init(formatString: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = formatString

        self.dateFormatter = formatter
    }

    func transform(_ decoded: Input?) -> Output? {
        if let dateString = decoded {
            return dateFormatter.date(from: dateString)
        }
        return nil
    }

    func transform(_ encoded: Output?) -> Input? {
        if let date = encoded {
            return dateFormatter.string(from: date)
        }
        return nil
    }
}
