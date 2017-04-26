//
//  IntExtensions.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 13.04.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation

func hex<T:Integer>( v:T) -> String {
    var v = v
    var s = ""
    for _ in 0..<MemoryLayout<T>.size * 2 {
        s = String(format: "%X", (v & 0xf).toIntMax()) + s
        v /= 16
    }
    
    var firstZeroCounter = 0
    for char in s.characters {
        if char != "0" {
            break
        }
        firstZeroCounter += 1
    }
    
    if firstZeroCounter > 0 {
        let range = s.startIndex..<s.index(s.startIndex, offsetBy: firstZeroCounter)
        s.removeSubrange(range)
    }
    
    return s
}

extension Integer {
    func hex(preferableLength: Int) -> String {
        var s = FitpaySDK.hex(v: self)
        let lenght = s.characters.count
        if lenght < preferableLength {
            for _ in 0..<preferableLength - lenght {
                s = "0" + s
            }
        }
        
        return s
    }
}
