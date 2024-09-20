//
//  SettingScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 20/09/2024.
//

import SwiftUI
import SwiftData

struct SettingScreen: View {
    @Environment(\.myRoute) private var path
    @Environment(ToastViewObserver.self) var toastViewObserver
    @Environment(\.modelContext) private var modelContext
    
    @State private var loginVM = LoginViewModel()
    
    var versionInfo: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    var body: some View {
        VStack {
            // Current version info
            HStack {
                Text("Version:")
                Spacer()
                Text(versionInfo)
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            // Check update btn
            HStack {
                Button {
                    print("check update...")
                } label: {
                    Text("Check Update")
                        .frame(width: 120, height: 20)
                        .font(.subheadline)
                        .background(.gray.opacity(0.5))
                        .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 10)
                Spacer()
            }
            
            // Current language
            HStack {
                Text("Current Language:")
                Spacer()
                Text("中文")
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            // Switch language btn
            HStack {
                Button {
                    print("switch language...")
                } label: {
                    Text("Switch Language")
                        .frame(width: 120, height: 20)
                        .font(.subheadline)
                        .background(.gray.opacity(0.5))
                        .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 10)
                Spacer()
            }
            
            // Total topics
            HStack {
                Text("Total topics:")
                Spacer()
                Text("0")
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            // Clear topic btn
            HStack {
                Button {
                    print("clear topic...")
                } label: {
                    Text("Clear Topics")
                        .frame(width: 120, height: 20)
                        .font(.subheadline)
                        .background(.gray.opacity(0.5))
                        .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 10)
                Spacer()
            }
            
            // Delete account btn (not logout)
            HStack {
                Spacer()
                Button {
                    print("delete account...")
                } label: {
                    Text("Delete Account")
                        .foregroundStyle(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 50)
                Spacer()
            }
            
            Spacer()
            
            // Logout btn
            HStack {
                Spacer()
                Button {
                    loginVM.isShowingConfirmLogout = true
                } label: {
                    Text("Logout")
                        .frame(width: 140, height: 30)
                        .font(.subheadline)
                        .foregroundColor(Color.white)
                        .background(Color("primaryBgColor"))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .alert("Confirm to logout?", isPresented: Binding<Bool>(
                    get: { loginVM.isShowingConfirmLogout },
                    set: { _ in loginVM.isShowingConfirmLogout = false }
                )) {
                    Button("Cancel") {
                        loginVM.isShowingConfirmLogout = false
                    }
                    Button("Confirm") {
                        loginVM.isShowingConfirmLogout = false
                        loginVM.logout()
                        path.wrappedValue.append(.loginScreen)
                    }
                }
                Spacer()
            }
            .padding(.bottom, 30.0)
        }
        .shadowAndRoundedCorner(color: .secondaryBg, radius: 0)
        .onAppear() {
            self.loginVM.modelContext = modelContext
        }
        .navigationBarBackButtonHidden()
        .toastView(toastViewObserver: toastViewObserver)
    }
}

#Preview {
    return Group {
        SettingScreen()
            .frame(width: 200, height: 500)
            .environment(\.locale, .init(identifier: "en"))
//            .environment(\.locale, .init(identifier: "zh-Hans"))
            .environment(ToastViewObserver())
            
    }
}
