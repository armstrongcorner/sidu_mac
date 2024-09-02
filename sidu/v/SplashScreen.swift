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
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SplashScreen()
}
