# EgeriaInternship

# 📱 Egeria Internship App
Bu proje, staj süresince geliştirilen role dayalı dinamik menü sistemine sahip, barkod okuyucu entegreli bir **SwiftUI mobil uygulama** ve **Node.js tabanlı RESTful API** içeren bir sistemdir.

## ✨ Özellikler

- ✅ JWT tabanlı kullanıcı doğrulama ve token yenileme
- 📋 Role dayalı dinamik menü yönetimi (admin/user ayrımı)
- ⚙️ Menü ve kullanıcı CRUD işlemleri (sadece admin için)
- 📷 Barkod/QR kod tarayıcı (iOS cihazlar için kamera ile)
- 🌐 Ayarlanabilir sunucu adresi
- 🧠 MVVM + Service katmanlı mimari

---

## 📦 Backend (Node.js)

### 🔗 Başlatma
```bash
cd backend/
npm install
node server.js
```

### 📂 Endpoint'ler

| Method | Route        | Açıklama                    |
| ------ | ------------ | --------------------------- |
| POST   | `/login`     | Giriş işlemi (JWT üretir)   |
| POST   | `/refresh`   | Token yenileme (refresh)    |
| GET    | `/users`     | Tüm kullanıcıları getirir   |
| POST   | `/users`     | Yeni kullanıcı ekler        |
| PUT    | `/users/:id` | Kullanıcı günceller         |
| DELETE | `/users/:id` | Kullanıcı siler             |
| GET    | `/menus`     | Menüleri getirir            |
| POST   | `/menus`     | Yeni menü ekler             |
| PUT    | `/menus/:id` | Menü günceller (ID + title) |
| DELETE | `/menus/:id` | Menü siler (recursive)      |

 ## 📲 iOS Uygulaması (SwiftUI)
 
###  Kurulum
Xcode ile aç: EgeriaInternshipApp.xcodeproj
Gerekli hedef: iOS 16+
Çalıştırmadan önce: SettingsView ekranına girin
Simülatör değil gerçek cihazda çalıştıracaksanız, APIConfig.swift içinde şu kısmı düzenleyin:
```
// Gerçek cihaz için:
//Kendi bilgisayarınızın IP adresini bulmak için:
// ipconfig getifaddr en0 
return "http://192.168.x.x:3000" // <- burayı değiştirmeniz gerekebilir
```

## 📸 Screenshots
<img width="378" alt="Ekran Resmi 2025-05-14 22 15 13" src="https://github.com/user-attachments/assets/ca8d2766-7283-48c0-8a81-cb2cf4a7c706" />
<img width="372" alt="Ekran Resmi 2025-05-14 22 16 09" src="https://github.com/user-attachments/assets/a8be6ed5-aebb-4ce5-bb43-25c98ef21982" />
<img width="370" alt="Ekran Resmi 2025-05-14 22 15 45" src="https://github.com/user-attachments/assets/59265a33-4362-4c04-938a-0000a5aa97c6" />
<img width="386" alt="Ekran Resmi 2025-05-14 22 15 39" src="https://github.com/user-attachments/assets/cee87280-3a58-4c3e-aac9-33e554820688" />
<img width="370" alt="Ekran Resmi 2025-05-14 22 15 32" src="https://github.com/user-attachments/assets/178a637f-50a9-44e9-bc64-db338ccbf496" />
<img width="375" alt="Ekran Resmi 2025-05-14 22 15 24"![ScreenRecording_05-14-2025 22-18-48_1](https://github.com/user-attachments/assets/12baa746-d135-4282-82bd-fd76799f8df1)
 src="https://github.com/user-attachments/assets/9e78a647-0643-4df1-a716-19ca748b769e" />

![ScreenRecording_05-14-2025 23](https://github.com/user-attachments/assets/1a550c93-7b85-4f10-a08b-e43290b6bb4c)
![IMG_7690](https://github.com/user-attachments/assets/cf59ad8d-6f56-48a1-80a9-eac92c13607f)



## 🧪 Test Süreci (Postman + Manuel)

✅ Giriş, token yenileme, yetkili/izinsiz erişim testleri Postman üzerinden yapıldı.
✅ Menü CRUD işlemleri (GET/POST/PUT/DELETE) test edildi.
✅ Yetkisiz kullanıcıların erişememesi test edildi.
✅ Manuel testlerle kullanıcı rolleri kontrol edildi:
admin → Admin panel erişimi + tüm işlemler
user → Sadece yetkili menülere erişim.

📦 Refresh Token süresi test edildi, oturum süresi dolunca otomatik yenileme çalıştı.

## 📸 Barkod Okuyucu Özelliği
- iOS kamera üzerinden gerçek zamanlı barkod ve QR taraması yapılır.
- GenericDetailView.swift içinde teslim-siparis menüsü üzerinden barkod okutma desteklenir.
- Okutulan barkodlar:
- Liste halinde gösterilir
- UserDefaults üzerinden saklanır
- Kullanıcı dilerse tüm barkodları temizleyebilir
- Kamera açılışı BarcodeScannerView.swift dosyasındaki AVCaptureSession ile yönetilir.

## Yönetici Paneli

Sadece admin kullanıcılar için:

👥 Kullanıcı Ekle / Sil / Güncelle
📋 Menü Ekle / Sil / Güncelle (hiyerarşik yapı)
⚙️ Sunucu bağlantı ayarlarını değiştirme

## Kullanılan Teknolojiler
| Teknoloji      | Kullanım Alanı         |
| -------------- | ---------------------- |
| SwiftUI        | Mobil UI geliştirme    |
| Node.js        | Backend API            |
| Express.js     | Routing & Middleware   |
| JWT            | Kimlik doğrulama       |
| AVFoundation   | Kamera & barkod tarama |
| UserDefaults   | Lokalde veri saklama   |
| MVVM + Service | Temiz mimari yapısı    |

## 🔧 Gereksinimler

- Xcode 14 veya üzeri
- Node.js 18+
- Swift 5.9
- Gerçek cihaz testleri için aynı Wi-Fi ağına bağlı iPhone
- Postman (API testleri için)

## 🔮 Geliştirme Önerileri

- Barkod verilerinin bulut tabanlı saklanması
- Menü yetkilerinin daha görsel bir şekilde yönetilmesi
- Offline çalışma desteği

## 👩🏻‍💻 Developer

**Helin Güler**  
- [LinkedIn Profilim](https://www.linkedin.com/in/helin-guler)  
- [GitHub Profilim](https://github.com/helinguler)
- [Portfolio](https://helinguler.github.io)
