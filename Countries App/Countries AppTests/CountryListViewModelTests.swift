//
//  Countries_AppApp.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

import XCTest
import CoreData
@testable import Countries_App

final class CountryListViewModelTests: XCTestCase {

}

// MARK: - Mocks
final class MockAPIService {

    var shouldFail = false
    var mockCountries: [CountryListItem] = []
    
    func fetchCountries() async throws -> [CountryListItem] {
        if shouldFail {
            throw URLError(.badServerResponse)
        }
        return mockCountries
    }
    
    func fetchDetail(for id: String) async throws -> CountryDetail {
        throw URLError(.unsupportedURL)
    }
}

final class MockPersistenceService: PersistenceServiceProtocol {
    var favorites: [CountryFavorite] = []

    func addFavorite(country: CountryListItem) {
        let fav = CountryFavorite(context: CoreDataManager.shared.context)
        fav.id = country.id
        favorites.append(fav)
    }
    
    func removeFavorite(id: String) {
        favorites.removeAll { $0.id == id }
    }
    
    func isFavorite(id: String) -> Bool {
        favorites.contains(where: { $0.id == id })
    }
    
    func fetchFavorites() -> [CountryFavorite] {
        favorites
    }
}



