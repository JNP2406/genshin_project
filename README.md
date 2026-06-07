# Genshin Import 🗡️

Aplikasi e-commerce seluler bertema game populer **Genshin Impact**. Aplikasi ini memungkinkan pengguna untuk mencari dan membeli senjata serta artefak bertema Teyvat menggunakan mata uang dalam aplikasi yang disebut **Mora**. Administrator dapat mengelola katalog item melalui antarmuka khusus.

---

## 🛠️ Technology Stack

| Komponen | Teknologi |
|----------|-----------|
| Frontend | Flutter SDK 3.32.2 (Dart) |
| Backend | Node.js + Express.js |
| Database | MySQL (via XAMPP) |
| Autentikasi | JWT Bearer Token + Google OAuth 2.0 |
| Penyimpanan Gambar | Multer (folder uploads/ lokal) |
| State Management | setState + SharedPreferences + Custom MoraNotifier |

---

## 👤 Role Pengguna

| Role | Deskripsi |
|------|-----------|
| User | Dapat menelusuri barang, membeli barang menggunakan Mora, melihat riwayat transaksi, dan mengelola profil. |
| Admin | Dapat membuat, membaca, memperbarui, dan menghapus item serta melihat semua transaksi pengguna. Akun Admin dibuat secara manual di database. |

---

## ✨ Fitur Utama

### 🔐 Autentikasi
- Login menggunakan email & kata sandi
- Login / Register via Google OAuth 2.0
- Bearer token (20 karakter alfanumerik) disimpan secara lokal
- Validasi input: format email, kata sandi minimal 8 karakter
- Aplikasi mengingat tema terakhir (dark/light mode) setelah logout

### 🏠 Home Screen
- Grid 2 kolom menampilkan semua weapon dan artefak
- Search bar real-time berdasarkan nama item
- Filter berdasarkan kategori (All / Weapon / Artifact) dan sub-type
- Mora Balance ditampilkan di pojok kanan atas
- Pull to refresh
- Admin: tombol Edit & Delete pada setiap item + FAB untuk menambah item baru

### 📦 Detail Item
- Menampilkan: gambar, nama, kategori, tipe, stok, deskripsi, dan harga
- Pemilih kuantitas (+/-) — tidak bisa melebihi stok
- Dialog konfirmasi pembelian dengan total harga
- Saldo Mora diperbarui secara real-time setelah pembelian
- Label "Out of Stock" ketika stok habis
- Admin: tombol Edit & Delete sebagai pengganti tombol Beli

### 📝 Admin Form
- Form untuk membuat atau mengedit item
- Field: Nama, Kategori (dropdown), Tipe (dropdown dinamis), Stok, Harga, Deskripsi, Upload Gambar
- Validasi semua field wajib diisi
- Upload gambar dari galeri perangkat

### 📜 History Screen
- Kartu emas menampilkan total pengeluaran/pendapatan Mora per bulan
- Kalender interaktif untuk filter berdasarkan tanggal
- User: daftar transaksi dengan gambar item, nama, tipe, tanggal, dan jumlah (merah)
- Admin: transaksi dikelompokkan per pengguna (dapat dilipat/expand)

### 👤 Profile Screen
- Foto sampul dan foto profil
- Info pengguna: nama, email, role, bio
- Toggle Dark Mode / Light Mode
- Tombol Top Up Mora
- Tombol Log Out dengan dialog konfirmasi

### 💰 Top Up Screen
- 4 paket Top Up:
  - 10.000 Mora – Rp 100.000
  - 50.000 Mora – Rp 500.000
  - 100.000 Mora – Rp 1.000.000
  - 1.000.000 Mora – Rp 10.000.000

---

## 🔌 API Endpoints

| Method | Endpoint | Auth | Deskripsi |
|--------|----------|------|-----------|
| POST | /auth/login | ❌ | Login dengan email & password |
| POST | /auth/register | ❌ | Register akun baru |
| POST | /auth/google | ❌ | Login/Register via Google OAuth |
| GET | /items | ❌ | Ambil semua item |
| GET | /items/:id | ❌ | Ambil item berdasarkan ID |
| POST | /items | ✅ | Admin: Tambah item baru |
| PUT | /items/:id | ✅ | Admin: Update item |
| DELETE | /items/:id | ✅ | Admin: Hapus item |
| POST | /buy | ✅ | User: Beli item |
| GET | /transactions/my | ✅ | User: Riwayat transaksi sendiri |
| GET | /transactions/all | ✅ | Admin: Semua transaksi |
| POST | /topup | ✅ | User: Top up Mora |
| PUT | /profile | ✅ | Update profil pengguna |

---

## 🗄️ Struktur Database

### Tabel: users
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id | INT AUTO_INCREMENT | Primary key |
| name | VARCHAR(100) | Username |
| email | VARCHAR(255) | Email pengguna |
| password | VARCHAR(255) | Password terenkripsi (Bcrypt) |
| role | ENUM('user','admin') | Role pengguna |
| mora | DECIMAL(15,2) | Saldo Mora (default 0) |
| profile_picture | VARCHAR(255) | Nama file foto profil |
| cover_photo | VARCHAR(255) | Nama file foto sampul |
| bio | TEXT | Bio pengguna |
| token | VARCHAR(255) | Bearer token aktif |

### Tabel: items
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id | INT AUTO_INCREMENT | Primary key |
| name | VARCHAR(255) | Nama item |
| category | VARCHAR(50) | Weapon atau Artifact |
| type | VARCHAR(50) | Misal: Sword, Claymore, Flower, Feather |
| stat | VARCHAR(100) | Stat item |
| description | TEXT | Deskripsi item |
| stock | INT | Stok tersedia |
| image | VARCHAR(255) | Nama file gambar |
| price | DECIMAL(15,2) | Harga dalam Mora |

### Tabel: transactions
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| id | INT AUTO_INCREMENT | Primary key |
| user_id | INT | Foreign key ke users |
| item_id | INT | Foreign key ke items |
| item_name | VARCHAR(100) | Nama item saat dibeli |
| item_image | VARCHAR(255) | Gambar item saat dibeli |
| item_type | VARCHAR(50) | Tipe item saat dibeli |
| quantity | INT | Jumlah yang dibeli |
| total_price | DECIMAL(15,2) | Total harga |
| created_at | TIMESTAMP | Waktu transaksi |

---

## 🎨 UI Design

### Font
| Font | Penggunaan |
|------|------------|
| Coolvetica | Heading, Logo |
| Poppins | Body text, tombol, label |

### Warna
| Nama | Hex | Penggunaan |
|------|-----|------------|
| Dark Navy | #1A1A2E | Teks utama Light Mode |
| Cream | #F5F0E8 | Teks utama Dark Mode |
| Gold | #EEC249 | Aksen, harga, Mora |
| Blue | #046FE1 | Hyperlink |
| Red | #E53935 | Hapus, error, Logout |
