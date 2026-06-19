import Foundation

// MARK: - Internal coercion helper

private func coerceToString(container: SingleValueDecodingContainer) -> String? {
    if let value = try? container.decode(String.self) { return value }
    if let value = try? container.decode(Int.self)    { return String(value) }
    if let value = try? container.decode(Double.self) {
        return value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(value)
    }
    if let value = try? container.decode(Bool.self)   { return String(value) }
    return nil
}

// MARK: - @DecodableString (non-optional: String)

/// Required string field. Coerces Int, Double, Bool from JSON to String.
/// Throws if key is missing, null, or value is not coercible.
///
///     @DecodableString var userID: String   // 1234 → "1234"
@propertyWrapper
public struct DecodableString: Codable {
    public var wrappedValue: String

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            throw DecodingError.valueNotFound(String.self, .init(
                codingPath: decoder.codingPath,
                debugDescription: "[FlexCodable] Expected String, got null."
            ))
        }

        guard let value = coerceToString(container: container) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "[FlexCodable] Cannot convert value to String."
            )
        }
        self.wrappedValue = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

// MARK: - @DecodableStringOptional (optional: String?)

/// Optional string field. Coerces Int/Double/Bool. Returns nil for null or missing keys.
///
///     @DecodableStringOptional var nickname: String?
@propertyWrapper
public struct DecodableStringOptional: Codable {
    public var wrappedValue: String?

    public init(wrappedValue: String? = nil) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard !container.decodeNil() else { self.wrappedValue = nil; return }
        self.wrappedValue = coerceToString(container: container)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let v = wrappedValue { try container.encode(v) }
        else { try container.encodeNil() }
    }
}
