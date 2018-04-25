//
//  Transforms.swift
//  FitpaySDK
//
//  Created by Jakub Borowski on 6/2/16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import Foundation

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
