import Foundation

extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: Array<Any>.Type, array: Bool) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self, array: true) {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    mutating func decode<T>(_ type: Array<T>.Type, array: Bool) throws -> Array<T>? {
        var array: [T] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try decode(Bool.self) as? T {
                array.append(value)
            } else if let value = try decode(Double.self) as? T  {
                array.append(value)
            } else if let value = try decode(String.self) as? T  {
                array.append(value)
            } else if let nestedDictionary = try decode(Dictionary<String, Any>.self) as? T  {
                array.append(nestedDictionary)
            } else if let nestedArray = try decode(Array<Any>.self, array: true) as? T  {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
    
}
