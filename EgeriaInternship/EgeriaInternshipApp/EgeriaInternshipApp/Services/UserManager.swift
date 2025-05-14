//
//  UserManager.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 18.04.2025.
//

// Kullanıcı oturumunu ve yetkilerini yönetir.
import Foundation
import SwiftUI

class UserManager: ObservableObject {
    static let shared = UserManager()

    @AppStorage("accessToken") private var accessToken: String = ""
    @AppStorage("refreshToken") private var refreshToken: String = ""

    @Published var currentUser: User? = nil
    @Published var token: String?

    private init() {}

    // MARK: Giriş durumu
    var isLoggedIn: Bool {
        !accessToken.isEmpty
    }

    // MARK: Giriş işlemi
    func login(accessToken: String, refreshToken: String, user: User? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.currentUser = user
    }

    // MARK: Çıkış işlemi
    func logout() {
        accessToken = ""
        refreshToken = ""
        currentUser = nil
    }

    // MARK: Token erişimi
    func getToken() -> String {
        return accessToken
    }

    func getRefreshToken() -> String {
        return refreshToken
    }
    
    func setToken(_ token: String) {
        self.token = token
    }

    func setUser(_ user: User) {
        self.currentUser = user
    }
    
    func initializeSessionIfPossible() {
        let token = getToken()
        let userId = UserDefaults.standard.integer(forKey: "userId")


            guard !token.isEmpty, userId != 0 else {
                print("⚠️ Token veya userId yok, oturum başlatılamaz.")
                return
            }

            // Token geçerli mi kontrol etmek
            validateOrRefreshToken { success in
                if success {
                    DispatchQueue.main.async {
                        Task {
                            await UserService().fetchUser(id: userId)
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        print("❌ Token geçersiz veya yenilenemedi.")
                        self.logout()
                    } // Gerekirse otomatik logout
                }
            }
    }
    
    func validateOrRefreshToken(completion: @escaping (Bool) -> Void) {
        let token = getToken()
        guard !token.isEmpty else {
            completion(false)
            return
        }

        // Token süresi dolmuş olabilir → refresh etmeyi deneme
        TokenService.refreshAccessToken { success in
            completion(success)
        }
    }
    
}

// MARK: Yetki kontrolü
extension UserManager {
    func hasPermission(for id: String) -> Bool {
        guard let user = currentUser else {
            print("❌ currentUser nil!")
            return false
        }
        return user.permissions.contains(id)
    }
}
