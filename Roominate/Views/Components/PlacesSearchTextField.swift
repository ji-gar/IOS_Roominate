import CoreLocation
import SwiftUI

struct PlacesSearchTextField: View {
    enum FieldStyle {
        case standard
        case outlined
    }

    @Binding var selectedText: String
    var mode: PlacesSearchMode = .cities
    var placeholder: String = "Search city or area"
    var fieldStyle: FieldStyle = .standard
    var onPlaceSelected: ((PlaceDetails) -> Void)?

    @StateObject private var placesService = GooglePlacesService()
    @State private var query: String = ""
    @FocusState private var isFocused: Bool

    private var showsSuggestions: Bool {
        isFocused && !placesService.suggestions.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                switch fieldStyle {
                case .standard:
                    standardSearchField
                case .outlined:
                    outlinedSearchField
                }
            }
            .zIndex(showsSuggestions ? 2 : 0)

            if showsSuggestions {
                suggestionsList
                    .zIndex(3)
            }
        }
        .zIndex(showsSuggestions ? 50 : 0)
        .onAppear {
            query = selectedText
        }
        .onChange(of: selectedText) { _, newValue in
            if query != newValue { query = newValue }
        }
    }

    private var standardSearchField: some View {
        HStack(spacing: 10) {
            TextField(placeholder, text: $query)
                .font(.system(size: 16))
                .appTextInputStyle()
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .onChange(of: query) { _, newValue in
                    selectedText = newValue
                    placesService.search(query: newValue, mode: mode)
                }

            trailingIcon
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(isFocused ? AppTheme.activeFieldBackground : AppTheme.fieldBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(isFocused ? AppTheme.primaryBlue : AppTheme.fieldBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var outlinedSearchField: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isFocused || !query.isEmpty ? AppTheme.primaryBlue : AppTheme.fieldBorder, lineWidth: 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(placeholder)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryBlue)
                    .opacity(isFocused || !query.isEmpty ? 1 : 0)

                HStack(spacing: 8) {
                    TextField(placeholder, text: $query)
                        .font(.system(size: 15))
                        .appTextInputStyle()
                        .focused($isFocused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .onChange(of: query) { _, newValue in
                            selectedText = newValue
                            placesService.search(query: newValue, mode: mode)
                        }

                    trailingIcon
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
        }
        .frame(height: 60)
        .animation(.easeInOut(duration: 0.18), value: isFocused)
        .animation(.easeInOut(duration: 0.18), value: query.isEmpty)
    }

    @ViewBuilder
    private var trailingIcon: some View {
        if placesService.isLoading {
            ProgressView()
                .scaleEffect(0.7)
        } else if isLandmarkOrAddressMode {
            Image(systemName: "magnifyingglass")
                .font(.system(size: fieldStyle == .outlined ? 15 : 16))
                .foregroundStyle(AppTheme.textSecondary)
        } else if !query.isEmpty {
            Button {
                query = ""
                selectedText = ""
                placesService.clear()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    private var isLandmarkOrAddressMode: Bool {
        switch mode {
        case .address, .landmarks: return true
        case .cities: return false
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
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .padding(.top, 4)
    }

    private func selectSuggestion(_ suggestion: PlaceSuggestion) {
        let displayText: String
        switch mode {
        case .cities:
            displayText = suggestion.mainText
        case .landmarks, .address:
            displayText = suggestion.mainText
        }

        query = displayText
        selectedText = displayText
        isFocused = false
        placesService.clear()

        guard let onPlaceSelected else { return }

        Task {
            let details = await placesService.resolveSuggestion(suggestion, mode: mode)
            onPlaceSelected(details)
        }
    }
}
