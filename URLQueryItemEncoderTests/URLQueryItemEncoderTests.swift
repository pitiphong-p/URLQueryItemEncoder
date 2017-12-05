//
//  URLQueryItemEncoderTests.swift
//  URLQueryItemEncoderTests
//
//  Created by Pitiphong Phongpattranont on 25/10/2017.
//  Copyright © 2017 Pitiphong Phongpattranont. All rights reserved.
//

import XCTest
@testable import URLQueryItemEncoder

// This is a special protocol to support decoding metadata type.
// This situation will be greatly improved when `Conditional Conformance` feature land in Swift
public protocol JSONType: Decodable {
  var jsonValue: Any { get }
}

extension Int: JSONType {
  public var jsonValue: Any { return self }
}
extension String: JSONType {
  public var jsonValue: Any { return self }
}
extension Double: JSONType {
  public var jsonValue: Any { return self }
}
extension Bool: JSONType {
  public var jsonValue: Any { return self }
}

public struct AnyJSONType: JSONType {
  public let jsonValue: Any
  
  public init(_ jsonValue: Any) {
    self.jsonValue = jsonValue
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    
    if let intValue = try? container.decode(Int.self) {
      jsonValue = intValue
    } else if let stringValue = try? container.decode(String.self) {
      jsonValue = stringValue
    } else if let boolValue = try? container.decode(Bool.self) {
      jsonValue = boolValue
    } else if let doubleValue = try? container.decode(Double.self) {
      jsonValue = doubleValue
    } else if let doubleValue = try? container.decode(Array<AnyJSONType>.self) {
      jsonValue = doubleValue
    } else if let doubleValue = try? container.decode(Dictionary<String, AnyJSONType>.self) {
      jsonValue = doubleValue
    } else {
      throw DecodingError.typeMismatch(JSONType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON tyep"))
    }
  }
}


extension AnyJSONType: Encodable {
  public func encode(to encoder: Encoder) throws {
    switch jsonValue {
    case Optional<Any>.none:
      var container = encoder.singleValueContainer()
      try container.encodeNil()
    case let value as Int:
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case let value as Bool:
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case let value as Double:
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case let value as String:
      var container = encoder.singleValueContainer()
      try container.encode(value)
    case let value as Date:
      var container = encoder.singleValueContainer()
      try container.encode(iso8601Formatter.string(from: value))
    case let value as [Encodable]:
      var container = encoder.unkeyedContainer()
      try container.encode(contentsOf: value.map(AnyJSONType.init))
    case let value as Dictionary<String, Encodable>:
      var container = encoder.container(keyedBy: AnyJSONAttributeEncodingKey.self)
      let sortedValuesByKey = value.sorted(by: { (first, second) -> Bool in
        return first.key < second.key
      })
      for (key, value) in sortedValuesByKey {
        let value = AnyJSONType(value)
        try container.encode(value, forKey: AnyJSONAttributeEncodingKey(stringValue: key))
      }
    default: fatalError()
    }
  }
}

fileprivate struct AnyJSONAttributeEncodingKey: CodingKey {
  let stringValue: String
  init?(intValue: Int) { return nil }
  var intValue: Int? { return nil }
  init(stringValue: String) { self.stringValue = stringValue }
}


class URLQueryItemEncoderTests: XCTestCase {
  func testEncodeBasic() throws {
    let values = AnyJSONType(["hello": "world"])
    let encoder = URLQueryItemEncoder()
    let result = try encoder.encode(values)
    
    XCTAssertEqual(1, result.count)
    XCTAssertEqual("hello", result[0].name)
    XCTAssertEqual("world", result[0].value)
  }
  
