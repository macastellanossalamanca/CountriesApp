//
//  MockServices.swift
//  Countries App
//
//  Created by Temporal on 22/07/25.
//

import Foundation
import CoreData
@testable import Countries_App

final class MockAPIService: APIServiceProtocol {
    var countriesToReturn: [CountryListItem] = []
    var countryDetailToReturn: CountryDetail?
    var shouldThrowError = false

    func fetchCountries() async throws -> [CountryListItem] {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock API Error"])
        }
        return countriesToReturn
    }

    func fetchCountryDetail(name: String) async throws -> CountryDetail {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock Detail Error"])
        }
        guard let detail = countryDetailToReturn else {
            throw NSError(domain: "TestError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No Detail Found"])
        }
        return detail
    }
}

final class MockPersistenceService: PersistenceServiceProtocol {
    var favorites: [CountryFavorite] = []
    
    func addFavorite(country: CountryListItem) {
        let fav = CountryFavorite(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        fav.id = country.id
        favorites.append(fav)
    }

    func removeFavorite(id: String) {
        favorites.removeAll { $0.id == id }
    }

    func isFavorite(id: String) -> Bool {
        favorites.contains { $0.id == id }
    }

    func fetchFavorites() -> [CountryFavorite] {
        return favorites
    }
}
