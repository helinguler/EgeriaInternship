//
//  MenuManagementView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 11.05.2025.
//

/// Bu view, admin yetkisine sahip kullanıcıların menü öğelerini görüntüleyip yönetebileceği ekranı temsil eder.
/// Menü hiyerarşisi RecursiveMenuRowView ile görselleştirilir.
///  Tüm işlemler AdminService üzerinden gerçekleştirilir.
import SwiftUI

struct MenuManagementView: View {
    @State private var menus: [MenuItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    @State private var newMenuID = ""
    @State private var newMenuTitle = ""
    @State private var parentMenuID = ""

    @State private var selectedMenuToEdit: MenuItem? = nil
    @State private var editedMenuID = ""
    @State private var editedMenuTitle = ""
    @State private var isEditSheetPresented = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Menüler yükleniyor...")
            } else if let error = errorMessage {
                Text(error).foregroundColor(.red)
            }
            // Menü listesi
            else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        // Menüleri alt alta göstermek için recursive view kullanılıyor
                        ForEach(menus, id: \.id) { item in
                            RecursiveMenuRowView(
                                menu: item,
                                indentLevel: 0,
                                onDelete: { idToDelete in
                                    deleteMenu(id: idToDelete)
                                },
                                onEdit: { menu in
                                    // Düzenleme sheet'ini tetikleyen setup
                                    editedMenuID = menu.id
                                    editedMenuTitle = menu.title
                                    selectedMenuToEdit = menu
                                    isEditSheetPresented = true
                                }
                            )
                        }
                    }
                    .padding()
                }
            }

            Divider()

            // Yeni menü ekleme formu
            VStack(spacing: 10) {
                Text("Yeni Menü Ekle").font(.headline)

                TextField("Menü ID", text: $newMenuID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Menü Başlığı", text: $newMenuTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Üst Menü ID (isteğe bağlı)", text: $parentMenuID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("➕ Menü Ekle") {
                    addMenu()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Menü Yönetimi")
        .onAppear(perform: loadMenus) // Sayfa ilk açıldığında menüleri getir
        .sheet(isPresented: $isEditSheetPresented) {
            // Menü düzenleme ekranı
            VStack(spacing: 16) {
                Text("Menü Düzenle").font(.headline)

                TextField("Yeni ID", text: $editedMenuID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Yeni Başlık", text: $editedMenuTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("💾 Kaydet") {
                    guard let oldID = selectedMenuToEdit?.id else { return }
                    AdminService.updateMenu(oldID: oldID, newID: editedMenuID, newTitle: editedMenuTitle) { success in
                        if success {
                            loadMenus()
                            isEditSheetPresented = false
                        } else {
                            errorMessage = "Güncelleme başarısız"
                        }
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }

    func loadMenus() {
        isLoading = true
        print("🔗 Aktif BaseURL: \(AdminService.baseURL)")
        AdminService.fetchMenus { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let menus):
                    self.menus = menus
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }

    func deleteMenu(id: String) {
        AdminService.deleteMenu(id: id) { success in
            if success {
                loadMenus()
            } else {
                errorMessage = "Menü silinemedi (sunucu hatası olabilir)"
            }
        }
    }

    func addMenu() {
        AdminService.addMenu(id: newMenuID, title: newMenuTitle, parentId: parentMenuID.isEmpty ? nil : parentMenuID) { success in
            if success {
                newMenuID = ""
                newMenuTitle = ""
                parentMenuID = ""
                loadMenus()
            } else {
                errorMessage = "Menü ekleme başarısız."
            }
        }
    }
}
