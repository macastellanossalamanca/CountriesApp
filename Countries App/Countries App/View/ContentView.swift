import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = DIManager.shared.makeAppCoordinator()
    @StateObject private var viewModel = DIManager.shared.getCountryListViewModel()
    @State private var selectedTab = 0

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
            .navigationDestination(for: CountryListItem.self) { country in
                CountryDetailView(country: country)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $viewModel.searchText, prompt: "Search")
        .environmentObject(coordinator)
    }

    // MARK: - Factory method for tabs
    @ViewBuilder
    private func makeCountryListView(
        showFavoritesOnly: Bool,
        icon: String,
        title: String,
        tag: Int
    ) -> some View {
        CountryListView(viewModel: viewModel)
            .onAppear {
                viewModel.showFavoritesOnly = showFavoritesOnly
            }
            .onDisappear {
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

