//
//  CountryListViewModel.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

import SwiftUI
import CoreData

@MainActor
final class CountryListViewModel: ObservableObject {
    @Published var countries: [CountryListItem] = []
    @Published var searchText = ""
    @Published var state: LoadingState = .idle
    @Published var showFavoritesOnly = false

    private let apiService: APIServiceProtocol
    private let persistenceService: PersistenceServiceProtocol
    private let context: NSManagedObjectContext
    private var hasFetched = false

    init(apiService: APIServiceProtocol, persistenceService: PersistenceServiceProtocol, context: NSManagedObjectContext) {
        self.apiService = apiService
        self.persistenceService = persistenceService
        self.context = context
    }

    var filteredCountries: [CountryListItem] {
        countries.filter { country in
            (searchText.isEmpty || country.name.common.lowercased().contains(searchText.lowercased())) &&
            (!showFavoritesOnly || country.isFavorite)
        }
        .sorted { $0.name.common.lowercased() < $1.name.common.lowercased() }
    }

    func fetchCountries() async {
        guard !hasFetched else {
            AppLogger.viewModel.info("⚠️ Skip fetch: Already fetched countries")
            return
        }

        state = .loading
        AppLogger.viewModel.info("🌍 Fetching countries from API")

        do {
            let fetchedCountries = try await apiService.fetchCountries()
            AppLogger.viewModel.debug("✅ Successfully fetched \(fetchedCountries.count) countries")

            let favoriteIds = Set(persistenceService.fetchFavorites().map { $0.id })
            countries = fetchedCountries.map { country in
                CountryListItem(
                    name: country.name,
                    capital: country.capital,
                    flags: country.flags,
                    isFavorite: favoriteIds.contains(country.id)
                )
            }

            hasFetched = true
            state = .success
        } catch {
            AppLogger.viewModel.error("❌ Failed to fetch countries: \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }
    }

    func toggleFavorite(_ country: CountryListItem) {
        guard let index = countries.firstIndex(where: { $0.id == country.id }) else { return }

        let updatedCountry = countries[index]
        updatedCountry.isFavorite.toggle()
        countries[index] = updatedCountry

        if updatedCountry.isFavorite {
            persistenceService.addFavorite(country: updatedCountry)
            AppLogger.viewModel.info("⭐ Added favorite: \(updatedCountry.name.common)")
        } else {
            persistenceService.removeFavorite(id: updatedCountry.id)
            AppLogger.viewModel.info("🗑️ Removed favorite: \(updatedCountry.name.common)")
        }

        do {
            if context.hasChanges {
                try context.save()
                AppLogger.viewModel.debug("💾 Context saved after favorite toggle")
            }
        } catch {
            AppLogger.viewModel.error("❌ Failed to save context: \(error.localizedDescription)")
        }
    }
}

