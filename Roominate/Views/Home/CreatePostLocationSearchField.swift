import SwiftUI

struct CreatePostLocationSearchField: View {
    @Binding var searchText: String
    var onPlaceSelected: (PlaceDetails) -> Void

    @StateObject private var placesService = GooglePlacesService()
    @State private var query: String = ""
    @FocusState private var isFocused: Bool

    private var isFilled: Bool { !query.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused || isFilled ? AppTheme.primaryBlue : AppTheme.fieldBorder, lineWidth: 1)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Search location")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryBlue)
                        .opacity(isFocused || isFilled ? 1 : 0)

                    HStack(spacing: 8) {
                        TextField("Search location", text: $query)
                            .font(.system(size: 15))
                            .appTextInputStyle()
                            .focused($isFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .onChange(of: query) { _, newValue in
                                searchText = newValue
                                placesService.search(query: newValue, mode: .address)
                            }

                        if placesService.isLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
            }
            .frame(height: 60)
            .animation(.easeInOut(duration: 0.18), value: isFilled)
            .animation(.easeInOut(duration: 0.18), value: isFocused)

            if isFocused && !placesService.suggestions.isEmpty {
                suggestionsList
            }
        }
        .onAppear {
            query = searchText
        }
        .onChange(of: searchText) { _, newValue in
            if query != newValue { query = newValue }
        }
    }

    private var suggestionsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(placesService.suggestions.enumerated()), id: \.element.id) { index, suggestion in
                Button {
                    selectSuggestion(suggestion)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "mappin")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(width: 18)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.mainText)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary)

                            if !suggestion.secondaryText.isEmpty {
                                Text(suggestion.secondaryText)
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                }
                .buttonStyle(.plain)

                if index < placesService.suggestions.count - 1 {
                    Divider()
                        .padding(.leading, 46)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.fieldBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
        .padding(.top, 4)
        .zIndex(10)
    }

    private func selectSuggestion(_ suggestion: PlaceSuggestion) {
        query = suggestion.fullText
        searchText = suggestion.fullText
        isFocused = false
        placesService.clear()

        Task {
            if let details = await placesService.fetchPlaceDetails(placeId: suggestion.id) {
                onPlaceSelected(details)
            }
        }
    }
}
