//
//  MenuService.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 25.04.2025.
//

// Menüyü API'den çekme ve güncel token ile erişim
import Foundation

@MainActor
class MenuService: ObservableObject {
    @Published var menus: [MenuItem] = []

    // Menüleri API'den çekme
    func fetchMenus() async throws {
        var baseURL: String {
            UserDefaults.standard.string(forKey: "baseURL") ?? "http://localhost:3000"
        }
        guard let url = URL(string: "\(APIConfig.baseURL)/menus") else {
            throw URLError(.badURL)
        }

        // GET isteği
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // JWT token ekleme
        let token = UserManager.shared.getToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // API isteği gönderme
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 401 {
            // Token geçersiz, refresh etmeyi deneme
            var refreshed = false
            await withCheckedContinuation { continuation in
                TokenService.refreshAccessToken { success in
                    refreshed = success
                    continuation.resume()
                }
            }

            if refreshed {
                // Token yenilendiyse tekrar deneme
                try await fetchMenus()
                return
            } else {
                // Refresh başarısızsa logout yapma
                UserManager.shared.logout()
                throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Oturum süresi doldu. Lütfen tekrar giriş yapın."])
            }
            
        }

        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }


        let decoded = try JSONDecoder().decode(MenuResponse.self, from: data)
        self.menus = decoded.menus
    }
}
