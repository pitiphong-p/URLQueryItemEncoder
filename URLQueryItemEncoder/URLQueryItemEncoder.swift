//
//  URLQueryItemEncoder.swift
//  URLQueryItemEncoder
//
//  Created by Pitiphong Phongpattranont on 23/10/2017.
//  Copyright © 2017 Pitiphong Phongpattranont. All rights reserved.
//

import Foundation


let iso8601Formatter: Formatter = {
  if #available(iOS 10.0, *) {
    return ISO8601DateFormatter()
  } else {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return formatter
  }
}()

public class URLQueryItemEncoder {
  public enum ArrayIndexEncodingStrategy {
    case emptySquareBrackets
    case index
  }
  
  fileprivate(set) public var codingPath: [CodingKey] = []
  fileprivate var items: [URLQueryItem] = []
  public var arrayIndexEncodingStrategy = ArrayIndexEncodingStrategy.index
  public init() {}
  
  public func encode(_ value: Encodable) throws -> [URLQueryItem] {
    items = []
    try value.encode(to: self)
    return items
  }
}

extension Array where Element == CodingKey {
  fileprivate func queryItemKeyForKey(_ key: CodingKey) -> String {
    let keysPath = self + [key]
    return keysPath.queryItemKey
  }
  
  fileprivate var queryItemKey: String {
    guard !isEmpty else { return "" }
    var keysPath = self
    let firstKey = keysPath.removeFirst()
    let tailCodingKeyString = keysPath.reduce(into: "", {
      $0 += "[\($1.stringValue)]"
    })
    
    return firstKey.stringValue + tailCodingKeyString
  }
}

private struct URLQueryItemArrayElementKey: CodingKey {
  let encodingStrategy: URLQueryItemEncoder.ArrayIndexEncodingStrategy
  
  fileprivate var stringValue: String {
    switch encodingStrategy {
    case .emptySquareBrackets:
      return ""
    case .index:
      return String(index)
    }
  }
  
  fileprivate init(index: Int, encodingStrategy: URLQueryItemEncoder.ArrayIndexEncodingStrategy) {
    self.index = index
    self.encodingStrategy = encodingStrategy
  }
  
  init?(stringValue: String) {
    guard let index = Int(stringValue) else { return nil }
    self.index = index
    encodingStrategy = .index
  }
  let index: Int
  var intValue: Int? {
    return index
  }
  init?(intValue: Int) {
    self.index = intValue
    encodingStrategy = .index
  }
}


extension URLQueryItemEncoder {
  private func pushNil(forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: nil))
  }
  
  private func push(_ value: DateComponents, forKey codingPath: [CodingKey]) throws {
    guard (value.calendar?.identifier ?? Calendar.current.identifier) == .gregorian,
      let year = value.year, let month = value.month, let day = value.day else {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid date components"))
    }
    
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(year)-\(month)-\(day)"))
  }
  
  private func push(_ value: String, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: value))
  }
  
  private func push(_ value: Date, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: iso8601Formatter.string(for: value)))
  }
  
  private func push(_ value: Bool, forKey codingPath: [CodingKey]) throws {
    let boolValue: String
    switch value {
    case true:
      boolValue = "true"
    case false:
      boolValue = "false"
    }
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: boolValue))
  }
  
  private func push(_ value: Int, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: Int8, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: Int16, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: Int32, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: Int64, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: UInt, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: UInt8, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: UInt16, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: UInt32, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: UInt64, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: Double, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: Float, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: "\(value)"))
  }
  
  private func push(_ value: URL, forKey codingPath: [CodingKey]) throws {
    items.append(URLQueryItem(name: codingPath.queryItemKey, value: value.absoluteString))
  }
  
  private func push<T: Encodable>(_ value: T?, forKey codingPath: [CodingKey]) throws {
    self.codingPath = codingPath
    switch value {
    case let value as String:
      try push(value, forKey: codingPath)
      
    case let value as Bool:
      try push(value, forKey: codingPath)
    case let value as Int:
      try push(value, forKey: codingPath)
    case let value as Int8:
      try push(value, forKey: codingPath)
    case let value as Int16:
      try push(value, forKey: codingPath)
    case let value as Int32:
      try push(value, forKey: codingPath)
    case let value as Int64:
      try push(value, forKey: codingPath)
    case let value as UInt:
      try push(value, forKey: codingPath)
    case let value as UInt8:
      try push(value, forKey: codingPath)
    case let value as UInt16:
      try push(value, forKey: codingPath)
    case let value as UInt32:
      try push(value, forKey: codingPath)
    case let value as UInt64:
      try push(value, forKey: codingPath)
      
    case let value as Double:
      try push(value, forKey: codingPath)
    case let value as Float:
      try push(value, forKey: codingPath)
      
    case let value as Date:
      try push(value, forKey: codingPath)
    case let value as DateComponents:
      try push(value, forKey: codingPath)
      
    case let value as URL:
      try push(value, forKey: codingPath)
      
    case nil:
      try pushNil(forKey: codingPath)
      
    default:
      try value.encode(to: self)
    }
  }
}


