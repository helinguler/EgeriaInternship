//
//  AdminPanelView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 11.05.2025.
//

/// Admin kullanıcılar için ana kontrol panelini temsil eder.
/// - Kullanıcılar buradan:
///   - Kullanıcı yönetimi UserManagementView
///   - Menü yönetimi MenuManagementView
///   - Ayarlar SettingsView ekranlarına geçebilir.

import SwiftUI

struct AdminPanelView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("👥 Kullanıcı Yönetimi", destination: UserManagementView())
                NavigationLink("📋 Menü Yönetimi", destination: MenuManagementView())
            }
            .navigationTitle("Admin Paneli")
            .navigationBarItems(trailing:
                NavigationLink(destination: SettingsView()) {
                Image(systemName: "gear")
                }
            )

        }
    }
}
