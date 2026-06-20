import Combine
import SwiftUI

enum AppTab: Hashable {
    case explore
    case wishlist
    case add
    case profile
}

@MainActor
final class MainTabState: ObservableObject {
    @Published var selectedTab: AppTab = .explore
    @Published private(set) var homeRefreshID = UUID()
    @Published private(set) var addFlowResetID = UUID()

    func openAddTab() {
        selectedTab = .add
    }

    func cancelAddFlow() {
        selectedTab = .explore
    }

    func completeAddFlow() {
        selectedTab = .explore
        homeRefreshID = UUID()
        addFlowResetID = UUID()
    }
}

struct MainTabView: View {
    let onSignOut: () -> Void
    @StateObject private var tabState = MainTabState()

    init(onSignOut: @escaping () -> Void = {}) {
        self.onSignOut = onSignOut

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $tabState.selectedTab) {
            HomeView()
                .environmentObject(tabState)
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(AppTab.explore)

            PlaceholderTabView(title: "Wishlist", systemImage: "heart")
                .tabItem {
                    Label("Wishlist", systemImage: "heart")
                }
                .tag(AppTab.wishlist)

            CreatePostFlowView(
                onDismiss: { tabState.cancelAddFlow() },
                onSuccess: { tabState.completeAddFlow() }
            )
            .id(tabState.addFlowResetID)
            .tabItem {
                Label("Add", systemImage: "plus")
            }
            .tag(AppTab.add)

            ProfileTabView(onSignOut: onSignOut)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(AppTab.profile)
        }
        .tint(AppTheme.primaryBlue)
    }
}

#Preview {
    MainTabView()
}
