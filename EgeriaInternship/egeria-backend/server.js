const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const fs = require("fs");
const path = require('path');
const jwt = require("jsonwebtoken");

const app = express();
app.use(bodyParser.json());
app.use(cors());

const data = JSON.parse(fs.readFileSync("menus.json"));

let { menus, users } = require('./menus.json');

// JWT için gizli anahtarlar
const ACCESS_SECRET = "egeria-access-key";
const REFRESH_SECRET = "egeria-refresh-key";

// Refresh token'lar listesi
let refreshTokens = [];

// Access Token üretmek
function generateAccessToken(user) {
    return jwt.sign(
        { userId: user.id, username: user.username, role: user.role },
        ACCESS_SECRET,
        { expiresIn: "60m" }
      );
}

// Refresh Token üretmek
function generateRefreshToken(user) {
  const token = jwt.sign({ userId: user.id }, REFRESH_SECRET, { expiresIn: "7d" });
  refreshTokens.push(token);
  return token;
}

// Access Token doğrulayıcı middleware
function authenticateToken(req, res, next) {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) return res.status(401).json({ error: "Token bulunamadı" });

  jwt.verify(token, ACCESS_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: "Geçersiz token" });
    req.user = user;
    next();
  });
}

// Admin kontrolü yapan middleware
function requireAdmin(req, res, next) {
    if (!req.user || req.user.role !== 'admin') {
      return res.status(403).json({ error: "Sadece admin erişebilir" });
    }
    next();
  }

// POST /login -> Kullanıcı girişi, access + refresh token dönüyor
app.post("/login", (req, res) => {
  const { username, password } = req.body;
  const user = data.users.find(u => u.username === username && u.password === password);
  if (!user) return res.status(401).json({ error: "Geçersiz kullanıcı bilgisi" });

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  res.json({ 
    accessToken, 
    refreshToken, 
    userId: user.id
  });
});

// POST /refresh
app.post("/refresh", (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(401).json({ error: "Refresh token eksik" });
  if (!refreshTokens.includes(refreshToken)) return res.status(403).json({ error: "Tanımsız refresh token" });

  jwt.verify(refreshToken, REFRESH_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ error: "Refresh token geçersiz" });

    const user = data.users.find(u => u.id === decoded.userId);
    if (!user) return res.status(404).json({ error: "Kullanıcı bulunamadı" });

    const accessToken = generateAccessToken(user);
    res.json({ accessToken });
  });
});

// MENU CRUD
// GET /menus -> Menüler (access token ile erişme)

app.get("/menus", authenticateToken, (req, res) => {
  const raw = fs.readFileSync("menus.json", "utf-8");
  const json = JSON.parse(raw);

  const user = data.users.find(u => u.id === req.user.userId);
  if (!user) return res.status(403).json({ error: "Kullanıcı bulunamadı" });

  const filteredMenus = filterMenusByPermissions(json.menus, user.permissions);
  res.json({ menus: filteredMenus });
});

/*
app.get("/menus", authenticateToken, (req, res) => {
  const raw = fs.readFileSync("menus.json", "utf-8");
  const json = JSON.parse(raw);
  res.json({ menus: json.menus });
});
*/

// POST /menus -> Yeni menü ekleme
app.post("/menus", authenticateToken, requireAdmin, (req, res) => {
  const { id, title, parentId } = req.body.newMenu;

  if (!id || !title) {
    return res.status(400).json({ error: "Eksik menü verisi" });
  }

  const newMenu = { id, title };
  const menus = data.menus;

  if (parentId) {
    const parent = findMenuById(menus, parentId);
    if (!parent) {
      return res.status(404).json({ error: "Üst menü bulunamadı" });
    }
    if (!parent.children) parent.children = [];
    parent.children.push(newMenu);
  } else {
    menus.push(newMenu);
  }

  // Ekleyen kullanıcıya yetkiyi otomatik verme
  const user = data.users.find(u => u.id === req.user.userId);
  if (user && !user.permissions.includes(id)) {
    user.permissions.push(id);
  }

  saveData(data);
  res.status(201).json({ message: "Menü eklendi", newMenu });
});


// PUT /menus/:id -> Menü güncelleme
app.put("/menus/:id", authenticateToken, requireAdmin, (req, res) => {
  const menuId = req.params.id;
  const { newId, newTitle } = req.body;

  if (!newId && !newTitle) {
    return res.status(400).json({ error: "Güncellenecek veri eksik." });
  }

  const menu = findMenuById(data.menus, menuId);
  if (!menu) {
    return res.status(404).json({ error: "Menü bulunamadı." });
  }

  if (newId) {
    for (const user of data.users) {
      const index = user.permissions.indexOf(menu.id);
      if (index !== -1) {
        user.permissions.splice(index, 1, newId);
      }
    }

    menu.id = newId;
  }

  if (newTitle) {
    menu.title = newTitle;
  }

  saveData(data);
  res.status(200).json({ message: "Menü güncellendi", updatedMenu: menu });
});

