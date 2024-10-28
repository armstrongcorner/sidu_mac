//
//  siduApp.swift
//  sidu
//
//  Created by Armstrong Liu on 27/08/2024.
//

import SwiftUI
import SwiftData

@main
struct siduApp: App {
    let databaseProvider = DatabaseProvider.shared
    var languageCode: String = ""
    
    init() {
        if let currentLanguage = UserDefaults.standard.string(forKey: CacheKey.currentLanguage.rawValue) {
            self.languageCode = currentLanguage
        } else {
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.languageCode = systemLanguage
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                SplashScreen()
                    .environment(ToastViewObserver())
                    .environment(AppSize(geometry.size))
                    .environment(\.locale, .init(identifier: languageCode))
//                    .environment(\.createDatabaseManager, databaseProvider.databaseManagerCreator())
                    .environment(\.createUserHandler, databaseProvider.userHandlerCreator())
                    .environment(\.createTopicHandler, databaseProvider.topicHandlerCreator())
                    .environment(\.createChatHandler, databaseProvider.chatHandlerCreator())
            }
        }
        .modelContainer(databaseProvider.sharedModelContainer)
    }
}
