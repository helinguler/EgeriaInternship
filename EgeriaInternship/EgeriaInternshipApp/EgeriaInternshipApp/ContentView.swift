//
//  ContentView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 16.04.2025.
//

import SwiftUI

struct ContentView: View {
    // viewResetKey her değiştiğinde SwiftUI o View’u tamamen sıfırdan oluşturur.
    @State private var viewResetKey = UUID()
    @StateObject private var userManager = UserManager.shared

        var body: some View {
            Group {
                if UserManager.shared.getToken().isEmpty {
                    LoginView {
                        // Giriş başarılı → ekranı sıfırla
                        viewResetKey = UUID()
                    }
                } else {
                    MainMenuView {
                        // Çıkış yapıldı → ekranı sıfırla
                        viewResetKey = UUID()

                    }
                }
            }
            .id(viewResetKey) // Sayesinde görünüm sıfırlanır, cache’lenmiş veya kalmış verilerden etkilenmez.
            .onAppear {
                UserManager.shared.initializeSessionIfPossible()
            }
        }
}

#Preview {
    ContentView()
}
