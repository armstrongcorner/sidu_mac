//
//  SchemaV1.swift
//  sidu
//
//  Created by Armstrong Liu on 26/10/2024.
//

import Foundation
import SwiftData

typealias CurrentSchema = SchemaV1

enum SchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [User.self, Topic.self, Chat.self]
    }
    
    static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }
}