// DELETE /menus/:id -> Menü silme
app.delete('/menus/:id', (req, res) => {
    const idToDelete = req.params.id;
    const filePath = path.join(__dirname, 'menus.json');

    fs.readFile(filePath, 'utf-8', (err, data) => {
        if (err) {
            console.error("Dosya okuma hatası:", err);
            return res.status(500).json({ message: 'Dosya okunamadı' });
        }

        let jsonData;
        try {
            jsonData = JSON.parse(data);
        } catch (parseError) {
            console.error("JSON parse hatası:", parseError);
            return res.status(500).json({ message: 'JSON hatası' });
        }

        // Tüm menü ağacında silinecek öğeyi bulmak için recursive fonksiyon
        function removeMenuItem(menuItems) {
            return menuItems.filter(menuItem => {
                if (menuItem.id === idToDelete) {
                    return false;
                }
                
                if (menuItem.children) {
                    menuItem.children = removeMenuItem(menuItem.children);
                }
                
                return true;
            });
        }

        // Menüleri güncelleme
        jsonData.menus = removeMenuItem(jsonData.menus);

        // Tüm dosyayı kaydetme
        fs.writeFile(filePath, JSON.stringify(jsonData, null, 2), 'utf-8', (err) => {
            if (err) {
                console.error("Dosya yazma hatası:", err);
                return res.status(500).json({ message: 'Silme işlemi başarısız' });
            }

            res.status(200).json({ message: 'Menü silindi' });
        });
    });
});

// KULLANICI CRUD
// GET /users -> Tüm kullanıcıları listeleme
app.get("/users", authenticateToken, requireAdmin, (req, res) => {
    res.json({ users: data.users });
  });

  // GET /users/:id -> Belirli kullanıcıyı getirme
  app.get("/users/:id", authenticateToken, (req, res) => {
    const user = data.users.find(u => u.id == req.params.id);
    if (!user) {
      return res.status(404).json({ error: "Kullanıcı bulunamadı" });
    }
    res.json(user);
  });
  
  // POST /users -> Yeni kullanıcı ekleme
  app.post("/users", authenticateToken, requireAdmin, (req, res) => {
    const { username, password, role, permissions } = req.body;
    if (!username || !password || !role) {
      return res.status(400).json({ error: "Eksik kullanıcı verisi" });
    }
  
    const newUser = {
      id: Date.now(),
      username,
      password,
      role,
      permissions: permissions || []
    };
  
    data.users.push(newUser);
    saveData();
    res.status(201).json({ message: "Kullanıcı eklendi", newUser });
  });
  
  // PUT /users/:id -> Kullanıcı güncelleme
  app.put("/users/:id", authenticateToken, requireAdmin, (req, res) => {
    const { id } = req.params;
    const user = data.users.find(u => u.id == id);
    if (!user) return res.status(404).json({ error: "Kullanıcı bulunamadı" });
  
    const { username, password, role, permissions } = req.body;
  
    if (username) user.username = username;
    if (password) user.password = password;
    if (role) user.role = role;
    if (permissions) user.permissions = permissions;
  
    saveData();
    res.json({ message: "Kullanıcı güncellendi", user });
  });
  
  // DELETE /users/:id -> Kullanıcı silme
  app.delete("/users/:id", authenticateToken, requireAdmin, (req, res) => {
    const { id } = req.params;
    const index = data.users.findIndex(u => u.id == id);
    if (index === -1) return res.status(404).json({ error: "Kullanıcı bulunamadı" });
  
    const deleted = data.users.splice(index, 1);
    saveData();
    res.json({ message: "Kullanıcı silindi", deleted });
  });
  

// Menüleri kullanıcının yetkisine göre filtreleme
function filterMenusByPermissions(menus, permissions) {
  return menus
    .map(menu => {
      if (menu.children) {
        const filteredChildren = filterMenusByPermissions(menu.children, permissions);
        if (filteredChildren.length > 0 || permissions.includes(menu.id)) {
          return { ...menu, children: filteredChildren };
        }
        return null;
      } else {
        return permissions.includes(menu.id) ? menu : null;
      }
    })
    .filter(Boolean);
}

// Yardımcı: Menü ID bulucu
function findMenuById(menus, id) {
  for (let menu of menus) {
    if (menu.id === id) return menu;
    if (menu.children) {
      const found = findMenuById(menu.children, id);
      if (found) return found;
    }
  }
  return null;
}

// menus.json dosyasını kaydetme
function saveData() {
  fs.writeFileSync("menus.json", JSON.stringify(data, null, 2));
}

// Sunucuyu başlatma
app.listen(3000, '0.0.0.0', () => {
  console.log("🚀 API çalışıyor: http://localhost:3000");
  //console.log("✅ Sunucu aktif: http://192.168.x.x:3000");  eksik kısımları kendi bilgisayar IPniz ile doldurunuz.
});
