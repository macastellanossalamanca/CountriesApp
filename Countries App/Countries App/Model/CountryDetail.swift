//
//  CountryDetail.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

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
