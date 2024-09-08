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
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                SplashScreen()
                    .environment(ToastViewObserver())
                    .environment(AppSize(geometry.size))
                    .environment(\.locale, .init(identifier: "zh-Hans"))
            }
        }
        .modelContainer(for: [User.self, Topic.self, Chat.self])
    }
}
