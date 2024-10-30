//
//  UserHandler.swift
//  sidu
//
//  Created by Armstrong Liu on 28/10/2024.
//

import Foundation
import SwiftData

@ModelActor
actor UserHandler {
    private var context: ModelContext { modelExecutor.modelContext }
    
    init(container: ModelContainer) {
        self.modelContainer = container
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(container))
    }
    
    @discardableResult
    func addUser(data: UserInfoModel) throws -> PersistentIdentifier {
        let user = User(row: data.toDictionary())
        context.insert(user)
        if context.hasChanges {
            try context.save()
        }
        
        return user.persistentModelID
    }
    
    @discardableResult
    func addUserIfNeeded(data: UserInfoModel, predicate: Predicate<User>) throws -> PersistentIdentifier {
        let user = User(row: data.toDictionary())
        
        let descriptor = FetchDescriptor(predicate: predicate)
        let savedCount = try context.fetchCount(descriptor)
        
        if savedCount == 0 {
            context.insert(user)
        }
        if context.hasChanges {
            try context.save()
        }
        
        return user.persistentModelID
    }

    func fetchUserPersistentId(byUsername username: String) throws -> PersistentIdentifier? {
        let fetchDescriptor = FetchDescriptor<User>(predicate: #Predicate { $0.userName == username })
        let users = try context.fetch(fetchDescriptor)
        return users.first?.persistentModelID
    }
    
    func fetchUser(byUsername username: String) throws -> UserInfoModel? {
        let fetchDescriptor = FetchDescriptor<User>(predicate: #Predicate { $0.userName == username })
        let users = try context.fetch(fetchDescriptor)
        if let user = users.first {
            return UserInfoModel(
                id: user.id,
                userName: user.userName,
                password: user.password,
                photo: user.photo,
                role: user.role,
                mobile: user.mobile,
                email: user.email,
                serviceLevel: user.serviceLevel,
                tokenDurationInMin: user.tokenDurationInMin,
                isActive: user.isActive,
                createdDateTime: user.createdDateTime,
                updatedDateTime: user.updatedDateTime,
                createdBy: user.createdBy,
                updatedBy: user.updatedBy
            )
        }
        return nil
    }

    func updateUser(id: PersistentIdentifier, data: UserInfoModel) throws {
        guard let user = self[id, as: User.self] else { return }
        
        user.userName = data.userName
        user.password = data.password
        user.photo = data.photo
        user.role = data.role
        user.mobile = data.mobile
        user.email = data.email
        user.serviceLevel = data.serviceLevel
        user.tokenDurationInMin = data.tokenDurationInMin
        user.isActive = data.isActive
        user.createdDateTime = data.createdDateTime
        user.updatedDateTime = data.updatedDateTime
        user.createdBy = data.createdBy
        user.updatedBy = data.updatedBy
        
        try context.save()
    }
    
    func deleteUser(id: PersistentIdentifier) throws {
        guard let user = self[id, as: User.self] else { return }
        context.delete(user)
        if context.hasChanges {
            try context.save()
        }
    }
    
    func deleteUser(byUsername username: String) throws {
        try context.delete(model: User.self, where: #Predicate { $0.userName == username })
        if context.hasChanges {
            try context.save()
        }
    }
}
