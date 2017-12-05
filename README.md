# URLQueryItemEncoder
![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20Linux-4E4E4E.svg?colorA=EF5138)
[![Swift support](https://img.shields.io/badge/Swift-4.0-lightgrey.svg?colorA=EF5138&colorB=4E4E4E)](#requirements)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/URLQueryItemEncoder.svg?style=flat&label=CocoaPods)](https://cocoapods.org/pods/URLQueryItemEncoder)
![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorB=64A5DE)
![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorB=64A5DE)
[![Twitter](https://img.shields.io/badge/twitter-@pitiphong__p-blue.svg?style=flat&colorB=64A5DE&label=Twitter)](http://twitter.com/pitiphong_p)


A Swift `Encoder` for encoding any `Encodable` value into an array of `URLQueryItem`. As part of the [SE-0166](https://github.com/apple/swift-evolution/blob/master/proposals/0166-swift-archival-serialization.md), Swift has a foundation for any type to define how its value should be archived. This encoder allows you to encode those value into an array of `URLQueryItem` which represent that value in one command.

```swift
struct Language {
  let name: String
  let age: Int
}

let person = Language(name: "Swift", age: 4)
let encoder = URLQueryItemEncoder()
let items = try encoder.encode(person)
// items == [URLQueryItem(name: "name", value: "Swift"), URLQueryItem(name: "age", value: "4")]
```

# Requirements
- iOS 8+
- macOS 10.10+
- Swift 4.0+

# Installation
## Manually
This project comes with built in *`URLQueryItemEncoder framework`* target. You can drag `URLQueryItemEncoder.xcproj` file into your project, add `URLQueryItemEncoder framework` target as a target dependency and link/embed that framework. and Voila!!!
```swift
import URLQueryItemEncoder
```
Or you can copy the `URLQueryItemEncoder.swift` file into your project.

## CocoaPods
Add the following to your `Podfile`
```ruby
pod 'URLQueryItemEncoder'
use_frameworks!
```
## Carthage
Add the following to your `Cartfile`
```ruby
github "pitiphong-p/URLQueryItemEncoder"
```

## Swift Package Manager
You can use [Swift Package Manager](https://swift.org/package-manager/) and specify dependency in `Package.swift` by adding this:
```swift
dependencies: [
    .Package(url: "https://github.com/pitiphong-p/URLQueryItemEncoder.git", majorVersion: 0)
]
```


# Usage
The `URLQueryItemEncoder` has a simple and familiar API. It has only 1 method for performing the encoding and 1 strategy for choosing how to encode the `Array Index` key.

```swift
let encoder = URLQueryItemEncoder()
let items = try encoder.encode(person)
```

# Contact
### Pitiphong Phongpattranont
- [@pitiphong_p on Twitter](https://twitter.com/pitiphong_p)

# License
`URLQueryItemEncoder` is released under an MIT License.  
Copyright © 2017-present Pitiphong Phongpattranont.