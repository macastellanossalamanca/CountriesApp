//
//  CountryListItem.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

// MARK: - Modelos de Datos
import Foundation

class CountryListItem: Codable, Identifiable, Hashable {
    let name: Name
    let capital: [String]?
    let flags: Flags
    var isFavorite: Bool = false

    init(name: Name, capital: [String]?, flags: Flags, isFavorite: Bool = false) {
        self.name = name
        self.capital = capital
        self.flags = flags
        self.isFavorite = isFavorite
    }

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

    enum CodingKeys: String, CodingKey {
        case name
        case capital
        case flags
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CountryListItem, rhs: CountryListItem) -> Bool {
        lhs.id == rhs.id
    }
}
