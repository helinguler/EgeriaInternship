//
//  RecursiveMenuRowView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 12.05.2025.
//


/// Bu view, bir MenuItem öğesini ve varsa alt menülerini hiyerarşik yapıda görselleştirmek için kullanılır.
/// Menü başlığı solda gösterilir, edit (`📝`) ve sil (`🗑`) butonları sağda yer alır.
import SwiftUI

struct RecursiveMenuRowView: View {
    let menu: MenuItem
    let indentLevel: Int
    let onDelete: (String) -> Void
    let onEdit: (MenuItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(String(repeating: "⤷ ", count: indentLevel) + menu.title)
                Spacer()
                Button("📝") {
                    onEdit(menu) // edit butonu
                }
                Button("🗑", role: .destructive) {
                    print("🗑 Silme talebi geldi, id: \(menu.id)")
                    onDelete(menu.id)
                }
            }
            .padding(.leading, CGFloat(indentLevel) * 10)

            if let children = menu.children {
                ForEach(children, id: \.id) { child in
                    RecursiveMenuRowView(
                        menu: child,
                        indentLevel: indentLevel + 1,
                        onDelete: onDelete,
                        onEdit: onEdit // Alt menülere iletme
                    )
                }
            }
        }
    }
}
