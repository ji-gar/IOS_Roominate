import Foundation
import Combine

// MARK: - Pusher Protocol over native URLSessionWebSocket

/// Implements the minimal Pusher wire protocol needed to subscribe to private channels
/// on a self-hosted Laravel Reverb server without any third-party library.
@MainActor
final class ReverbManager: NSObject, ObservableObject {

    static let shared = ReverbManager()

    // MARK: Published state
    @Published var isConnected = false

    // MARK: Private
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var socketId: String?
    private var subscribedChannel: String?
    private var onMessageReceived: ((MessageItem) -> Void)?
    private var pingTimer: Timer?
    private var reconnectWorkItem: DispatchWorkItem?
    private var isIntentionalDisconnect = false

    private override init() {
        super.init()
    }

    // MARK: - Connect

    func connect() {
        guard webSocketTask == nil else { return }
        isIntentionalDisconnect = false

        let urlString = "wss://\(APIConstants.Reverb.host):\(APIConstants.Reverb.port)/app/\(APIConstants.Reverb.appKey)?protocol=7&client=ios&version=8.0.0"
        guard let url = URL(string: urlString) else { return }

        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: nil, delegateQueue: .main)
        webSocketTask = session?.webSocketTask(with: url)
        webSocketTask?.resume()
        receive()
        schedulePing()
    }

    // MARK: - Disconnect

    func disconnect() {
        isIntentionalDisconnect = true
        cleanup()
    }

    private func cleanup() {
        pingTimer?.invalidate()
        pingTimer = nil
        reconnectWorkItem?.cancel()
        reconnectWorkItem = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        session = nil
        socketId = nil
        subscribedChannel = nil
        isConnected = false
    }

    // MARK: - Subscribe

    func subscribe(
        conversationId: Int,
        onMessage: @escaping (MessageItem) -> Void
    ) {
        let channel = "private-chat.conversation.\(conversationId)"

        if subscribedChannel == channel {
            onMessageReceived = onMessage
            return
        }

        if let previous = subscribedChannel {
            sendUnsubscribe(channel: previous)
        }

        subscribedChannel = channel
        onMessageReceived = onMessage

        if isConnected, let sid = socketId {
            authenticateAndSubscribe(channel: channel, socketId: sid)
        } else {
            connect()
        }
    }

    func unsubscribe() {
        if let channel = subscribedChannel {
            sendUnsubscribe(channel: channel)
        }
        subscribedChannel = nil
        onMessageReceived = nil
    }

    // MARK: - Receive loop

    private func receive() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleFrame(text)
                default:
                    break
                }
                self.receive()
            case .failure:
                Task { @MainActor in
                    self.handleDisconnect()
                }
            }
        }
    }

    // MARK: - Frame handling

    private func handleFrame(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let event = json["event"] as? String else { return }

        switch event {
        case "pusher:connection_established":
            if let dataStr = json["data"] as? String,
               let dataObj = dataStr.data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: dataObj) as? [String: Any],
               let sid = obj["socket_id"] as? String {
                socketId = sid
                isConnected = true
                if let channel = subscribedChannel {
                    authenticateAndSubscribe(channel: channel, socketId: sid)
                }
            }

        case "pusher_internal:subscription_succeeded":
            break

        case "message.sent":
            let eventData = (json["data"] as? String) ?? ""
            if let msg = parseRealtimeMessage(eventData) {
                onMessageReceived?(msg)
            }

        case "pusher:error":
            break

        default:
            break
        }
    }

    // MARK: - Auth + Subscribe

    private func authenticateAndSubscribe(channel: String, socketId: String) {
        guard let token = TokenStorage.shared.token,
              let url = URL(string: APIConstants.Reverb.authEndpoint) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "socket_id=\(socketId)&channel_name=\(channel)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self, let data, error == nil else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let auth = json["auth"] as? String else { return }

            Task { @MainActor in
                self.sendSubscribe(channel: channel, auth: auth)
            }
        }.resume()
    }

    private func sendSubscribe(channel: String, auth: String) {
        let payload: [String: Any] = [
            "event": "pusher:subscribe",
            "data": ["channel": channel, "auth": auth]
        ]
        sendJSON(payload)
    }

    private func sendUnsubscribe(channel: String) {
        let payload: [String: Any] = [
            "event": "pusher:unsubscribe",
            "data": ["channel": channel]
        ]
        sendJSON(payload)
    }

    // MARK: - Ping / keepalive

    private func schedulePing() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }

    private func sendPing() {
        sendJSON(["event": "pusher:ping", "data": [:] as [String: String]])
    }

    // MARK: - Reconnect

    private func handleDisconnect() {
        isConnected = false
        cleanup()
        guard !isIntentionalDisconnect else { return }

        let work = DispatchWorkItem { [weak self] in
            self?.reconnect()
        }
        reconnectWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
    }

    private func reconnect() {
        connect()
        if let channel = subscribedChannel {
            subscribedChannel = channel
        }
    }

    // MARK: - Send helper

    private func sendJSON(_ dict: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let text = String(data: data, encoding: .utf8) else { return }
        webSocketTask?.send(.string(text)) { _ in }
    }

    // MARK: - Parse realtime payload

    private func parseRealtimeMessage(_ json: String) -> MessageItem? {
        guard let root = try? JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any]
        else { return nil }
        let obj = (root["message"] as? [String: Any])
                ?? (root["data"] as? [String: Any])
                ?? root
        guard let objData = try? JSONSerialization.data(withJSONObject: obj) else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(MessageItem.self, from: objData)
    }
}
