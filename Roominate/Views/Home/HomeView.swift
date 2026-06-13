import SwiftUI

enum HomeRoute: Hashable {
    case flatDetail(FlatListing)
    case flatmateDetail(FlatmateListing)
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var path: [HomeRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                feed
            }
            .background(AppTheme.screenBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .flatDetail(let listing):
                    FlatDetailView(listing: listing)
                case .flatmateDetail(let listing):
                    FlatmateDetailView(listing: listing)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text(Strings.App.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.primaryBlue)
            Spacer()
            Image(systemName: "ellipsis.message")
                .font(.system(size: 20))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.textSecondary)
                TextField("Search City / area", text: $viewModel.searchText)
                    .font(.system(size: 15))
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.infoCardBorder, lineWidth: 1)
            )

            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    private var feed: some View {
        ScrollView {
            VStack(spacing: 16) {
                ListingSegmentedControl(selection: $viewModel.segment)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                switch viewModel.segment {
                case .flat:
                    flatList
                case .flatmate:
                    flatmateList
                }
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private var flatList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.filteredFlats) { listing in
                NavigationLink(value: HomeRoute.flatDetail(listing)) {
                    FlatCard(
                        listing: listing,
                        isFavorite: viewModel.isFavorite(listing.id),
                        onToggleFavorite: { viewModel.toggleFavorite(listing.id) }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private var flatmateList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.filteredFlatmates) { listing in
                NavigationLink(value: HomeRoute.flatmateDetail(listing)) {
                    FlatmateCard(
                        listing: listing,
                        isFavorite: viewModel.isFavorite(listing.id),
                        onSave: { viewModel.toggleFavorite(listing.id) },
                        onChat: {}
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    HomeView()
}
