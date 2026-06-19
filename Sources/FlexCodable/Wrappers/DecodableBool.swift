import Foundation

// MARK: - Internal coercion helper

private func coerceToBool(container: SingleValueDecodingContainer) -> Bool? {
    if let value = try? container.decode(Bool.self) { return value }
    if let int   = try? container.decode(Int.self)  { return int != 0 }
    if let string = try? container.decode(String.self) {
        switch string.lowercased().trimmingCharacters(in: .whitespaces) {
        case "true",  "yes", "1", "on":  return true
        case "false", "no",  "0", "off": return false
        default: return nil
        }
    }
    return nil
}

// MARK: - @DecodableBool (non-optional: Bool)

/// Required Bool field.
/// Handles: true/false, 0/1, "true"/"false", "TRUE"/"FALSE", "yes"/"no", "on"/"off".
/// Throws if key is missing, null, or not coercible.
///
///     @DecodableBool var isActive: Bool
@propertyWrapper
public struct DecodableBool: Codable {
    public var wrappedValue: Bool

    public init(wrappedValue: Bool) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            throw DecodingError.valueNotFound(Bool.self, .init(
                codingPath: decoder.codingPath,
                debugDescription: "[FlexCodable] Expected Bool, got null."
            ))
        }

        guard let value = coerceToBool(container: container) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "[FlexCodable] Cannot convert value to Bool."
            )
        }
        self.wrappedValue = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

// MARK: - @DecodableBoolOptional (optional: Bool?)

/// Optional Bool field. Returns nil for null or missing keys.
///
///     @DecodableBoolOptional var isVerified: Bool?
@propertyWrapper
public struct DecodableBoolOptional: Codable {
    public var wrappedValue: Bool?

    public init(wrappedValue: Bool? = nil) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard !container.decodeNil() else { self.wrappedValue = nil; return }
        self.wrappedValue = coerceToBool(container: container)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let v = wrappedValue { try container.encode(v) }
        else { try container.encodeNil() }
    }
}
