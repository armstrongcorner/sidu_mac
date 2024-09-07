//
//  RouteCoordinator.swift
//  sidu
//
//  Created by Armstrong Liu on 06/09/2024.
//

import SwiftUI
import Combine

@Observable
class RouteCoordinator {
    var path: [Route] = []
//    var path = NavigationPath()
    
    // Define a passthrough subject to handle 401 token expired error
    let tokenExpiredSubject = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Subscribe to the tokenExpiredSubject
        tokenExpiredSubject
            .sink { [weak self] _ in
                self?.navigateToLoginScreen()
            }
            .store(in: &cancellables)
    }
    
    // Navigate to login screen
    func navigateToLoginScreen() {
        // Clear all the routes, and navigate to login screen
        path.removeLast(path.count)
        path.append(Route.loginScreen)
    }
}
