//
//  DatabaseProvider.swift
//  sidu
//
//  Created by Armstrong Liu on 26/10/2024.
//

import Foundation
import SwiftData

final class DatabaseProvider: Sendable {
    static let shared = DatabaseProvider()
    
    let sharedModelContainer: ModelContainer = {
        let schema = Schema(CurrentSchema.models)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    let previewContainer: ModelContainer = {
        let schema = Schema(CurrentSchema.models)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    init() {}
    
    func databaseManagerCreator(preview: Bool = false) -> DatabaseManager {
        let container = preview ? previewContainer : sharedModelContainer
        return DatabaseManager(container: container)
    }
}
