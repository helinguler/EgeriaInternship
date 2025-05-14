//
//  SettingsView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 12.05.2025.
//

/// Uygulamanın sunucu bağlantı adresini baseURL kullanıcıdan almak için kullanılan ayar ekranıdır.
/// Web servis adresi settings sayfasından  değiştirilebilir.
import SwiftUI

struct SettingsView: View {
    @AppStorage("baseURL") private var storedBaseURL: String = ""
    @State private var tempURL: String = ""
        
    var isStartup: Bool = false
    @Environment(\.dismiss) var dismiss
        
    var body: some View {
        VStack {
            Text("Sunucu Adresi Girin").font(.title2)
            TextField("Örn: http://localhost:3000", text: $tempURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.URL)
                .onAppear {
                    tempURL = storedBaseURL
                }
            Button("✅ Kaydet") {
                storedBaseURL = tempURL
                if !isStartup {
                    dismiss()
                }
            }
            .padding()
        }
        .padding()
    }
}
