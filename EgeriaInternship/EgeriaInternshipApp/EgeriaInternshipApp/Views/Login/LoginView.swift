//
//  LoginView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 4.05.2025.
//

// Giriş Ekranı: kullanıcı adı + şifre + giriş butonu
import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    // ContentView bu closure’ı tanımlar.
    var onLoginSuccess: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Giriş Yap")
                .font(.largeTitle)
                .bold()

            TextField("Kullanıcı Adı", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            SecureField("Şifre", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            if isLoading {
                ProgressView()
            } else {
                Button("Giriş") {
                    login()
                }
                .buttonStyle(.borderedProminent)
                .disabled(username.isEmpty || password.isEmpty)
            }
        }
        .padding()
    }

    func login() {
        isLoading = true
        errorMessage = nil

        LoginService.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    UserManager.shared.login(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken

                    )
                    
                    // ✅ userId'yi sakla
                    UserDefaults.standard.set(response.userId, forKey: "userId")
                    UserDefaults.standard.synchronize()
                    
                    // ✅ Kullanıcı verisini çek
                    Task {
                        await UserService().fetchUser(id:response.userId)
                            onLoginSuccess?()

                    }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
