//
//  CountryDetailViewModel.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//
import SwiftUI
import Combine

@MainActor
final class CountryDetailViewModel: ObservableObject {
    @Published var countryDetail: CountryDetail?
    @Published var state: LoadingState = .idle
    private let apiService: APIServiceProtocol
    private let countryListViewModel: CountryListViewModel
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol, countryListViewModel: CountryListViewModel) {
        self.apiService = apiService
        self.countryListViewModel = countryListViewModel
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        countryListViewModel.$countries
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func fetchCountryDetail(name: String) async {
        state = .loading
        do {
            countryDetail = try await apiService.fetchCountryDetail(name: name)
            state = .success
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func isFavorite(_ id: String) -> Bool {
        countryListViewModel.countries.first { $0.id == id }?.isFavorite ?? false
    }

    func toggleFavorite(_ country: CountryListItem) {
        countryListViewModel.toggleFavorite(country)
    }
}
