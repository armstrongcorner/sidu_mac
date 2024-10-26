//
//  User.swift
//  sidu
//
//  Created by Armstrong Liu on 08/09/2024.
//

import SwiftData
import SwiftUI

typealias User = SchemaV1.User

extension SchemaV1 {
    @Model
    final class User {
        @Attribute(.unique) var id: Int?
        var userName: String?
        var password: String?
        var photo: String?
        var role: String?
        var mobile: String?
        var email: String?
        var serviceLevel: Int?
        var tokenDurationInMin: Int?
        var isActive: Bool?
        var createdDateTime: String?
        var updatedDateTime: String?
        var createdBy: String?
        var updatedBy: String?
        
        @Relationship(deleteRule: .cascade) var topics: [Topic]
        
        init(id: Int?, userName: String?, password: String?, photo: String?, role: String?, mobile: String?, email: String?, serviceLevel: Int?, tokenDurationInMin: Int?, isActive: Bool?, createdDateTime: String?, updatedDateTime: String?, createdBy: String?, updatedBy: String?, topics: [Topic] = []) {
            self.id = id
            self.userName = userName
            self.password = password
            self.photo = photo
            self.role = role
            self.mobile = mobile
            self.email = email
            self.serviceLevel = serviceLevel
            self.tokenDurationInMin = tokenDurationInMin
            self.isActive = isActive
            self.createdDateTime = createdDateTime
            self.updatedDateTime = updatedDateTime
            self.createdBy = createdBy
            self.updatedBy = updatedBy
            
            self.topics = topics
        }
        
        init(row: [String: Any?], topics: [Topic] = []) {
            self.id = row["id"] as? Int
            self.userName = row["userName"] as? String
            self.password = row["password"] as? String
            self.photo = row["photo"] as? String
            self.role = row["role"] as? String
            self.mobile = row["mobile"] as? String
            self.email = row["email"] as? String
            self.serviceLevel = row["serviceLevel"] as? Int
            self.tokenDurationInMin = row["tokenDurationInMin"] as? Int
            self.isActive = row["isActive"] as? Bool
            self.createdDateTime = row["createdDateTime"] as? String
            self.updatedDateTime = row["updatedDateTime"] as? String
            self.createdBy = row["createdBy"] as? String
            self.updatedBy = row["updatedBy"] as? String
            
            self.topics = topics
        }
        
        static func addUser(user: User, context: ModelContext?) throws {
            let existedUser = try fetchUser(byUsername: user.userName, context: context)
            if existedUser == nil {
                context?.insert(user)
                if context?.hasChanges ?? false {
                    try context?.save()
                }
            }
        }
        
        static func deleteUser(user: User, context: ModelContext?) throws {
            context?.delete(user)
            if context?.hasChanges ?? false {
                try context?.save()
            }
        }
        
        static func fetchUser(byUsername username: String?, context: ModelContext?) throws -> User? {
            let fetchDescriptor = FetchDescriptor<User>(predicate: #Predicate { $0.userName == username })
            let users = try? context?.fetch(fetchDescriptor)
            return users?.first
        }
    }
}