  func testEncodeMultipleTypes() throws {
    let values = AnyJSONType([
      "0hello": "world",
      "1num": 42,
      "2number": 64,
      "3long": 1234123412341234,
      "4bool": false,
      "5boolean": true,
      "6date": Date(timeIntervalSince1970: 0),
      "7nil": String?.none as Optional<String>,
      ] as [String: Optional<Any>])
    
    let encoder = URLQueryItemEncoder()
    let result = try encoder.encode(values).map({ (query) in query.value ?? "$*nil*$" })
    XCTAssertEqual(8, result.count)
    XCTAssertEqual(result, [
      "world",
      "42",
      "64",
      "1234123412341234",
      "false",
      "true",
      "1970-01-01T00:00:00.000Z",
      "$*nil*$",
      ])
  }
  
  func testEncodeNestedWithEmptyIndexStrategy() throws {
    let values = AnyJSONType([
      "0outer": "normal",
      "1nested": ["inside": "inner"] as [String: String],
      "2deeper": ["nesting": ["also": "works"]  ],
      "3array": [ "one", "two", "three", [ "deepest": "inside deepest" ] ],
      "4deeparray": [ "one", "two", "three", [ "deepest", "inside deepest" ] ],
      "5deepdictionary": ["anesting": ["also": "works"],
                          "another nesting": [ "deep": [ "deepest1" : "hello 1", "deepest2": "hello 2" ],
                                               "deeparray": [ "rolling in", ["the" : 2, "deep": 1]]]],
      "6outer": "normal",
      "7nested": ["inside": "inner"] as [String: String],
      "8deeper": ["nesting": ["also": "works"]  ],
      "9deeparrayindeepdictionary": [ "array": [ "0", "1", "2" ] ],
      ])
    
    let encoder = URLQueryItemEncoder()
    encoder.arrayIndexEncodingStrategy = .emptySquareBrackets
    let result = try encoder.encode(values)
    XCTAssertEqual(24, result.count)
    XCTAssertEqual("0outer", result[0].name)
    XCTAssertEqual("normal", result[0].value)
    XCTAssertEqual("1nested[inside]", result[1].name)
    XCTAssertEqual("inner", result[1].value)
    XCTAssertEqual("2deeper[nesting][also]", result[2].name)
    XCTAssertEqual("works", result[2].value)
    // 3array
    XCTAssertEqual("one", result[3].value)
    XCTAssertEqual("3array[]", result[3].name)
    XCTAssertEqual("two", result[4].value)
    XCTAssertEqual("3array[]", result[4].name)
    XCTAssertEqual("three", result[5].value)
    XCTAssertEqual("3array[]", result[5].name)
    XCTAssertEqual("inside deepest", result[6].value)
    XCTAssertEqual("3array[][deepest]", result[6].name)
    // 4deeparray
    XCTAssertEqual("one", result[7].value)
    XCTAssertEqual("4deeparray[]", result[7].name)
    XCTAssertEqual("two", result[8].value)
    XCTAssertEqual("4deeparray[]", result[8].name)
    XCTAssertEqual("three", result[9].value)
    XCTAssertEqual("4deeparray[]", result[9].name)
    XCTAssertEqual("deepest", result[10].value)
    XCTAssertEqual("4deeparray[][]", result[10].name)
    XCTAssertEqual("inside deepest", result[11].value)
    XCTAssertEqual("4deeparray[][]", result[11].name)
    
    // 5deepdictionary
    XCTAssertEqual("works", result[12].value)
    XCTAssertEqual("5deepdictionary[anesting][also]", result[12].name)
    XCTAssertEqual("hello 1", result[13].value)
    XCTAssertEqual("5deepdictionary[another nesting][deep][deepest1]", result[13].name)
    XCTAssertEqual("hello 2", result[14].value)
    XCTAssertEqual("5deepdictionary[another nesting][deep][deepest2]", result[14].name)
    // 5deepdictionary -> deeparray
    XCTAssertEqual("rolling in", result[15].value)
    XCTAssertEqual("5deepdictionary[another nesting][deeparray][]", result[15].name)
    XCTAssertEqual("2", result[17].value)
    XCTAssertEqual("5deepdictionary[another nesting][deeparray][][the]", result[17].name)
    XCTAssertEqual("1", result[16].value)
    XCTAssertEqual("5deepdictionary[another nesting][deeparray][][deep]", result[16].name)
    
    // resting
    XCTAssertEqual("6outer", result[18].name)
    XCTAssertEqual("normal", result[18].value)
    XCTAssertEqual("7nested[inside]", result[19].name)
    XCTAssertEqual("inner", result[19].value)
    XCTAssertEqual("8deeper[nesting][also]", result[20].name)
    XCTAssertEqual("works", result[20].value)
    
    XCTAssertEqual("0", result[21].value)
    XCTAssertEqual("9deeparrayindeepdictionary[array][]", result[21].name)
    XCTAssertEqual("1", result[22].value)
    XCTAssertEqual("9deeparrayindeepdictionary[array][]", result[22].name)
    XCTAssertEqual("2", result[23].value)
    XCTAssertEqual("9deeparrayindeepdictionary[array][]", result[23].name)
  }
  
