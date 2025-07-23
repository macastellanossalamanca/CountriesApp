//
//  LoadingState.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

// MARK: - Estado de Carga
enum LoadingState: Equatable {
    case idle
    case loading
    case success
    case error(String)

    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
