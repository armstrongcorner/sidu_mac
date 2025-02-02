//
//  LoginScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 27/08/2024.
//

import SwiftUI
import SwiftData

struct LoginScreen: View {
    @Environment(\.myRoute) private var path
    @Environment(ToastViewObserver.self) var toastViewObserver
    @Environment(\.createUserHandler) private var createUserHandler
    
    @State private var loginVM = LoginViewModel()
    
    var body: some View {
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
                    .clearButton(text: $loginVM.username)
                    .textFieldStyle(.plain)
                Spacer(minLength: 100)
            }
            .padding(.bottom, 15.0)
            
            HStack {
                Spacer(minLength: 100)
                Image(systemName: "lock.fill")
                SecureField("Password", text: $loginVM.password)
                    .clearButton(text: $loginVM.password)
                    .textFieldStyle(.plain)
                Spacer(minLength: 100)
            }
            .padding(.bottom, 50.0)
            
            // Go to register btn
            Button {
                path.wrappedValue.append(.emailRegisterScreen)
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
        .onAppear() {
            self.loginVM.createUserHandler = createUserHandler
        }
        .onDisappear() {
            loginVM.clearCredentials()
        }
        .onChange(of: loginVM.isLoggedIn, { oldValue, newValue in
            if newValue == .success {
                toastViewObserver.dismissLoading()
                path.wrappedValue.append(.chatScreen)
            } else if newValue == .failed {
                toastViewObserver.showToast(message: loginVM.errMsg)
            }
            loginVM.isLoggedIn = .none
        })
        .navigationBarBackButtonHidden()
        .toastView(toastViewObserver: toastViewObserver)
    }
}

#Preview {
    return Group {
        LoginScreen()
//            .environment(\.locale, .init(identifier: "en"))
            .environment(\.locale, .init(identifier: "zh"))
            .environment(ToastViewObserver())
            .environment(AppSize(CGSize(width: 1024, height: 768)))
            .environment(\.createUserHandler, DatabaseProvider.shared.userHandlerCreator(preview: true))
            .modelContainer(DatabaseProvider.shared.previewContainer)
    }
}
