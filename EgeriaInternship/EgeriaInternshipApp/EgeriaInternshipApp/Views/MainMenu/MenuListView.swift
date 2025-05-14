//
//  MenuListView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 25.04.2025.
//

/// Hiyerarşik iç içe menü yapısını oluşturmak.
/// /// - Eğer menü öğesinin alt menüsü varsa, aynı view tekrar çağrılır MenuListView — yani recursive  yapı kurulur.
/// Eğer alt menü yoksa, GenericDetailView 'a yönlendirilir (muhtemelen içerik gösterim ekranı).

import SwiftUI

struct MenuListView: View {
    let menuItems: [MenuItem]  // Gösterilecek menü öğeleri

    var body: some View {
        List(menuItems, id: \.id) { item in
            NavigationLink(destination: nextView(for: item)) {
                Text(item.title)
            }
        }
        .navigationTitle("Alt Menü")
    }

    @ViewBuilder
    func nextView(for menu: MenuItem) -> some View {
        if let children = menu.children, !children.isEmpty {
            // Alt menü varsa, aynı ekranla devam edilir (recursive navigation)
            MenuListView(menuItems: children)
        } else {
            // Alt menü yoksa detay ekranına yönlendirilir
            GenericDetailView(menuItem: menu)
        }
    }
}

#Preview {
    MenuListView(menuItems: [])
}
