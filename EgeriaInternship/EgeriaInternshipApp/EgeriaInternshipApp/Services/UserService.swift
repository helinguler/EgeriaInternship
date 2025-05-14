//
//  UserSevice.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 25.04.2025.
//

//  Kullanıcı ID'si ile sunucuya istek atmak, gelen kullanıcıyı User modeline dönüştürmek, hem View'da gösterme, hem de UserManager'a kaydetmek.
import Foundation

@MainActor
class UserService: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let baseURL = "\(APIConfig.baseURL)/users"

    func fetchUser(id: Int) async {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(baseURL)/\(id)") else {
            errorMessage = "Geçersiz kullanıcı URL'si."
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = UserManager.shared.getToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")


        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            
            let decodedUser = try JSONDecoder().decode(User.self, from: data)
            self.currentUser = decodedUser
        

            // 📌 Kullanıcıyı UserManager'a kaydet:
            UserManager.shared.setUser(decodedUser)

        } catch {
            self.errorMessage = "Kullanıcı çekme hatası: \(error.localizedDescription)"
            print("❌ Kullanıcı çekilemedi:", error.localizedDescription)
        }

        isLoading = false
    }
}
