//
//  LoginScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 27/05/2024.
//

import SwiftUI

struct LoginScreen: View {
    @State private var path: [Route] = []
    @State private var loginVM = LoginViewModel()
    
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Image("sidu_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300)
                    .padding(.bottom, 20.0)
                
                HStack {
                    Spacer(minLength: 100)
                    Image(systemName: "person.fill")
                    TextField("Username/Email/Mobile", text: $loginVM.username)
                        .textFieldStyle(.plain)
                    Spacer(minLength: 100)
                }
                .padding(.bottom, 15.0)
                
                HStack {
                    Spacer(minLength: 100)
                    Image(systemName: "lock.fill")
                    SecureField("Password", text: $loginVM.password)
                        .textFieldStyle(PlainTextFieldStyle())
                    Spacer(minLength: 100)
                }
                .padding(.bottom, 50.0)
                
                // Go to register btn
                Button {
                    path.append(.emailRegisterScreen)
                } label: {
                    Text("No account? Go to sign up")
                        .font(.subheadline)
                        .foregroundColor(Color("primaryTextColor"))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 15)
                
                // Login btn
                Button {
                    Task {
                        toastViewObserver.showLoading()
                        await loginVM.login()
                    }
                } label: {
                    Text("Login")
                        .frame(width: 260, height: 30)
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .background(Color("primaryBgColor"))
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
//                .alert("Oops", isPresented: Binding<Bool>(
//                    get: { loginVM.errMsg != nil },
//                    set: { _ in loginVM.errMsg = nil }
//                ), actions: {
//                    Button("OK") {}
//                }, message: {
//                    Text(loginVM.errMsg ?? "")
//                })
            }
            .padding()
            .onDisappear() {
                loginVM.clearCredentials()
            }
            .onChange(of: loginVM.isLoggedIn, { oldValue, newValue in
                if newValue == .success {
                    toastViewObserver.dismissLoading()
                    path.append(.chatScreen)
                } else if newValue == .failed {
                    toastViewObserver.showToast(message: loginVM.errMsg)
                }
                loginVM.isLoggedIn = .none
            })
            .navigationDestination(for: Route.self) { value in
                getViewByRoute(value)
            }
            .toastView(toastViewObserver: toastViewObserver)
        }
        .environment(\.myRoute, $path)
    }
}

#Preview {
    return Group {
//        LoginScreen().environment(\.locale, .init(identifier: "en"))
        LoginScreen()
            .environment(\.locale, .init(identifier: "zh-Hans"))
            .environment(ToastViewObserver())
    }
}
