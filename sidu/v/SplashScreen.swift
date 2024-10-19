//
//  SplashScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import SwiftUI

struct SplashScreen: View {
    @State private var path: [Route] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Spacer(minLength: 50)
                HStack {
                    Spacer(minLength: 50)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer(minLength: 50)
                }
                Spacer(minLength: 50)
            }
            .navigationDestination(for: Route.self) { value in
                getViewByRoute(value)
            }
        }
        .onAppear() {
            Task {
                if await CacheUtil.shared.getAuthInfo() != nil {
                    path.append(.chatScreen)
                } else {
                    path.append(.loginScreen)
                }
            }
        }
        .environment(\.myRoute, $path)
    }
}

#Preview {
    SplashScreen()
        .environment(ToastViewObserver())
}
