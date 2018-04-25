//
//  Codable+JSON.swift
//  FitpaySDK
//
//  Created by Illya Kyznetsov on 4/11/18.
//  Copyright © 2018 Fitpay. All rights reserved.
//

protocol Serializable: Codable {
}

extension Serializable {
    func toJSONString() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        return String(data: jsonData, encoding: .utf8)!
    }

    func toJSON() -> [String: Any]? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options : .allowFragments) as! [String: Any]
        return jsonDictionary
    }

    init(_ any: Any?) throws {
        var data =  Data()

        if let stringJson = any as? String, let stringData = stringJson.data(using: .utf8) {
            let jsonArray = try JSONSerialization.jsonObject(with: stringData, options : .allowFragments) as! [String: Any]
            data = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
        } else if let jSONObject = any {
            let jSONObjectData = try JSONSerialization.data(withJSONObject: jSONObject, options: .prettyPrinted)
            data = jSONObjectData
        }

        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

public extension KeyedDecodingContainer {
    public func decode<Transformer: DecodingContainerTransformer>(_ key: KeyedDecodingContainer.Key,
        
                                                                  transformer: Transformer) throws -> Transformer.Output? where Transformer.Input : Decodable {

        do {
             let decoded: Transformer.Input? = try self.decode(key)
             return transformer.transform(decoded)
        } catch {
            return nil
        }
    }

    public func decode<T>(_ key: KeyedDecodingContainer.Key) throws -> T? where T : Decodable {
        do {
            let object = try self.decodeIfPresent(T.self, forKey: key)
            return object
        } catch {
            return nil
        }
    }
}

public extension KeyedEncodingContainer {

    public mutating func encode<Transformer: EncodingContainerTransformer>(_ value: Transformer.Output?,
                                                                           forKey key: KeyedEncodingContainer.Key,
                                                                           transformer: Transformer) throws where Transformer.Input : Encodable {
        let transformed: Transformer.Input? = transformer.transform(value)
        try self.encode(transformed, forKey: key)
    }
}

struct JSONCodingKeys: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

public extension KeyedDecodingContainer {

    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
     do {
            let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
            let object = try container.decode(type)
            return object
        } catch {
            return nil
        }
    }

    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        do {
            var container = try self.nestedUnkeyedContainer(forKey: key)
            let object = try container.decode(type)
            return object
        } catch {
            return nil
        }
    }

    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

public extension UnkeyedDecodingContainer {

    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
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
            } else if let nestedArray = try? decode(Array<Any>.self) {
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

public protocol DecodingContainerTransformer {
    associatedtype Input
    associatedtype Output
    func transform(_ decoded: Input?) -> Output?
}

public protocol EncodingContainerTransformer {
    associatedtype Input
    associatedtype Output
    func transform(_ encoded: Output?) -> Input?
}

public typealias CodingContainerTransformer = DecodingContainerTransformer & EncodingContainerTransformer
