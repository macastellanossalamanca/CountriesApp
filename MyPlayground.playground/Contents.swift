import Foundation
import SwiftUI

// MARK: - Coordinador
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func showCountryDetail(_ country: CountryListItem) {
        path.append(country)
    }
}

struct CountryDetail: Codable {
    let name: Name
    let region: String
    let subregion: String?
    let capital: [String]?
    let timezones: [String]
    let population: Int
    let languages: [String: String]
    let currencies: [String: Currency]
    let car: Car
    let flags: Flags
    let coatOfArms: CoatOfArms?
    
    struct Name: Codable {
        let common: String
        let official: String
        let nativeName: [String: NativeName]?
        
        struct NativeName: Codable {
            let official: String
            let common: String
        }
    }
    
    struct Currency: Codable {
        let name: String
        let symbol: String
    }
    
    struct Car: Codable {
        let side: String
    }
    
    struct Flags: Codable {
        let png: String
        let svg: String
    }
    
    struct CoatOfArms: Codable {
        let png: String?
        let svg: String?
    }
    
    var capitalString: String { capital?.joined(separator: ", ") ?? "N/A" }
    var languagesString: String { languages.values.joined(separator: ", ") }
    var currenciesString: String { currencies.values.map { "\($0.name) (\($0.symbol))" }.joined(separator: ", ") }
}


// MARK: - Modelos de Datos
struct CountryListItem: Codable, Identifiable, Hashable {
    let name: Name
    let capital: [String]?
    let flags: Flags
    
    struct Name: Codable, Hashable {
        let common: String
        let official: String
    }
    
    struct Flags: Codable, Hashable {
        let png: String
        let alt: String?
    }
    
    var id: String { name.common }
    var capitalString: String { capital?.joined(separator: ", ") ?? "N/A" }
}

import CoreData

// MARK: - CoreData Manager
final class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext { persistentContainer.viewContext }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Countries_App")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error { fatalError("Failed to load CoreData: \(error)") }
        }
    }
}

// MARK: - Servicios
protocol APIServiceProtocol {
    func fetchCountries() async throws -> [CountryListItem]
    func fetchCountryDetail(name: String) async throws -> CountryDetail
}

final class APIService: APIServiceProtocol {
    private let baseURL = "https://restcountries.com/v3.1"
    
    func fetchCountries() async throws -> [CountryListItem] {
        let url = URL(string: "\(baseURL)/all?fields=name,capital,flags")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([CountryListItem].self, from: data)
    }
    
    func fetchCountryDetail(name: String) async throws -> CountryDetail {
        let url = URL(string: "\(baseURL)/name/\(name)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let countries = try JSONDecoder().decode([CountryDetail].self, from: data)
        guard let country = countries.first else {
            throw NSError(domain: "No country found", code: 404, userInfo: nil)
        }
        return country
    }
}

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
        let favorite = CountryFavorite(context: context)
        favorite.id = country.id
        favorite.nameCommon = country.name.common
        favorite.nameOfficial = country.name.official
        favorite.flagURL = country.flags.png
        favorite.capital = country.capitalString
        try? context.save()
    }
    
    func removeFavorite(id: String) {
        let fetchRequest: NSFetchRequest<CountryFavorite> = CountryFavorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        if let result = try? context.fetch(fetchRequest), let favorite = result.first {
            context.delete(favorite)
            try? context.save()
        }
    }
    
    func isFavorite(id: String) -> Bool {
        let fetchRequest: NSFetchRequest<CountryFavorite> = CountryFavorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let count = try? context.count(for: fetchRequest)
        return count ?? 0 > 0
    }
    
    func fetchFavorites() -> [CountryFavorite] {
        let fetchRequest: NSFetchRequest<CountryFavorite> = CountryFavorite.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching favorites: \(error.localizedDescription)")
            return []
        }
    }
}

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TabView {
                CountryListView(coordinator: coordinator)
                    .tabItem { Label("Search", systemImage: "globe") }
                FavoritesView(coordinator: coordinator)
                    .tabItem { Label("Saved", systemImage: "star") }
            }
            .navigationDestination(for: CountryListItem.self) { country in
                CountryDetailView(country: country)
            }
        }
    }
    
}

