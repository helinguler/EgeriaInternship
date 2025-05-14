//
//  MenuResponse.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 6.05.2025.
//

import Foundation

// JSON verisini Swift nesnesine decode etme
struct MenuResponse: Decodable {
    let menus: [MenuItem]
    let users: [User]?
}
