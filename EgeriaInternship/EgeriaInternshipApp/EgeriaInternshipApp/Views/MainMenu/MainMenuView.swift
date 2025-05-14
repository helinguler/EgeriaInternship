//
//  MainMenuView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 16.04.2025.
//

/// Uygulamanın ana menü ekranı.
/// Kullanıcının yetkisine göre dinamik menüleri sunucudan çeker.
/// Admin kullanıcılar için admin panele ulaşabilecekleri buton mevcuttur.
import SwiftUI

struct MainMenuView: View {
    @StateObject private var menuService = MenuService()
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    @AppStorage("baseURL") private var baseURL: String = ""
    @State private var lastKnownBaseURL = ""

    // // ContentView bu closure’ı tanımlar.
    var onLogout: (() -> Void)? = nil

    var body: some View {
        NavigationView {
            VStack {
                if !isLoading && menuService.menus.isEmpty {
                    VStack(spacing: 12) {
                          Text(errorMessage!)
                              .foregroundColor(.red)
                              .padding()

                        // Admin için ayarlar linki gösterilir.
                          if UserManager.shared.currentUser?.role == "admin" {
                              NavigationLink("🔧 Sunucu Ayarlarını Değiştir", destination: SettingsView())
                                  .padding()
                                  .background(Color.blue.opacity(0.8))
                                  .foregroundColor(.white)
                                  .cornerRadius(10)
                          }
                      }
                } else {
                    List(menuService.menus, id: \.id) { menu in
                        NavigationLink(destination: nextView(for: menu)) {
                            Text(menu.title)
                                .font(.headline)
                        }
                    }
                    // Admin'e özel panel erişimi
                    if UserManager.shared.currentUser?.role == "admin" {
                        Section {
                            NavigationLink("🛠 Admin Panel", destination: AdminPanelView())
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .onChange(of: baseURL) { newValue in
                if newValue != lastKnownBaseURL {
                    Task {
                        isLoading = true
                        await loadMenus()
                        lastKnownBaseURL = newValue
                    }
                }
            }
            .onAppear {
                lastKnownBaseURL = baseURL
            }
            .navigationTitle("Ana Menü")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Çıkış Yap") {
                        UserManager.shared.logout()
                        onLogout?()
                    }
                }
            }
        }
        .task {
            if UserManager.shared.isLoggedIn {
                print("📦 Token (ilk açılışta):", UserManager.shared.getToken())
                    await loadMenus()
                }
        }
    
    }

    func loadMenus() async {
        do {
                try await menuService.fetchMenus()
                errorMessage = nil
                isLoading = false
            } catch {
                // ❗ Hata alınırsa menüleri temizle
                menuService.menus = []
                errorMessage = "❌ Sunucuya bağlanılamadı. Lütfen URL ayarlarını kontrol edin."
                isLoading = false
            }
    }

    @ViewBuilder
    func nextView(for menu: MenuItem) -> some View {
        if let children = menu.children, !children.isEmpty {
            MenuListView(menuItems: children)
        } else {
            GenericDetailView(menuItem: menu)
        }
    }
}


#Preview {
    MainMenuView()
}
