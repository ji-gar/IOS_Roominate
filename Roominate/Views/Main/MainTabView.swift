import SwiftUI

struct MainTabView: View {
    let onSignOut: () -> Void

    init(onSignOut: @escaping () -> Void = {}) {
        self.onSignOut = onSignOut

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }

            PlaceholderTabView(title: "Wishlist", systemImage: "heart")
                .tabItem {
                    Label("Wishlist", systemImage: "heart")
                }

            PlaceholderTabView(title: "Add Listing", systemImage: "plus.circle")
                .tabItem {
                    Label("Add", systemImage: "plus")
                }

            ProfileTabView(onSignOut: onSignOut)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .tint(AppTheme.primaryBlue)
    }
}

#Preview {
    MainTabView()
}
