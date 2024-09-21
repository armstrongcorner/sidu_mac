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
            }
        }
        .modelContainer(for: [User.self, Topic.self, Chat.self])
    }
}
