//
//  DIManager.swift
//  Countries App
//
//  Created by Temporal on 21/07/25.
//

import Foundation
import CoreData

@MainActor
final class DIManager {
    static let shared = DIManager()

    private lazy var countryListViewModel: CountryListViewModel = {
        AppLogger.di.debug("Inicializando CountryListViewModel desde DIManager")
        return CountryListViewModel(
            apiService: makeAPIService(),
            persistenceService: makePersistenceService()
        )
    }()

    private init() {}

    func saveContext() {
        CoreDataManager.shared.saveContext()
    }

    // MARK: - Factories

    /// Servicio de red
    func makeAPIService() -> APIServiceProtocol {
        AppLogger.di.debug("Creando instancia de APIService")
        return APIService()
    }

    /// Servicio de persistencia
    func makePersistenceService() -> PersistenceServiceProtocol {
        AppLogger.di.debug("Creando instancia de PersistenceService")
        return PersistenceService(context: CoreDataManager.shared.context)
    }

    /// Retorna una instancia compartida del `CountryListViewModel`
    func getCountryListViewModel() -> CountryListViewModel {
        AppLogger.di.debug("Retornando instancia compartida de CountryListViewModel")
        return countryListViewModel
    }

    /// Crea una nueva instancia del `CountryDetailViewModel
    func makeCountryDetailViewModel() -> CountryDetailViewModel {
        AppLogger.di.debug("Creando instancia nueva de CountryDetailViewModel")
        return CountryDetailViewModel(
            apiService: makeAPIService(),
            countryListViewModel: getCountryListViewModel()
        )
    }
    
    func makeAppCoordinator() -> AppCoordinator {
        return AppCoordinator()
    }
}

