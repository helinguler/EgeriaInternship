//
//   AdminService.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 11.05.2025.
//

/// AdminService sunucu ile admin işlemlerini (kullanıcı ve menü yönetimi) gerçekleştiren yardımcı servis.
/// Sadece adminlerin yapabileceği işlemleri içerir.

import Foundation

struct AdminService {
    static var baseURL: String {
        APIConfig.baseURL
    }
    
    // MARK: Kullanıcı işlemleri
    
    // MARK: Kullanıcı getirme
    //Tüm kullanıcıları sunucudan çeker.
    static func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(UserManager.shared.getToken())", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                struct Response: Decodable {
                let users: [User]
                }
                let decoded = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(decoded.users))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
    }

    // MARK: DELETE -> Kullanıcı silme
    // Belirtilen ID’ye sahip kullanıcıyı siler.
    static func deleteUser(id: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(id)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(UserManager.shared.getToken())", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
    
    // MARK: POST -> Kullanıcı ekleme
    static func addUser(username: String, password: String, role: String, permissions: [String], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/users") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserManager.shared.getToken())", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "username": username,
            "password": password,
            "role": role,
            "permissions": permissions
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 201
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
    
    // MARK: PUT -> Var olan kullanıcıyı güncelleme
    static func updateUser(id: Int, username: String, password: String?, role: String, permissions: [String], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(id)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(UserManager.shared.getToken())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "username": username,
            "role": role.lowercased(),
            "permissions": permissions
        ]

        if let password = password, !password.isEmpty {
            body["password"] = password
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }

    // MARK: Menü işlemleri
    
    // MARK: GET -> Menüleri getirme
    // Tüm menüleri sunucudan çeker.
    static func fetchMenus(completion: @escaping (Result<[MenuItem], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/menus") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(UserManager.shared.getToken())", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                struct MenuResponse: Decodable { let menus: [MenuItem] }
                let decoded = try JSONDecoder().decode(MenuResponse.self, from: data)
                completion(.success(decoded.menus))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: DELETE -> Menü silme id ye göre
    static func deleteMenu(id: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/menus/\(id)") else {
            print("❌ Geçersiz URL: \(baseURL)/menus/\(id)")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(UserManager.shared.getToken())", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code: \(httpResponse.statusCode)")
            }
            if let data = data {
                print("📩 Response body: \(String(data: data, encoding: .utf8) ?? "N/A")")
            }
            if let error = error {
                print("❌ Hata: \(error.localizedDescription)")
            }
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
    

    // MARK: POST -> Menü ekleme
    static func addMenu(id: String, title: String, parentId: String?, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/menus") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(UserManager.shared.getToken())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var newMenu: [String: Any] = [
                "id": id,
                "title": title
            ]

            if let parentId = parentId {
                newMenu["parentId"] = parentId
            }

        
            let body = ["newMenu": newMenu]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Gönderilen JSON:\n\(jsonString)")
        }


        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 201
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
    
    // MARK: PUT -> Menü güncelleme
    // Sadece ID ve title güncellenebilir. Hiyerarşi değişmez.
    static func updateMenu(oldID: String, newID: String, newTitle: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/menus/\(oldID)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserManager.shared.getToken())", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "newId": newID,
            "newTitle": newTitle
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
}
