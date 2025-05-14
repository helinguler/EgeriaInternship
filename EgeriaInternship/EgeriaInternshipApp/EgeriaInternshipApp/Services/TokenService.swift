//
//  TokenService.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 4.05.2025.
//

// Uygulamanın access token süresi dolduğunda otomatik olarak refresh token ile yeni bir accessToken almasını sağlar.
import Foundation

struct TokenResponse: Decodable {
    let accessToken: String
}

struct TokenService {
    static func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/refresh") else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let refreshToken = UserManager.shared.getRefreshToken()
        let body = ["refreshToken": refreshToken]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                DispatchQueue.main.async {
                    UserManager.shared.setToken(tokenResponse.accessToken)
                    UserDefaults.standard.set(tokenResponse.accessToken, forKey: "accessToken")
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
}
