extension KeyedEncodingContainer {

    mutating func encode<Transformer: EncodingContainerTransformer>(_ value: Transformer.Output?,
                                                                           forKey key: KeyedEncodingContainer.Key,
                                                                           transformer: Transformer) throws where Transformer.Input : Encodable {
        let transformed: Transformer.Input? = transformer.transform(value)
        try self.encode(transformed, forKey: key)
    }
}
