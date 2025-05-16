//
//  APIConfig.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 14.05.2025.
//

import Foundation

struct APIConfig {
    static var baseURL: String {
        // Kullanıcının ayarladığı adres varsa onu kullan
        if let savedURL = UserDefaults.standard.string(forKey: "baseURL") {
            return savedURL
        }

        #if targetEnvironment(simulator)
        // Simülatör için localhost
        return "http://localhost:3000"
        #else
        // Gerçek cihaz için varsayılan IP (başka bir wifi ağından bağlanılırsa o da eklenmelidir.)
        return "http://localhost:3000" // Buraya kendi cihaz IP'nizi giriniz. http://192.168.x.x:3000 şeklinde olmalıdır.
        #endif
    }
}
