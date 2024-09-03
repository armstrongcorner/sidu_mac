//
//  siduApp.swift
//  sidu
//
//  Created by Armstrong Liu on 27/05/2024.
//

import SwiftUI

@main
struct siduApp: App {
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                LoginScreen()
                    .environment(ToastViewObserver())
                    .environment(AppSize(geometry.size))
            }
        }
    }
}
