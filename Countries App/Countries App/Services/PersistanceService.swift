//
//  PersistanceService.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

import CoreData

protocol PersistenceServiceProtocol {
    func addFavorite(country: CountryListItem)
    func removeFavorite(id: String)
    func isFavorite(id: String) -> Bool
    func fetchFavorites() -> [CountryFavorite]
}

final class PersistenceService: PersistenceServiceProtocol {

    static let shared = PersistenceService()

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    func addFavorite(country: CountryListItem) {
        guard !isFavorite(id: country.id) else {
            AppLogger.persistence.info("✅ Country '\(country.name.common)' already in favorites")
            return
        }

        let favorite = CountryFavorite(context: context)
        favorite.id = country.id
        favorite.nameCommon = country.name.common
        favorite.nameOfficial = country.name.official
        favorite.flagURL = country.flags.png
        favorite.capital = country.capitalString
        favorite.isFavorite = true

        saveContext()
        AppLogger.persistence.debug("✅ Added favorite: \(country.name.common)")
    }

    func removeFavorite(id: String) {
        guard let favorite = fetchFavorite(by: id) else {
            AppLogger.persistence.warning("⚠️ Attempted to remove non-existent favorite with id: \(id)")
            return
        }

        context.delete(favorite)
        saveContext()
        AppLogger.persistence.debug("🗑️ Removed favorite with id: \(id)")
    }

    func isFavorite(id: String) -> Bool {
        fetchFavorite(by: id) != nil
    }

    func fetchFavorites() -> [CountryFavorite] {
        let request: NSFetchRequest<CountryFavorite> = CountryFavorite.fetchRequest()
        do {
            let results = try context.fetch(request)
            AppLogger.persistence.info("📦 Fetched \(results.count) favorites")
            return results
        } catch {
            AppLogger.error.error("❌ Error fetching favorites: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Private Helpers

    private func fetchFavorite(by id: String) -> CountryFavorite? {
        let request: NSFetchRequest<CountryFavorite> = CountryFavorite.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            AppLogger.error.error("❌ Error saving context: \(error.localizedDescription)")
        }
    }
}

