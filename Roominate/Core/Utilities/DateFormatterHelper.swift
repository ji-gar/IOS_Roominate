import Foundation

enum DateFormatterHelper {
    /// Formats a `Date` for API requests as `yyyy-MM-dd`.
    static func apiDateString(from date: Date) -> String {
        apiDateFormatter.string(from: date)
    }

    /// Formats an API date string for display as `dd/MM/yyyy`.
    /// Returns the original string if parsing fails.
    static func displayDate(from apiValue: String?) -> String {
        guard let apiValue, !apiValue.isEmpty else { return "" }
        guard let date = parseAPIDate(apiValue) else { return apiValue }
        return utcDisplayDateFormatter.string(from: date)
    }

    /// Formats a date range from API strings as `dd/MM/yyyy - dd/MM/yyyy`.
    static func displayDateRange(from start: String?, to end: String?) -> String {
        let formattedStart = displayDate(from: start)
        let formattedEnd = displayDate(from: end)
        if !formattedStart.isEmpty, !formattedEnd.isEmpty {
            return "\(formattedStart) - \(formattedEnd)"
        }
        return formattedStart.isEmpty ? formattedEnd : formattedStart
    }

    /// Formats a locally selected `Date` for display as `dd/MM/yyyy`.
    static func displayDate(from date: Date) -> String {
        localDisplayDateFormatter.string(from: date)
    }

    /// Parses API date strings (ISO 8601 with timezone, or plain `yyyy-MM-dd`).
    static func parseAPIDate(_ value: String) -> Date? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let date = iso8601WithFractionalSeconds.date(from: trimmed) {
            return date
        }
        if let date = iso8601Formatter.date(from: trimmed) {
            return date
        }
        if let date = utcAPIDateFormatter.date(from: trimmed) {
            return date
        }

        for format in fallbackInputFormats {
            fallbackInputFormatter.dateFormat = format
            if let date = fallbackInputFormatter.date(from: trimmed) {
                return date
            }
        }
        return nil
    }

    /// Shared formatter for filter UI date pickers.
    static var filterDisplayFormatter: DateFormatter { localDisplayDateFormatter }

    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let utcAPIDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    /// Preserves the calendar date from UTC ISO API strings.
    private static let utcDisplayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let localDisplayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let fallbackInputFormats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
        "yyyy-MM-dd'T'HH:mm:ss'Z'"
    ]

    private static let fallbackInputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
