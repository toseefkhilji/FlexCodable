import Foundation

// MARK: - Internal coercion helper

private func coerceToInt(container: SingleValueDecodingContainer) -> Int? {
    if let value = try? container.decode(Int.self)    { return value }
    if let string = try? container.decode(String.self), let value = Int(string) { return value }
    if let double = try? container.decode(Double.self) { return Int(double) }
    if let bool   = try? container.decode(Bool.self)   { return bool ? 1 : 0 }
    return nil
}

// MARK: - @DecodableInt (non-optional: Int)

/// Required Int field. Parses from Int, "42" (String), 3.7 (Double→3), true/false (Bool→1/0).
/// Throws if key is missing, null, or not coercible.
///
///     @DecodableInt var count: Int
@propertyWrapper
public struct DecodableInt: Codable {
    public var wrappedValue: Int

    public init(wrappedValue: Int) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            throw DecodingError.valueNotFound(Int.self, .init(
                codingPath: decoder.codingPath,
                debugDescription: "[FlexCodable] Expected Int, got null."
            ))
        }

        guard let value = coerceToInt(container: container) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "[FlexCodable] Cannot convert value to Int."
            )
        }
        self.wrappedValue = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

// MARK: - @DecodableIntOptional (optional: Int?)

/// Optional Int field. Returns nil for null or missing keys.
///
///     @DecodableIntOptional var retryCount: Int?
@propertyWrapper
public struct DecodableIntOptional: Codable {
    public var wrappedValue: Int?

    public init(wrappedValue: Int? = nil) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard !container.decodeNil() else { self.wrappedValue = nil; return }
        self.wrappedValue = coerceToInt(container: container)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let v = wrappedValue { try container.encode(v) }
        else { try container.encodeNil() }
    }
}
