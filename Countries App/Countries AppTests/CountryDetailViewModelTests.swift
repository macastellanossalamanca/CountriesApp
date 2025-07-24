//
//  CountryDetailViewModelTests.swift
//  Countries App
//
//  Created by Temporal on 22/07/25.
//
import XCTest
import CoreData
@testable import Countries_App

@MainActor
final class CountryDetailViewModelTests: XCTestCase {
    
    private var apiMock: MockAPIService!
    private var persistenceMock: MockPersistenceService!
    private var viewContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        apiMock = MockAPIService()
        persistenceMock = MockPersistenceService()
        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }

    func test_CountryDetailViewModel_fetchSuccess() async {
        let detail = CountryDetail(
            name: .init(common: "Argentina", official: "República Argentina", nativeName: nil),
            region: "Americas",
            subregion: "South America",
            capital: ["Buenos Aires"],
            timezones: ["UTC-3"],
            population: 45000000,
            languages: ["es": "Spanish"],
            currencies: ["ARS": .init(name: "Peso", symbol: "$")],
            car: .init(side: "right"),
            flags: .init(png: "flag.png", svg: "flag.svg"),
            coatOfArms: nil
        )
        apiMock.countryDetailToReturn = detail

        let countryListVM = CountryListViewModel(apiService: apiMock, persistenceService: persistenceMock)
        let detailVM = CountryDetailViewModel(apiService: apiMock, countryListViewModel: countryListVM)

        await detailVM.fetchCountryDetail(name: "Argentina")

        XCTAssertEqual(detailVM.state, .success)
        XCTAssertEqual(detailVM.countryDetail?.name.common, "Argentina")
    }

    func test_CountryDetailViewModel_fetchFailure() async {
        apiMock.shouldThrowError = true

        let countryListVM = CountryListViewModel(apiService: apiMock, persistenceService: persistenceMock)
        let detailVM = CountryDetailViewModel(apiService: apiMock, countryListViewModel: countryListVM)

        await detailVM.fetchCountryDetail(name: "FakeLand")

        XCTAssertEqual(detailVM.state, .error("Mock Detail Error"))
    }
}

