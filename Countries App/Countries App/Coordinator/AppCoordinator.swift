//
//  AppCoordinator.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

import SwiftUI

/// Coordinador principal de navegación de la app.
final class AppCoordinator: ObservableObject {

    @Published var path = NavigationPath()

    func showCountryDetail(_ country: CountryListItem) {
        AppLogger.coordinator.info("Navegando a detalle de país: \(country.name.common)")
        path.append(country)
    }

    func pop() {
        guard !path.isEmpty else {
            AppLogger.coordinator.warning("Intento de pop fallido: el path ya está vacío.")
            return
        }

        AppLogger.coordinator.debug("Volviendo una pantalla atrás")
        path.removeLast()
    }

    func popToRoot() {
        guard !path.isEmpty else {
            AppLogger.coordinator.debug("Intento de popToRoot ignorado: ya estamos en la raíz.")
            return
        }

        AppLogger.coordinator.debug("Volviendo al root del stack")
        path.removeLast(path.count)
    }
}