  func testEncodeNestedWithIndexStrategy() throws {
    let values = AnyJSONType([
      "0outer": "normal",
      "1nested": ["inside": "inner"] as [String: String],
      "2deeper": ["nesting": ["also": "works"]  ],
      "3array": [ "one", "two", "three", [ "deepest": "inside deepest" ] ],
      "4deeparray": [ "one", "two", "three", [ "deepest", "inside deepest" ] ],
      "5deepdictionary": ["anesting": ["also": "works"],
                          "another nesting": [ "deep": [ "deepest1" : "hello 1", "deepest2": "hello 2" ],
                                               "deeparray": [ "rolling in", ["the" : 2, "deep": 1]]]],
      "6outer": "normal",
      "7nested": ["inside": "inner"] as [String: String],
      "8deeper": ["nesting": ["also": "works"]  ],
      "9deeparrayindeepdictionary": [ "array": [ "0", "1", "2" ] ],
      ])
    
    let encoder = URLQueryItemEncoder()
    encoder.arrayIndexEncodingStrategy = .index
    let result = try encoder.encode(values)
    XCTAssertEqual(24, result.count)
    XCTAssertEqual("0outer", result[0].name)
    XCTAssertEqual("normal", result[0].value)
    XCTAssertEqual("1nested[inside]", result[1].name)
    XCTAssertEqual("inner", result[1].value)
    XCTAssertEqual("2deeper[nesting][also]", result[2].name)
    XCTAssertEqual("works", result[2].value)
    // 3array
    XCTAssertEqual("one", result[3].value)
    XCTAssertEqual("3array[0]", result[3].name)
    XCTAssertEqual("two", result[4].value)
    XCTAssertEqual("3array[1]", result[4].name)
    XCTAssertEqual("three", result[5].value)
    XCTAssertEqual("3array[2]", result[5].name)
    XCTAssertEqual("inside deepest", result[6].value)
    XCTAssertEqual("3array[3][deepest]", result[6].name)
    // 4deeparray
    XCTAssertEqual("one", result[7].value)
    XCTAssertEqual("4deeparray[0]", result[7].name)
    XCTAssertEqual("two", result[8].value)
    XCTAssertEqual("4deeparray[1]", result[8].name)
    XCTAssertEqual("three", result[9].value)
    XCTAssertEqual("4deeparray[2]", result[9].name)
    XCTAssertEqual("deepest", result[10].value)
    XCTAssertEqual("4deeparray[3][0]", result[10].name)
    XCTAssertEqual("inside deepest", result[11].value)
    XCTAssertEqual("4deeparray[3][1]", result[11].name)
    
    // 5deepdictionary
    XCTAssertEqual("works", result[12].value)
    XCTAssertEqual("5deepdictionary[anesting][also]", result[12].name)
    XCTAssertEqual("hello 1", result[13].value)
    XCTAssertEqual("5deepdictionary[another nesting][deep][deepest1]", result[13].name)
    XCTAssertEqual("hello 2", result[14].value)
    XCTAssertEqual("5deepdictionary[another nesting][deep][deepest2]", result[14].name)
    // 5deepdictionary -> deeparray
    XCTAssertEqual("rolling in", result[15].value)
    XCTAssertEqual("5deepdictionary[another nesting][deeparray][0]", result[15].name)
    XCTAssertEqual("2", result[17].value)
    XCTAssertEqual("5deepdictionary[another nesting][deeparray][1][the]", result[17].name)
    XCTAssertEqual("1", result[16].value)
    XCTAssertEqual("5deepdictionary[another nesting][deeparray][1][deep]", result[16].name)
    
    // resting
    XCTAssertEqual("6outer", result[18].name)
    XCTAssertEqual("normal", result[18].value)
    XCTAssertEqual("7nested[inside]", result[19].name)
    XCTAssertEqual("inner", result[19].value)
    XCTAssertEqual("8deeper[nesting][also]", result[20].name)
    XCTAssertEqual("works", result[20].value)
    
    
    XCTAssertEqual("0", result[21].value)
    XCTAssertEqual("9deeparrayindeepdictionary[array][0]", result[21].name)
    XCTAssertEqual("1", result[22].value)
    XCTAssertEqual("9deeparrayindeepdictionary[array][1]", result[22].name)
    XCTAssertEqual("2", result[23].value)
    XCTAssertEqual("9deeparrayindeepdictionary[array][2]", result[23].name)
  }
  
