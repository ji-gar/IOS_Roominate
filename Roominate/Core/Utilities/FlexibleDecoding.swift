import Foundation

extension KeyedDecodingContainer {
    func decodeFlexibleInt(forKey key: Key) throws -> Int {
        if let value = try? decode(Int.self, forKey: key) { return value }
        if let value = try? decode(String.self, forKey: key), let intValue = Int(value) { return intValue }
        if let value = try? decode(Double.self, forKey: key) { return Int(value) }
        throw DecodingError.typeMismatch(
            Int.self,
            .init(codingPath: codingPath + [key], debugDescription: "Expected Int-compatible value.")
        )
    }

    func decodeFlexibleIntIfPresent(forKey key: Key) throws -> Int? {
        guard contains(key), !(try decodeNil(forKey: key)) else { return nil }
        return try decodeFlexibleInt(forKey: key)
    }

    func decodeFlexibleInt(forKey key: Key, default defaultValue: Int) -> Int {
        (try? decodeFlexibleInt(forKey: key)) ?? defaultValue
    }
}
