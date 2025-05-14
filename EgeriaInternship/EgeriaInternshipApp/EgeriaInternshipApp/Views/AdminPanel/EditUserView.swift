//
//  EditUserView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 11.05.2025.
//

/// Mevcut bir kullanıcının bilgilerini düzenlemek için kullanılan form ekranını temsil eder.
///  Kullanıcı adı, rol, izinler ve şifre gibi alanlar düzenlenebilir.
import SwiftUI

struct EditUserView: View {
    let user: User
    var onSave: () -> Void
    var onCancel: () -> Void

    @State private var username: String
    @State private var password: String = ""
    @State private var role: String
    @State private var permissions: String

    init(user: User, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.user = user
        self.onSave = onSave
        self.onCancel = onCancel
        _username = State(initialValue: user.username)
        _role = State(initialValue: user.role)
        _permissions = State(initialValue: user.permissions.joined(separator: ","))
    }

    var body: some View {
        NavigationView {
            // Kullanıcı bilgilerini düzenlemek için kullanılan form
            Form {
                Section(header: Text("Kullanıcı Bilgileri")) {
                    TextField("Kullanıcı Adı", text: $username)
                    SecureField("Yeni Şifre (opsiyonel)", text: $password)
                    TextField("Rol", text: $role)
                    TextField("İzinler (virgülle)", text: $permissions)
                }

                Button("💾 Kaydet") {
                    let permArray = permissions
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }

                    // Güncelleme isteği gönderilir
                    AdminService.updateUser(
                        id: user.id,
                        username: username,
                        password: password.isEmpty ? nil : password,
                        role: role,
                        permissions: permArray
                    ) { success in
                        if success {
                            onSave() // sadece başarılı olunca kapat
                        }
                    }
                }
                .foregroundColor(.blue)
            }
            .navigationTitle("Kullanıcıyı Düzenle")
            // Navigasyon barındaki iptal butonu
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        onCancel()
                    }
                }
            }
        }
    }
}
