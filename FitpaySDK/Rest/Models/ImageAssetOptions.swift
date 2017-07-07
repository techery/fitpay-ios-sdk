//
//  ImageAssetOptions.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 07.07.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation

public protocol AssetOption {
    var urlKey: String { get }
    var urlValue: String { get }
}

public enum ImageAssetOption: AssetOption {
    case width(Int)
    case height(Int)
    case embossedText(String)
    case foregroundColor(String)
    case fontScale(Int)
    case textPositionXScale(Float)
    case textPositionYScale(Float)
    case fontName(String)
    case fontBold(Bool)
    
    public var urlKey: String {
        switch self {
        case .width:
            return "w"
        case .height:
            return "h"
        case .embossedText:
            return "embossedText"
        case .foregroundColor:
            return "foregroundColor"
        case .fontScale:
            return "fontScale"
        case .textPositionXScale:
            return "textPositionXScale"
        case .textPositionYScale:
            return "textPositionYScale"
        case .fontName:
            return "fontName"
        case .fontBold:
            return "fontBold"
        }
    }
    
    public var urlValue: String {
        switch self {
        case .width(let value):
            return String(value)
        case .height(let value):
            return String(value)
        case .embossedText(let value):
            return value
        case .foregroundColor(let value):
            return value
        case .fontScale(let value):
            return String(value)
        case .textPositionXScale(let value):
            return String(value)
        case .textPositionYScale(let value):
            return String(value)
        case .fontName(let value):
            return value
        case .fontBold(let value):
            return String(value)
        }
    }
}
