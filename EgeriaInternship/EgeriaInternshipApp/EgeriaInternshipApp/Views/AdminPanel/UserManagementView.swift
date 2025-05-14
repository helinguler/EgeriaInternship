//
//  UserManagementView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 11.05.2025.
//

/// Adminlerin  sistemdeki kullanıcıları yönetmesini sağlar.
import SwiftUI

struct UserManagementView: View {
    @State private var users: [User] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    // Yeni kullanıcı ekleme alanları
    @State private var newUsername = ""
    @State private var newPassword = ""
    @State private var newRole = ""
    @State private var newPermissions = ""

    // Güncelleme için state
    @State private var showEditSheet = false
    @State private var selectedUser: User?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Kullanıcılar yükleniyor...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                List {
                    ForEach(users, id: \.id) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.username).font(.headline)
                                Text("Rol: \(user.role)").font(.subheadline).foregroundColor(.gray)
                            }
                            Spacer()

                            // Edit ve Sil ayrı ayrı çalışır, ID çakışması olmaz.
                            Button {
                                selectedUser = user
                                showEditSheet = true
                            } label: {
                                Text("✏️")
                            }
                            .buttonStyle(.borderless)

                            Button {
                                deleteUser(user.id)
                            } label: {
                                Text("🗑")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }

            Divider()

            // Yeni kullanıcı ekleme alanı
            VStack(spacing: 10) {
                Text("Yeni Kullanıcı Ekle").font(.headline)

                TextField("Kullanıcı Adı", text: $newUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Şifre", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Rol (admin/user)", text: $newRole)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("İzinler (virgülle)", text: $newPermissions)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("➕ Kullanıcı Ekle") {
                    let permissionArray = newPermissions
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }

                    AdminService.addUser(
                        username: newUsername,
                        password: newPassword,
                        role: newRole.lowercased(),
                        permissions: permissionArray
                    ) { success in
                        if success {
                            newUsername = ""
                            newPassword = ""
                            newRole = ""
                            newPermissions = ""
                            loadUsers()
                        } else {
                            errorMessage = "Kullanıcı ekleme başarısız."
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Kullanıcı Yönetimi")
        .onAppear(perform: loadUsers)
        .sheet(isPresented: $showEditSheet, onDismiss: {
            selectedUser = nil
        }) {
            if let userToEdit = selectedUser {
                EditUserView(
                    user: userToEdit,
                    onSave: {
                        showEditSheet = false
                    },
                    onCancel: {
                        showEditSheet = false
                    }
                )
            }
        }
    }

    func loadUsers() {
        isLoading = true
        AdminService.fetchUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users): self.users = users
                case .failure(let error): self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }

    func deleteUser(_ id: Int) {
        AdminService.deleteUser(id: id) { success in
            if success {
                loadUsers()
            } else {
                errorMessage = "Silme işlemi başarısız."
            }
        }
    }
}


