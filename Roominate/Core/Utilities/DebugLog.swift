import Foundation

enum DebugLog {
    private static let endpoint = URL(string: "http://127.0.0.1:7907/ingest/3153621c-40e9-4ad8-95c5-edfcfb20defd")!
    private static let sessionId = "5371db"
    private static let logPath = "/Users/nandinivithlani/Desktop/Roominate/.cursor/debug-5371db.log"

    static func write(
        location: String,
        message: String,
        data: [String: String] = [:],
        hypothesisId: String,
        runId: String = "pre-fix"
    ) {
        // #region agent log
        let payload: [String: Any] = [
            "sessionId": sessionId,
            "location": location,
            "message": message,
            "data": data,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000),
            "hypothesisId": hypothesisId,
            "runId": runId
        ]

        let logLine: String = {
            guard let json = try? JSONSerialization.data(withJSONObject: payload),
                  let line = String(data: json, encoding: .utf8) else { return "" }
            return line + "\n"
        }()

        print("[RoominateAuth][\(hypothesisId)] \(location) - \(message) \(data)")

        if let handle = FileHandle(forWritingAtPath: logPath) {
            handle.seekToEndOfFile()
            if let data = logLine.data(using: .utf8) {
                handle.write(data)
            }
            handle.closeFile()
        } else {
            FileManager.default.createFile(atPath: logPath, contents: logLine.data(using: .utf8))
        }

        guard let body = try? JSONSerialization.data(withJSONObject: payload) else { return }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionId, forHTTPHeaderField: "X-Debug-Session-Id")
        request.httpBody = body
        URLSession.shared.dataTask(with: request).resume()
        // #endregion
    }
}
