import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var viewModel = DIManager.shared.getCountryListViewModel()
    @State private var selectedTab = 0

    // Computed property for dynamic navigation title based on selected tab
    private var navigationTitle: String {
        selectedTab == 1 ? "Saved" : "Search"
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TabView(selection: $selectedTab) {
                
                // MARK: - Search Tab
                makeCountryListView(
                    showFavoritesOnly: false,
                    icon: "magnifyingglass",
                    title: "Search",
                    tag: 0
                )
                
                // MARK: - Saved Tab
                makeCountryListView(
                    showFavoritesOnly: true,
                    icon: "star",
                    title: "Saved",
                    tag: 1
                )
            }
            // Navigation logic encapsulated here
            .navigationDestination(for: CountryListItem.self) { country in
                CountryDetailView(coordinator: coordinator, country: country)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $viewModel.searchText, prompt: "Search")
        .environmentObject(coordinator) // coordinator injected globally
    }

    // MARK: - Factory method for tabs
    @ViewBuilder
    private func makeCountryListView(
        showFavoritesOnly: Bool,
        icon: String,
        title: String,
        tag: Int
    ) -> some View {
        CountryListView(coordinator: coordinator, viewModel: viewModel)
            .onAppear {
                viewModel.showFavoritesOnly = showFavoritesOnly
            }
            .onDisappear {
                // Restauramos el estado solo si fue modificado
                if viewModel.showFavoritesOnly != !showFavoritesOnly {
                    viewModel.showFavoritesOnly = false
                }
            }
            .tabItem {
                Image(systemName: icon)
                Text(title)
            }
            .tag(tag)
    }
}

