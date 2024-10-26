//
//  BackgroundSerialPersistenceActor.swift
//  sidu
//
//  Created by Armstrong Liu on 06/10/2024.
//

import Foundation
import SwiftData

/// ```swift
///  // It is important that this actor works as a mutex,
///  // so you must have one instance of the Actor for one container
//   // for it to work correctly.
///  let actor = DatabaseManager(container: modelContainer)
///
///  Task {
///      let data: [MyModel] = try? await actor.fetchData()
///  }
///  ```
@available(iOS 17, *)
@ModelActor
actor DatabaseManager {
    private var context: ModelContext { modelExecutor.modelContext }
    
    init(container: ModelContainer) {
        self.modelContainer = container
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(container))
    }
    
    // C
    func insert<T: PersistentModel>(data: T) throws -> PersistentIdentifier {
        let context = data.modelContext ?? context
        context.insert(data)
        if context.hasChanges {
            try context.save()
        }
        
        return data.persistentModelID
    }
    
    func insertIfNeeded<T: PersistentModel>(
        data: T,
        predicate: Predicate<T>
    ) throws -> PersistentIdentifier {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        let context = data.modelContext ?? context
        let savedCount = try context.fetchCount(descriptor)
        
        if savedCount == 0 {
            context.insert(data)
        }
        if context.hasChanges {
            try context.save()
        }
        
        return data.persistentModelID
    }
    
    // R
    func fetchData<T: PersistentModel>(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> [T] {
        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        let list: [T] = try context.fetch(fetchDescriptor)
        return list
    }
    
    func fetchCount<T: PersistentModel>(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> Int {
        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        let count = try context.fetchCount(fetchDescriptor)
        return count
    }
    
    // U
    func update<T: PersistentModel>(data: T) throws {
        let context = data.modelContext ?? context
        if context.hasChanges {
            try context.save()
        }
    }
    
    // D
    func delete<T: PersistentModel>(predicate: Predicate<T>? = nil) throws {
        try context.delete(model: T.self, where: predicate)
        if context.hasChanges {
            try context.save()
        }
    }
    
    func delete<T: PersistentModel>(data: T) throws {
        context.delete(data)
        if context.hasChanges {
            try context.save()
        }
    }
    
    func delete<T: PersistentModel>(id: PersistentIdentifier, type: T.Type) throws {
        guard let data = self[id, as: type] else { return }
        context.delete(data)
        if context.hasChanges {
            try context.save()
        }
    }
}
