//
//  GenericDetailView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 6.05.2025.
//

/// Her sayfa için ayrı view file oluşturmak yerine seçilen MenuItem'a göre ilgili içerik ve işlemleri sunar.
/// Desteklenen ID’ler:
/// - "gunluk-plan" → üretim plan listesi
/// - "aktif-sevkiyat" → sevkiyat listesi
/// - "teslim-siparis" → barkod tarayıcı destekli sipariş teslim listesi
/// - "urun-stok" → stok durumu listesi
/// Diğerleri için varsayılan genel işlem butonu gösterilir
import SwiftUI

struct GenericDetailView: View {
    let menuItem: MenuItem

    @State private var showConfirmation = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var primaryButton: Alert.Button = .default(Text("Tamam"))
    @State private var secondaryButton: Alert.Button = .cancel()
    @State private var showScanner = false
    @State private var scannedCode: String = ""
    @State private var scannedBarcodes: [String] = []



    var body: some View {
        VStack(spacing: 20) {

            if UserManager.shared.hasPermission(for: menuItem.id) {
                actionButtons(for: menuItem.id)
            } else {
                Text("Bu sayfaya erişim yetkiniz yok.")
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .navigationTitle(menuItem.title)
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                    loadBarcodesFromDefaults()
                }
                }
        .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showScanner = true
                        }) {
                            Image(systemName: "barcode.viewfinder")
                        }
                    }
                }
                .sheet(isPresented: $showScanner) {
                    BarcodeScannerView { code in
                        scannedCode = code
                        showScanner = false
                        print("📦 Barkod:", code)
                        
                        if menuItem.id == "teslim-siparis" {
                                if !scannedBarcodes.contains(code) {
                                    scannedBarcodes.append(code)
                                    saveBarcodesToDefaults()
                                }
                            }
                    }
        }
    }

    @ViewBuilder
    func actionButtons(for id: String) -> some View {
        switch id {
        // MARK: Günlük plan görünümü
        case "gunluk-plan":
            VStack(spacing: 12) {
                Text("📋 Bugünün Planları")
                    .font(.headline)

                VStack(alignment: .leading) {
                    HStack {
                        Text("Saat").bold().frame(width: 80, alignment: .leading)
                        Text("Görev").bold().frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Divider()
                    HStack {
                        Text("08:00").frame(width: 80, alignment: .leading)
                        Text("Üretim Başlat").frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        Text("10:30").frame(width: 80, alignment: .leading)
                        Text("Kalite Kontrol").frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        Text("13:00").frame(width: 80, alignment: .leading)
                        Text("Paketleme").frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        Text("15:00").frame(width: 80, alignment: .leading)
                        Text("Sevkiyata Gönderim").frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                Spacer()

                Button("Yeni Plan Ekle") {
                    configureAlert(
                        title: "Plan Eklensin mi?",
                        message: "İşlemine başlamak istediğinize emin misiniz?",
                        primary: .default(Text("Evet")) {
                            print("✅ Plan başladı")
                        },
                        secondary: .cancel(Text("Hayır"))
                        )
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
         
        // MARK: Aktif sevkiyat görünümü
        case "aktif-sevkiyat":
            VStack(spacing: 12) {

                List {
                    Text("Sevkiyat - Ankara")
                    Text("Sevkiyat - İzmir")
                    Text("Sevkiyat - Bursa")
                }
                .listStyle(.inset)
                .frame(height: 300)
                
                Spacer()
                
                Button("Tüm Sevkiyatları Başlat") {
                    configureAlert(
                        title: "Sevkiyat Başlatılsın mı?",
                        message: "Tüm aktif sevkiyatlar başlatılacak. Emin misiniz?",
                        primary: .default(Text("Başlat")) {
                            print("🚚 Sevkiyatlar başlatıldı")
                        },
                        secondary: .cancel(Text("İptal"))
                    )
                }
                .padding()
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()

        // MARK: Teslim edilen sipariş sayfası görünümü
        case "teslim-siparis":
            VStack(spacing: 12) {
                List {
                    if scannedBarcodes.isEmpty {
                        Text("📭 Henüz barkod okutulmadı.")
                    } else {
                        ForEach(scannedBarcodes, id: \.self) { code in
                            Text("📦 Barkod: \(code)")
                        }
                    }
                }
                .frame(height: 300)
                .listStyle(.inset)

                Button("Siparişleri Güncelle") {
                    configureAlert(
                        title: "Sipariş Güncellensin mi?",
                        message: "Sipariş listesi güncellenecek. Devam etmek istiyor musunuz?",
                        primary: .default(Text("Güncelle")) {
                            print("🔄 Güncellenen Barkodlar:", scannedCode)
                        },
                        secondary: .cancel(Text("İptal"))
                    )
                }
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Tümünü Temizle") {
                    scannedBarcodes.removeAll()
                    UserDefaults.standard.removeObject(forKey: "savedBarcodes")
                }
                .padding(.top, 5)
                .foregroundColor(.red)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
           
        // MARK: Ürün stok sayfası görünümü
        case "urun-stok":
            VStack(spacing: 12) {
                List {
                    Text("Ürün A - 120 adet")
                    Text("Ürün B - 50 adet")
                    Text("Ürün C - 75 adet")
                    Text("Ürün D - 0 adet (Stokta Yok)")
                    Text("Ürün E - 300 adet")
                }
                .listStyle(.inset)
                .frame(maxHeight: 300)

                Spacer()

                Button("Yeni Ürün Ekle") {
                    configureAlert(
                        title: "Yeni ürün eklensin mi?",
                        message: "Yeni bir ürün eklemek üzeresiniz. Devam etmek istiyor musunuz?",
                        primary: .default(Text("Ekle")) {
                            print("🆕 Yeni ürün eklendi")
                        },
                        secondary: .cancel(Text("Vazgeç"))
                    )
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()

        default:
            Button("İşleme Devam Et") {
                configureAlert(
                    title: "Devam edilsin mi?",
                    message: "Bu işlemi yapmak istediğinize emin misiniz?",
                    primary: .default(Text("Devam")) { print("➡️ Genel işlem yapıldı") },
                    secondary: .cancel()
                )
            }
        }
    }

    func configureAlert(title: String, message: String, primary: Alert.Button, secondary: Alert.Button) {
        self.alertTitle = title
        self.alertMessage = message
        self.primaryButton = primary
        self.secondaryButton = secondary
        self.showConfirmation = true
    }
    
    func saveBarcodesToDefaults() {
        UserDefaults.standard.set(scannedBarcodes, forKey: "savedBarcodes")
    }
    
    func loadBarcodesFromDefaults() {
        if let saved = UserDefaults.standard.stringArray(forKey: "savedBarcodes") {
            scannedBarcodes = saved
        }
    }

}

#Preview {
    MainMenuView()
}
