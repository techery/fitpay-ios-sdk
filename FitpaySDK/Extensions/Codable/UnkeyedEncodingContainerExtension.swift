import Foundation

extension UnkeyedEncodingContainer {

    mutating func encodeJSONArray(_ value: Array<Any>) throws {
        try value.enumerated().forEach { (index, value) in
            switch value {
            case let value as Bool:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as String:
                try encode(value)
            case let value as Double:
                try encode(value)
            case Optional<Any>.none:
                try encodeNil()
            default:
                let keys = JSONCodingKeys(intValue: index).map({ [ $0 ] }) ?? []
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + keys, debugDescription: "Invalid JSON value"))
            }
        }
    }
    
    mutating func encodeJSONDictionary(_ value: Dictionary<String, Any>) throws {
        var nestedContainer = self.nestedContainer(keyedBy: JSONCodingKeys.self)
        try nestedContainer.encodeJSONDictionary(value)
    }

}
