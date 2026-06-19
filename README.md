# FlexCodable

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015%2B%20%7C%20macOS%2012%2B%20%7C%20tvOS%2015%2B%20%7C%20watchOS%208%2B-blue.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Lightweight Swift property wrappers for flexible `Codable` decoding — handles messy real-world APIs with zero dependencies.

Maintained by [@toseefkhilji](https://github.com/toseefkhilji)

## Features

- 📅 **Date** — parses 15+ formats + ISO8601 fast-path + `NSDataDetector` fallback
- 🔤 **String** — coerces `Int`, `Double`, `Bool` from JSON to `String`
- 🔢 **Int** — parses from `"42"`, `42`, `true/false`
- ✅ **Bool** — handles `0/1`, `true/false`, `"TRUE"/"FALSE"`, `"yes"/"no"`, `"on"/"off"`
- Every type has both a **required** (`throws`) and **optional** (`nil`) variant
- Shared `DateFormatter` cache — no re-allocation per decode call

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies** and enter:

```
https://github.com/toseefkhilji/FlexCodable
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/toseefkhilji/FlexCodable", from: "1.0.0")
]
```

## Usage

```swift
import FlexCodable

struct User: Codable {
    // Date
    @DecodableDate         var createdAt:  Date     // throws if missing or unparseable
    @DecodableDateOptional var deletedAt:  Date?    // nil if missing / null

    // String — coerces Int/Double/Bool
    @DecodableString         var userID:   String   // 1234 → "1234"
    @DecodableStringOptional var nickname: String?

    // Int — coerces from "42", 42, true/false
    @DecodableInt         var score:       Int
    @DecodableIntOptional var retryCount:  Int?

    // Bool — 0/1, "TRUE"/"false", "yes"/"no", "on"/"off"
    @DecodableBool         var isActive:   Bool
    @DecodableBoolOptional var isVerified: Bool?
}

let json = """
{
    "userID": 9001,
    "createdAt": "2024-06-01T10:00:00Z",
    "score": "42",
    "isActive": 1,
    "nickname": null
}
"""

let user = try JSONDecoder().decode(User.self, from: Data(json.utf8))
print(user.userID)   // "9001"
print(user.score)    // 42
print(user.isActive) // true
```

## Wrapper Behaviour

| Wrapper | Missing key | Null value | Wrong type |
|---|---|---|---|
| `@DecodableDate` | 🔴 throws | 🔴 throws | 🔴 throws |
| `@DecodableDateOptional` | ✅ nil | ✅ nil | ✅ nil |
| `@DecodableString` | 🔴 throws | 🔴 throws | ✅ coerces |
| `@DecodableStringOptional` | ✅ nil | ✅ nil | ✅ coerces |
| `@DecodableInt` | 🔴 throws | 🔴 throws | ✅ coerces |
| `@DecodableIntOptional` | ✅ nil | ✅ nil | ✅ coerces |
| `@DecodableBool` | 🔴 throws | 🔴 throws | ✅ coerces |
| `@DecodableBoolOptional` | ✅ nil | ✅ nil | ✅ coerces |

## Date Formats Supported

```
yyyy-MM-dd'T'HH:mm:ssZZZZZ
yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ
yyyy-MM-dd'T'HH:mm:ss.SSSZ
yyyy-MM-dd'T'HH:mm:ssZ
yyyy-MM-dd'T'HH:mm:ss
yyyy-MM-dd HH:mm:ss.SSS
yyyy-MM-dd HH:mm:ss
yyyy/MM/dd HH:mm:ss
yyyy/MM/dd hh:mm:ss a
yyyy-MM-dd
yyyy/MM/dd
HH:mm:ss / HH:mm
hh:mm:ss a / hh:mm a
+ NSDataDetector fallback (natural language dates)
```

## Author

**Toseef Khilji** — [@toseefkhilji](https://github.com/toseefkhilji)

## License

MIT — see [LICENSE](LICENSE)
