//
//  User.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 16.04.2025.
//

import Foundation

// Kullanıcıya özgü yetkilendirme
struct User: Identifiable, Codable {
    let id: Int
    let username: String
    let password: String?
    let role: String
    let permissions: [String]
}
