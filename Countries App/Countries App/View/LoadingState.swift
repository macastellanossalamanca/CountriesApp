//
//  LoadingState.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

// MARK: - Estado de Carga
enum LoadingState {
    case idle, loading, success, error(String)
}
