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
    
    @AppStorage(CacheKey.currentLanguage.rawValue) var selectedLanguageCode = "en"
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                SplashScreen()
                    .environment(ToastViewObserver())
                    .environment(AppSize(geometry.size))
                    .environment(\.locale, .init(identifier: selectedLanguageCode))
                    .environment(\.createUserHandler, databaseProvider.userHandlerCreator())
                    .environment(\.createTopicHandler, databaseProvider.topicHandlerCreator())
                    .environment(\.createChatHandler, databaseProvider.chatHandlerCreator())
            }
        }
        .modelContainer(databaseProvider.sharedModelContainer)
    }
}
