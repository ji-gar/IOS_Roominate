import SwiftUI

struct PlacesSearchTextField: View {
    @Binding var selectedText: String
    @StateObject private var placesService = GooglePlacesService()
    @State private var query: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 16))
                    .foregroundStyle(isFocused ? AppTheme.primaryBlue : AppTheme.textSecondary)

                TextField(Strings.Profile.areaPlaceholder, text: $query)
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textPrimary)
                    .focused($isFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .onChange(of: query) { _, newValue in
                        selectedText = newValue
                        placesService.search(query: newValue)
                    }

                if placesService.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
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
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(isFocused ? AppTheme.activeFieldBackground : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isFocused ? AppTheme.primaryBlue : AppTheme.fieldBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))

            if isFocused && !placesService.suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(placesService.suggestions.enumerated()), id: \.element.id) { index, suggestion in
                        Button {
                            query = suggestion.fullText
                            selectedText = suggestion.fullText
                            isFocused = false
                            placesService.clear()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 13))
                                    .foregroundStyle(AppTheme.primaryBlue)
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
        }
        .onAppear {
            query = selectedText
        }
        .onChange(of: selectedText) { _, newValue in
            if query != newValue { query = newValue }
        }
    }
}
