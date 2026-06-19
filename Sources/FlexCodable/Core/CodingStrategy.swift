import Foundation

/// Base protocol for custom FlexCodable decoding strategies.
/// Implement this to build your own wrappers on top of FlexCodable's foundation.
public protocol FlexDecodingStrategy {
    associatedtype DecodedType
    static func decode(from decoder: Decoder) throws -> DecodedType
}
