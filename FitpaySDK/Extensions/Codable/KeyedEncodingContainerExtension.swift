extension KeyedEncodingContainer {
    
    mutating func encode<Transformer: EncodingContainerTransformer>(_ value: Transformer.Output?,
                                                                    forKey key: KeyedEncodingContainer.Key,
                                                                    transformer: Transformer) throws where Transformer.Input: Encodable {
        let transformed: Transformer.Input? = transformer.transform(value)
        try self.encode(transformed, forKey: key)
    }
    
    mutating func encode(_ value: [String: Any]?, forKey key: KeyedEncodingContainer.Key) throws {
        guard let value = value else { return }
        
        for dictionaryKey in value.keys {
            if let boolValue = value[dictionaryKey] as? Bool {
                try self.encode([dictionaryKey: boolValue], forKey: key)
                
            } else if let stringValue = value[dictionaryKey] as? String {
                try self.encode([dictionaryKey: stringValue], forKey: key)
                
            } else if let intValue = value[dictionaryKey] as? Int  {
                try self.encode([dictionaryKey: intValue], forKey: key)
                
            } else if let doubleValue = value[dictionaryKey] as? Double  {
                try self.encode([dictionaryKey: doubleValue], forKey: key)
                
            } else if let nestedDictionary = value[dictionaryKey] as? [String: Any]  {
                try self.encode([dictionaryKey: nestedDictionary], forKey: key)
            }
        }
    }
    
}