#Preview {
    ContentView()
}

struct CountryDetailView: View {
    @StateObject private var viewModel: CountryDetailViewModel
    let country: CountryListItem
    
    init(country: CountryListItem) {
        _viewModel = StateObject(wrappedValue: CountryDetailViewModel())
        self.country = country
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                AsyncImage(url: URL(string: country.flags.png)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 100)
                
                switch viewModel.state {
                case .loading:
                    ProgressView()
                case .error(let message):
                    Text("Error: \(message)")
                case .idle, .success:
                    if let detail = viewModel.country {
                        Text("Region: \(detail.region)").font(.headline)
                        if let subregion = detail.subregion { Text("Subregion: \(subregion)") }
                        Text("Capital: \(detail.capitalString)")
                        Text("Timezones: \(detail.timezones.joined(separator: ", "))")
                        Text("Population: \(detail.population)")
                        Text("Languages: \(detail.languagesString)")
                        Text("Currencies: \(detail.currenciesString)")
                        Text("Driving Side: \(detail.car.side)")
                        
                        if let coatURL = detail.coatOfArms?.png {
                            AsyncImage(url: URL(string: coatURL)) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 100)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(country.name.common)
        .task { await viewModel.fetchCountryDetail(name: country.name.common) }
    }
}

struct CountryListView: View {
    @StateObject private var viewModel: CountryListViewModel
    @ObservedObject var coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: CountryListViewModel())
        self.coordinator = coordinator
    }
    
    var body: some View {
        VStack {
            TextField("Search", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .error(let message):
                Text("Error: \(message)")
            case .idle, .success:
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.filteredCountries) { country in
                            CountryRow(country: country, isFavorite: viewModel.isFavorite(country.id)) {
                                viewModel.toggleFavorite(country)
                            }
                            .onTapGesture { coordinator.showCountryDetail(country) }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Countries")
        .task { await viewModel.fetchCountries() }
    }
}

struct CountryRow: View {
    let country: CountryListItem
    let isFavorite: Bool
    let toggleFavorite: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: country.flags.png)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 30)
            
            VStack(alignment: .leading) {
                Text(country.name.common).font(.headline)
                Text(country.name.official).font(.subheadline).foregroundColor(.gray)
                Text(country.capitalString).font(.caption)
            }
            
            Spacer()
            
            Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                .foregroundColor(.blue)
                .onTapGesture { toggleFavorite() }
        }
        .padding(.vertical, 5)
    }
}

struct FavoritesView: View {
    @ObservedObject var coordinator: AppCoordinator
    private let persistenceService: PersistenceServiceProtocol
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.persistenceService = PersistenceService()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(persistenceService.fetchFavorites(), id: \.id) { favorite in
                    CountryRow(
                        country: CountryListItem(
                            name: .init(common: favorite.nameCommon!, official: favorite.nameOfficial!),
                            capital: [favorite.capital!],
                            flags: .init(png: favorite.flagURL!, alt: nil)
                        ),
                        isFavorite: true,
                        toggleFavorite: { persistenceService.removeFavorite(id: favorite.id!) }
                    )
                    .onTapGesture { coordinator.showCountryDetail(CountryListItem(
                        name: .init(common: favorite.nameCommon!, official: favorite.nameOfficial!),
                        capital: [favorite.capital!],
                        flags: .init(png: favorite.flagURL!, alt: nil)
                    )) }
                }
            }
            .padding()
        }
        .navigationTitle("Favorites")
    }
}

// MARK: - Estado de Carga
enum LoadingState {
    case idle, loading, success, error(String)
}

@main
struct Countries_App: App {
    let context = CoreDataManager.shared.context
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
        }
    }
}
