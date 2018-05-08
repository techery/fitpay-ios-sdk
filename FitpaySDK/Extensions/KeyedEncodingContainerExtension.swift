//
//  KeyedEncodingContainerExtension.swift
//  FitpaySDK
//
//  Created by Illya Kyznetsov on 5/8/18.
//  Copyright © 2018 Fitpay. All rights reserved.
//

extension KeyedEncodingContainer {

    public mutating func encode<Transformer: EncodingContainerTransformer>(_ value: Transformer.Output?,
                                                                           forKey key: KeyedEncodingContainer.Key,
                                                                           transformer: Transformer) throws where Transformer.Input : Encodable {
        let transformed: Transformer.Input? = transformer.transform(value)
        try self.encode(transformed, forKey: key)
    }
}
