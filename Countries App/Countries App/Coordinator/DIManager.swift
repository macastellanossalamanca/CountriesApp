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

    private let persistentContainer: NSPersistentContainer

    /// Contexto principal del contenedor persistente (usado por los servicios de persistencia y vistas)
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private lazy var countryListViewModel: CountryListViewModel = {
        AppLogger.di.debug("Inicializando CountryListViewModel desde DIManager")
        return CountryListViewModel(
            apiService: makeAPIService(),
            persistenceService: makePersistenceService(),
            context: context
        )
    }()

    private init() {
        persistentContainer = NSPersistentContainer(name: "Countries_App")

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                AppLogger.di.error("Error cargando el stack de Core Data: \(error.localizedDescription)")
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            } else {
                AppLogger.di.info("Stack de Core Data cargado exitosamente.")
            }
        }
    }

    func saveContext() {
        guard context.hasChanges else {
            AppLogger.di.debug("No hay cambios en el contexto, no es necesario guardar.")
            return
        }

        do {
            try context.save()
            AppLogger.di.info("Contexto guardado exitosamente.")
        } catch {
            AppLogger.di.error("Fallo al guardar el contexto: \(error.localizedDescription)")
        }
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
        return PersistenceService(context: context)
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
}

