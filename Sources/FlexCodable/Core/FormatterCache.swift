import Foundation

/// Thread-safe, shared formatter cache.
/// DateFormatter is expensive to create — reuse always.
internal enum FormatterCache {

    /// Shared DateFormatter for multi-format parsing.
    /// NOTE: DateFormatter is NOT thread-safe. Access only from a single thread
    /// or protect with a lock if used concurrently.
    static let iso: DateFormatter = {
        let f = DateFormatter()
        f.locale   = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")!
        return f
    }()

    /// ISO8601DateFormatter IS thread-safe natively.
    static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static let iso8601NoFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    /// Encode output formatter — ISO8601 with fractional seconds.
    static let encoder: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
}
