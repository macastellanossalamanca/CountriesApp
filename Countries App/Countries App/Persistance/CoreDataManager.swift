//
//  CoreDataManager.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

import Foundation
import CoreData

// MARK: - CoreData Manager

final class CoreDataManager {
    
    // MARK: - Singleton

    static let shared = CoreDataManager()

    // MARK: - Core Data Stack

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Init

    private init() {
        persistentContainer = NSPersistentContainer(name: "Countries_App")

        AppLogger.persistence.debug("Inicializando CoreData stack...")

        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                AppLogger.persistence.critical("❌ Error al cargar el store de CoreData: \(error.localizedDescription)")
                return
            }
            AppLogger.persistence.info("✅ CoreData cargado correctamente: \(description.url?.absoluteString ?? "Sin URL")")
        }
    }

    // MARK: - Save Context

    func saveContext() {
        guard context.hasChanges else {
            AppLogger.persistence.debug("No hay cambios en el contexto para guardar.")
            return
        }

        do {
            try context.save()
            AppLogger.persistence.info("💾 Contexto de CoreData guardado exitosamente.")
        } catch {
            AppLogger.persistence.error("❌ Error al guardar el contexto: \(error.localizedDescription)")
        }
    }
}


