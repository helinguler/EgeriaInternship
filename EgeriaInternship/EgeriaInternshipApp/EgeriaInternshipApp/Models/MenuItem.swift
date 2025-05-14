//
//  MenuItem.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 16.04.2025.
//

import Foundation

// Dinamik Menü Yapısı
struct MenuItem: Identifiable, Codable {
    let id: String
    let title: String
    var children: [MenuItem]?
    
    // Encodable protokolü kullanan bir struct’ın, JSON’daki alan adları ile Swift’teki property adları farklıysa, onları eşleştirmek için CodingKeys kullanılır.
    // Bu enum’un adı mutlaka CodingKeys olmalı. Swift bunu otomatik tanır.
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case children
    }
}
