import Combine
import Foundation

struct PlaceSuggestion: Identifiable, Equatable {
    let id: String
    let mainText: String
    let secondaryText: String

    var fullText: String {
        secondaryText.isEmpty ? mainText : "\(mainText), \(secondaryText)"
    }
}

@MainActor
final class GooglePlacesService: ObservableObject {
    @Published var suggestions: [PlaceSuggestion] = []
    @Published var isLoading = false

    private var searchTask: Task<Void, Never>?

    func search(query: String) {
        searchTask?.cancel()

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            suggestions = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }

            isLoading = true
            defer { isLoading = false }

            let key = APIConstants.googlePlacesAPIKey
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encoded)&types=(cities)&key=\(key)"

            guard let url = URL(string: urlString) else { return }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled else { return }

                let response = try JSONDecoder().decode(AutocompleteResponse.self, from: data)
                suggestions = response.predictions.map { prediction in
                    PlaceSuggestion(
                        id: prediction.placeId,
                        mainText: prediction.structuredFormatting.mainText,
                        secondaryText: prediction.structuredFormatting.secondaryText ?? ""
                    )
                }
            } catch {
                if !Task.isCancelled {
                    suggestions = []
                }
            }
        }
    }

    func clear() {
        searchTask?.cancel()
        suggestions = []
    }
}

// MARK: - Response Models

private struct AutocompleteResponse: Decodable {
    let predictions: [Prediction]
    let status: String

    struct Prediction: Decodable {
        let placeId: String
        let structuredFormatting: StructuredFormatting

        enum CodingKeys: String, CodingKey {
            case placeId = "place_id"
            case structuredFormatting = "structured_formatting"
        }
    }

    struct StructuredFormatting: Decodable {
        let mainText: String
        let secondaryText: String?

        enum CodingKeys: String, CodingKey {
            case mainText = "main_text"
            case secondaryText = "secondary_text"
        }
    }
}
