//
//  Route.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import SwiftUI

enum Route: Hashable {
    case splashScreen
    case loginScreen
    case emailRegisterScreen
    case completeRegisterScreen(email: String)
    case chatScreen
    case liveChatScreen
}

private struct MyRouteKey: EnvironmentKey {
    static let defaultValue: Binding<[Route]> = .constant([])
}

extension EnvironmentValues {
    var myRoute: Binding<[Route]> {
        get { self[MyRouteKey.self] }
        set { self[MyRouteKey.self] = newValue }
    }
}

@MainActor var getViewByRoute: (Route) -> AnyView = { route in
    switch route {
    case .splashScreen:
        return AnyView(SplashScreen())
    case .loginScreen:
        return AnyView(LoginScreen())
    case .emailRegisterScreen:
        return AnyView(EmailRegisterScreen())
    case .completeRegisterScreen(let email):
        return AnyView(CompleteRegisterScreen(email: email))
    case .chatScreen:
        return AnyView(ChatScreen())
    case .liveChatScreen:
        return AnyView(LiveChatScreen())
    }
}
