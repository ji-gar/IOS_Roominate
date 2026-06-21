import Foundation

enum DebugSessionLog {
    private static let ingestURL = URL(string: "http://127.0.0.1:7907/ingest/3153621c-40e9-4ad8-95c5-edfcfb20defd")!
    private static let sessionId = "329e19"

    static func write(
        location: String,
        message: String,
        data: [String: String] = [:],
        hypothesisId: String,
        runId: String = "pre-fix"
    ) {
        #if DEBUG
        var payload: [String: Any] = [
            "sessionId": sessionId,
            "location": location,
            "message": message,
            "hypothesisId": hypothesisId,
            "runId": runId,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ]
        if !data.isEmpty { payload["data"] = data }

        guard JSONSerialization.isValidJSONObject(payload),
              let body = try? JSONSerialization.data(withJSONObject: payload) else { return }

        var request = URLRequest(url: ingestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionId, forHTTPHeaderField: "X-Debug-Session-Id")
        request.httpBody = body

        URLSession.shared.dataTask(with: request).resume()
        NSLog("[debug-329e19] \(location) — \(message) — \(data)")
        #endif
    }
}
