//
//  ContainerForTest.swift
//  siduTests
//
//  Created by Armstrong Liu on 21/01/2025.
//

@testable import sidu
import Foundation
import SwiftData

class ContainerForTest {
    static func createTestContainer(databaseName name: String) throws -> ModelContainer {
        do {
            let url = URL.temporaryDirectory.appending(component: name)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            
            let schema = Schema(CurrentSchema.models)
            let modelConfiguration = ModelConfiguration(url: url)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            return container
        } catch {
            fatalError("Failed to create ModelContainer for test: \(error)")
        }
    }
}
