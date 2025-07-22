//
//  ApiService.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

import Foundation

// MARK: - API Service Protocol

protocol APIServiceProtocol {
    func fetchCountries() async throws -> [CountryListItem]
    func fetchCountryDetail(name: String) async throws -> CountryDetail
}

// MARK: - API Service Implementation

final class APIService: APIServiceProtocol {

    // MARK: - Properties

    private let baseURL = "https://restcountries.com/v3.1"
    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Init

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }

    // MARK: - Public API Methods

    func fetchCountries() async throws -> [CountryListItem] {
        guard let url = URL(string: "\(baseURL)/all?fields=name,capital,flags") else {
            AppLogger.network.error("❌ URL inválida para fetchCountries")
            throw URLError(.badURL)
        }

        AppLogger.network.debug("🌍 Iniciando fetch de países desde: \(url.absoluteString)")

        let data = try await performRequest(url: url)
        let countries = try decoder.decode([CountryListItem].self, from: data)

        AppLogger.network.info("✅ Se cargaron \(countries.count) países")
        return countries
    }

    func fetchCountryDetail(name: String) async throws -> CountryDetail {
        guard let url = URL(string: "\(baseURL)/name/\(name)") else {
            AppLogger.network.error("❌ URL inválida para fetchCountryDetail: \(name)")
            throw URLError(.badURL)
        }

        AppLogger.network.debug("🔎 Obteniendo detalles para: \(name)")

        let data = try await performRequest(url: url)
        let countries = try decoder.decode([CountryDetail].self, from: data)

        guard let country = countries.first else {
            AppLogger.network.warning("⚠️ No se encontró el país con nombre: \(name)")
            throw NSError(domain: "CountryDetail", code: 404, userInfo: [NSLocalizedDescriptionKey: "No se encontró el país"])
        }

        AppLogger.network.info("✅ Detalles cargados para país: \(country.name.common)")
        return country
    }

    // MARK: - Private Helpers

    /// Realiza una petición y valida la respuesta HTTP.
    private func performRequest(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.network.error("❌ Respuesta inválida del servidor para: \(url)")
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            AppLogger.network.error("❌ Código de estado HTTP inesperado: \(httpResponse.statusCode)")
            throw URLError(.init(rawValue: httpResponse.statusCode))
        }

        AppLogger.network.debug("📦 Respuesta recibida con código: \(httpResponse.statusCode)")
        return data
    }
}