extension URLQueryItemEncoder: Encoder {
  public var userInfo: [CodingUserInfoKey : Any] { return [:] }
  
  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    return KeyedEncodingContainer(KeyedContainer<Key>(encoder: self, codingPath: codingPath))
  }
  
  public func unkeyedContainer() -> UnkeyedEncodingContainer {
    return UnkeyedContanier(encoder: self, codingPath: codingPath)
  }
  
  public func singleValueContainer() -> SingleValueEncodingContainer {
    return SingleValueContanier(encoder: self, codingPath: codingPath)
  }
}

extension URLQueryItemEncoder {
  fileprivate struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: URLQueryItemEncoder
    let codingPath: [CodingKey]
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
      let codingPath = self.codingPath + [key]
      encoder.codingPath = codingPath
      defer { encoder.codingPath.removeLast() }
      try encoder.push(value, forKey: codingPath)
    }
    
    func encodeNil(forKey key: Key) throws {
      let codingPath = self.codingPath + [key]
      encoder.codingPath = codingPath
      defer { encoder.codingPath.removeLast() }
      try encoder.pushNil(forKey: codingPath)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
      return KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder, codingPath: codingPath + [key]))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
      return UnkeyedContanier(encoder: encoder, codingPath: codingPath + [key])
    }
    
    func superEncoder() -> Encoder {
      return URLQueryItemReferencingEncoder(encoder: encoder, codingPath: codingPath)
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
      return URLQueryItemReferencingEncoder(encoder: encoder, codingPath: codingPath + [key])
    }
  }
  
  fileprivate class UnkeyedContanier: UnkeyedEncodingContainer {
    var encoder: URLQueryItemEncoder
    
    var codingPath: [CodingKey]
    
    var count: Int {
      return encodedItemsCount
    }
    
    var encodedItemsCount: Int = 0
    
    fileprivate init(encoder: URLQueryItemEncoder, codingPath: [CodingKey], encodedItemsCount: Int = 0) {
      self.encoder = encoder
      self.codingPath = codingPath
      self.encodedItemsCount = encodedItemsCount
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
      codingPath.append(
        URLQueryItemArrayElementKey(index: encodedItemsCount, encodingStrategy: encoder.arrayIndexEncodingStrategy)
      )
      defer { codingPath.removeLast() }
      return KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder, codingPath: codingPath))
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
      codingPath.append(
        URLQueryItemArrayElementKey(index: encodedItemsCount, encodingStrategy: encoder.arrayIndexEncodingStrategy)
      )
      defer { codingPath.removeLast() }
      return self
    }
    
    func superEncoder() -> Encoder {
      codingPath.append(URLQueryItemArrayElementKey(index: encodedItemsCount, encodingStrategy: encoder.arrayIndexEncodingStrategy))
      defer { codingPath.removeLast() }
      return UnkeyedURLQueryItemReferencingEncoder(encoder: encoder, codingPath: codingPath, referencing: self)
    }
    
    func encodeNil() throws {
      codingPath.append(
        URLQueryItemArrayElementKey(index: encodedItemsCount, encodingStrategy: encoder.arrayIndexEncodingStrategy)
      )
      defer { codingPath.removeLast() }
      try encoder.pushNil(forKey: codingPath)
      encodedItemsCount += 1
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
      codingPath.append(
        URLQueryItemArrayElementKey(index: encodedItemsCount, encodingStrategy: encoder.arrayIndexEncodingStrategy)
      )
      defer { codingPath.removeLast() }
      try encoder.push(value, forKey: codingPath)
      encodedItemsCount += 1
    }
  }
  
  fileprivate struct SingleValueContanier: SingleValueEncodingContainer {
    let encoder: URLQueryItemEncoder
    var codingPath: [CodingKey]
    
    fileprivate init(encoder: URLQueryItemEncoder, codingPath: [CodingKey]) {
      self.encoder = encoder
      self.codingPath = codingPath
    }
    
    mutating func encodeNil() throws {
      encoder.items.append(URLQueryItem(name: codingPath.queryItemKey, value: nil))
    }
    
    public func encode(_ value: Bool) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: Int) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: Int8) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: Int16) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: Int32) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: Int64) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: UInt) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: UInt8) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: UInt16) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: UInt32) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: UInt64) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: String) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: Float) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    public func encode(_ value: Double) throws {
      try encoder.push(value, forKey: codingPath)
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
      encoder.codingPath = self.codingPath
      try encoder.push(value, forKey: codingPath)
    }
  }
}

fileprivate class URLQueryItemReferencingEncoder: URLQueryItemEncoder {
  fileprivate let encoder: URLQueryItemEncoder
  
  init(encoder: URLQueryItemEncoder, codingPath: [CodingKey]) {
    self.encoder = encoder
    super.init()
    self.codingPath = codingPath
    self.arrayIndexEncodingStrategy = encoder.arrayIndexEncodingStrategy
  }
  
  deinit {
    self.encoder.items.append(contentsOf: self.items)
  }
}

fileprivate class UnkeyedURLQueryItemReferencingEncoder: URLQueryItemReferencingEncoder {
  var referencedUnkeyedContainer: UnkeyedContanier
  
  init(encoder: URLQueryItemEncoder, codingPath: [CodingKey], referencing: UnkeyedContanier) {
    referencedUnkeyedContainer = referencing
    super.init(encoder: encoder, codingPath: codingPath)
  }
  
  deinit {
    referencedUnkeyedContainer.encodedItemsCount += items.count
  }
}



