//
//  Countries_AppApp.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

import XCTest
import CoreData
@testable import Countries_App

@MainActor
final class CountryListViewModelTests: XCTestCase {
    
    private var apiMock: MockAPIService!
    private var persistenceMock: MockPersistenceService!
    private var viewContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        apiMock = MockAPIService()
        persistenceMock = MockPersistenceService()
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }

    func test_CountryListViewModel_fetchSuccess() async {
        let sampleCountry = CountryListItem(
            name: .init(common: "Colombia", official: "República de Colombia"),
            capital: ["Bogotá"],
            flags: .init(png: "flag.png", alt: nil)
        )
        apiMock.countriesToReturn = [sampleCountry]

        let viewModel = CountryListViewModel(
            apiService: apiMock,
            persistenceService: persistenceMock
        )

        await viewModel.fetchCountries()
        
        XCTAssertEqual(viewModel.countries.count, 1)
        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(viewModel.countries.first?.name.common, "Colombia")
    }

    func test_CountryListViewModel_fetchFailure() async {
        apiMock.shouldThrowError = true

        let viewModel = CountryListViewModel(
            apiService: apiMock,
            persistenceService: persistenceMock
        )

        await viewModel.fetchCountries()

        XCTAssertEqual(viewModel.state, .error("Mock API Error"))
        XCTAssertEqual(viewModel.countries.count, 0)
    }

    func test_CountryListViewModel_toggleFavorite() {
        let country = CountryListItem(
            name: .init(common: "Chile", official: "República de Chile"),
            capital: ["Santiago"],
            flags: .init(png: "flag.png", alt: nil)
        )

        let viewModel = CountryListViewModel(
            apiService: apiMock,
            persistenceService: persistenceMock
        )
        viewModel.countries = [country]

        viewModel.toggleFavorite(country)
        XCTAssertTrue(viewModel.countries[0].isFavorite)
        XCTAssertTrue(persistenceMock.isFavorite(id: country.id))

        viewModel.toggleFavorite(country)
        XCTAssertFalse(viewModel.countries[0].isFavorite)
        XCTAssertFalse(persistenceMock.isFavorite(id: country.id))
    }
}

