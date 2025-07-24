//
//  AppLogger.swift
//  Countries App
//
//  Created by Temporal on 22/07/25.
//

import os
import Foundation

enum AppLogger {
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.countries.app"

    // MARK: - Categorías

    static let lifecycle = Logger(subsystem: subsystem, category: "🧬Lifecycle")
    static let network = Logger(subsystem: subsystem, category: "🌐Networking")
    static let persistence = Logger(subsystem: subsystem, category: "💾Persistence")
    static let viewModel = Logger(subsystem: subsystem, category: "📦ViewModel")
    static let coordinator = Logger(subsystem: subsystem, category: "🧭Coordinator")
    static let ui = Logger(subsystem: subsystem, category: "🖼️UI")
    static let error = Logger(subsystem: subsystem, category: "❌Error")
    static let di = Logger(subsystem: subsystem, category: "🛠️DI")
}
