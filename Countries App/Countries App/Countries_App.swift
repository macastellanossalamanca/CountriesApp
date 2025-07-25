//
//  Countries_AppApp.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

import SwiftUI

@main
struct Countries_App: App {
    @Environment(\.scenePhase) private var scenePhase
    private let dimanager = DIManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .inactive {
                dimanager.saveContext() 
            }
        }
    }
}
