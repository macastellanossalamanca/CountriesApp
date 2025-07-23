//
//  Countries_AppUITests.swift
//  Countries AppUITests
//
//  Created by Temporal on 20/07/25.
//

import XCTest
import SwiftUI
import ViewInspector
import CoreData
@testable import Countries_App
@testable import Countries_AppTests


@MainActor
final class CountryListViewTests: XCTestCase {

//    func testRendersCountryRows() throws {
//        let mockCountry = CountryListItem(
//            name: .init(common: "Colombia", official: "República de Colombia"),
//            capital: ["Bogotá"],
//            flags: .init(png: "https://flagcdn.com/w320/co.png", alt: nil),
//            isFavorite: true
//        )
//
//        let viewModel = CountryListViewModel(
//            apiService: MockAPIService(),
//            persistenceService: MockPersistenceService(),
//            context: NSPersistentContainer(name: "Countries_App").viewContext
//        )
//        viewModel.countries = [mockCountry]
//
//        let coordinator = AppCoordinator()
//        let view = CountryListView(coordinator: coordinator, viewModel: viewModel)
//
//        XCTAssertNoThrow(try view.inspect().find(viewWithId: mockCountry.id))
//    }
//
//    func testFavoriteToggleButtonExists() throws {
//        let mockCountry = CountryListItem(
//            name: .init(common: "Perú", official: "República del Perú"),
//            capital: ["Lima"],
//            flags: .init(png: "https://flagcdn.com/w320/pe.png", alt: nil),
//            isFavorite: false
//        )
//
//        let row = CountryRow(
//            country: mockCountry,
//            toggleFavorite: { },
//            coordinator: AppCoordinator()
//        )
//
//        let button = try row.inspect().find(ViewType.Button.self)
//        XCTAssertNotNil(button)
//    }
}
