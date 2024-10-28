//
//  DatabaseProvider.swift
//  sidu
//
//  Created by Armstrong Liu on 26/10/2024.
//

import Foundation
import SwiftData
import SwiftUI

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
            fatalError("Failed to create ModelContainer for preview: \(error)")
        }
    }()
    
    init() {}
    
    func databaseManagerCreator(preview: Bool = false) -> @Sendable () async -> DatabaseManager {
        let container = preview ? previewContainer : sharedModelContainer
        return { DatabaseManager(container: container) }
    }
    
    func userHandlerCreator(preview: Bool = false) -> @Sendable () async -> UserHandler {
        let container = preview ? previewContainer : sharedModelContainer
        return { UserHandler(container: container) }
    }
    
    func topicHandlerCreator(preview: Bool = false) -> @Sendable () async -> TopicHandler {
        let container = preview ? previewContainer : sharedModelContainer
        return { TopicHandler(container: container) }
    }
    
    func chatHandlerCreator(preview: Bool = false) -> @Sendable () async -> ChatHandler {
        let container = preview ? previewContainer : sharedModelContainer
        return { ChatHandler(container: container) }
    }
}

struct DatabaseManagerKey: EnvironmentKey {
    static let defaultValue: @Sendable () async -> DatabaseManager? = { nil }
}

extension EnvironmentValues {
    var createDatabaseManager: @Sendable () async -> DatabaseManager? {
        get { self[DatabaseManagerKey.self] }
        set { self[DatabaseManagerKey.self] = newValue }
    }
}

struct UserHandlerKey: EnvironmentKey {
    static let defaultValue: @Sendable () async -> UserHandler? = { nil }
}

extension EnvironmentValues {
    var createUserHandler: @Sendable () async -> UserHandler? {
        get { self[UserHandlerKey.self] }
        set { self[UserHandlerKey.self] = newValue }
    }
}

struct TopicHandlerKey: EnvironmentKey {
    static let defaultValue: @Sendable () async -> TopicHandler? = { nil }
}

extension EnvironmentValues {
    var createTopicHandler: @Sendable () async -> TopicHandler? {
        get { self[TopicHandlerKey.self] }
        set { self[TopicHandlerKey.self] = newValue }
    }
}

struct ChatHandlerKey: EnvironmentKey {
    static let defaultValue: @Sendable () async -> ChatHandler? = { nil }
}

extension EnvironmentValues {
    var createChatHandler: @Sendable () async -> ChatHandler? {
        get { self[ChatHandlerKey.self] }
        set { self[ChatHandlerKey.self] = newValue }
    }
}
