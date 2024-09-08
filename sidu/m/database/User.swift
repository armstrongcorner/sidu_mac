//
//  User.swift
//  sidu
//
//  Created by Armstrong Liu on 08/09/2024.
//

import SwiftData
import SwiftUI

@Model
class User {
    var id: Int?
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
    
    var topics: [Topic] = []
    
    init(id: Int?, userName: String?, password: String?, photo: String?, role: String?, mobile: String?, email: String?, serviceLevel: Int?, tokenDurationInMin: Int?, isActive: Bool?, createdDateTime: String?, updatedDateTime: String?, createdBy: String?, updatedBy: String?) {
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
    }
    
    init(row: [String: Any?]) {
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
    }
    
    static func fetchUser(byUsername username: String, context: ModelContext) throws -> User? {
        let fetchDescriptor = FetchDescriptor<User>(predicate: #Predicate { $0.userName == username })
        let users = try? context.fetch(fetchDescriptor)
        return users?.first
    }
}
