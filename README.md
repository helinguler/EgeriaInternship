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
//Kendi bilgisayarınızın IP adresini yazın
return "http://192.168.x.x:3000" // <- burayı değiştirmeniz gerekebilir
```

## 🧪 Test Süreci (Postman + Manuel)

✅ Giriş, token yenileme, yetkili/izinsiz erişim testleri Postman üzerinden yapıldı.
✅ Menü CRUD işlemleri (GET/POST/PUT/DELETE) test edildi.
✅ Yetkisiz kullanıcıların erişememesi test edildi.
✅ Manuel testlerle kullanıcı rolleri kontrol edildi:
admin → Admin panel erişimi + tüm işlemler
user → Sadece yetkili menülere erişim
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


## 👩🏻‍💻 Developer

**Helin Güler**  
- [LinkedIn Profilim](https://www.linkedin.com/in/helin-guler)  
- [GitHub Profilim](https://github.com/helinguler)
- [Portfolio]([https://github.com/helinguler](https://helinguler.github.io))
