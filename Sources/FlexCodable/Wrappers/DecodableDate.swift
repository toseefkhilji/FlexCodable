import Foundation

// MARK: - Date Parsing Core

extension Date {

    internal static let flexFormats: [String] = [
        "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd'T'HH:mm:ss",
        "yyyy-MM-dd HH:mm:ss.SSS",
        "yyyy-MM-dd HH:mm:ss",
        "yyyy/MM/dd HH:mm:ss",
        "yyyy/MM/dd hh:mm:ss a",
        "yyyy-MM-dd",
        "yyyy/MM/dd",
        "HH:mm:ss",
        "HH:mm",
        "hh:mm:ss a",
        "hh:mm a"
    ]

    /// Parse a date string trying multiple strategies:
    /// 1. ISO8601 fast path (thread-safe)
    /// 2. Common format list
    /// 3. NSDataDetector fallback for natural language dates
    public static func flexParse(
        _ string: String,
        timeZone: TimeZone = TimeZone(identifier: "UTC")!
    ) -> Date? {
        // 1. Fast path: native ISO8601 (thread-safe, no format loop needed)
        if let date = FormatterCache.iso8601.date(from: string) { return date }
        if let date = FormatterCache.iso8601NoFraction.date(from: string) { return date }

        // 2. Try all common formats
        let formatter = FormatterCache.iso
        formatter.timeZone = timeZone
        for format in flexFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) { return date }
        }

        // 3. NSDataDetector fallback (natural language: "June 19, 2026")
        let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.date.rawValue
        )
        return detector?
            .firstMatch(in: string, range: NSRange(string.startIndex..., in: string))?
            .date
    }

    internal func toISO8601() -> String {
        FormatterCache.encoder.string(from: self)
    }
}

// MARK: - @DecodableDate (non-optional: Date)

/// Required date field. Throws `DecodingError` if key is missing, null, or unparseable.
///
///     @DecodableDate var publishedAt: Date
@propertyWrapper
public struct DecodableDate: Codable {
    public var wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            throw DecodingError.valueNotFound(Date.self, .init(
                codingPath: decoder.codingPath,
                debugDescription: "[FlexCodable] Expected date string, got null."
            ))
        }

        let string = try container.decode(String.self)

        guard let date = Date.flexParse(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "[FlexCodable] Cannot parse date from: \"\(string)\""
            )
        }
        self.wrappedValue = date
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue.toISO8601())
    }
}

// MARK: - @DecodableDateOptional (optional: Date?)

/// Optional date field. Returns nil if key is absent, null, or unparseable.
///
///     @DecodableDateOptional var updatedAt: Date?
@propertyWrapper
public struct DecodableDateOptional: Codable {
    public var wrappedValue: Date?

    public init(wrappedValue: Date? = nil) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard !container.decodeNil() else { self.wrappedValue = nil; return }
        let string = try container.decode(String.self)
        self.wrappedValue = Date.flexParse(string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let date = wrappedValue { try container.encode(date.toISO8601()) }
        else { try container.encodeNil() }
    }
}

// MARK: - KeyedDecodingContainer support for missing optional keys

public extension KeyedDecodingContainer {
    func decodeIfPresent(
        _ type: DecodableDate.Type,
        forKey key: Key
    ) throws -> DecodableDate? {
        guard contains(key), try !decodeNil(forKey: key) else { return nil }
        return try decode(type, forKey: key)
    }

    func decodeIfPresent(
        _ type: DecodableDateOptional.Type,
        forKey key: Key
    ) throws -> DecodableDateOptional? {
        guard contains(key) else { return nil }
        return try decode(type, forKey: key)
    }
}