  func testEncodeRawValueRepresentableDataType() throws {
    struct ListParams: Encodable {
      enum Order: String, Encodable {
        case ascending
        case descending
      }
      
      let order: Order?
      let from: Date?
    }
    
    let calendar = Calendar(identifier: .gregorian)
    let dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.init(identifier: "PST"), year: 2007, month: 1, day: 9, hour: 9, minute: 41)
    let date = calendar.date(from: dateComponents)
    
    let params = ListParams(order: .ascending, from: date)
    
    let encoder = URLQueryItemEncoder()
    let result = try encoder.encode(params)

    XCTAssertEqual(2, result.count)
    XCTAssertEqual("order", result[0].name)
    XCTAssertEqual("ascending", result[0].value)
    XCTAssertEqual("from", result[1].name)
    XCTAssertEqual("2007-01-09T17:41:00.000Z", result[1].value)
  }
  
  func testWWWFormURLEncodedDataEncoding() throws {
    let items: [URLQueryItem] = [
      URLQueryItem(name: "email", value: "url.query.item.encoder+test@example.com"),
      URLQueryItem(name: "password", value: "Eg{+wk?ao/6N{W3kUNZ&"),
    ]
    
    let encoded = URLQueryItemEncoder.encodeToFormURLEncodedData(queryItems: items)
    XCTAssertEqual(
      String(data: encoded, encoding: .utf8),
      "email=url.query.item.encoder%2Btest%40example.com&password=Eg%7B%2Bwk%3Fao%2F6N%7BW3kUNZ%26"
    )
  }
}


#if os(Linux)
  extension URLQueryItemEncoderTests {
    static var allTests : [(String, (URLQueryItemEncoderTests) -> () throws -> Void)] {
      return [
        ("testEncodeBasic", testEncodeBasic),
        ("testEncodeMultipleTypes", testEncodeMultipleTypes),
        ("testEncodeNestedWithEmptyIndexStrategy", testEncodeNestedWithEmptyIndexStrategy),
        ("testEncodeNestedWithIndexStrategy", testEncodeNestedWithIndexStrategy),
        ("testEncodeRawValueRepresentableDataType", testEncodeRawValueRepresentableDataType),
        ("testWWWFormURLEncodedDataEncoding", testWWWFormURLEncodedDataEncoding),

      ]
    }
  }
#endif 
