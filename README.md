# Smart Inventory App - UTS Pemrograman Mobile

Aplikasi manajemen inventaris stok barang modern yang dibangun menggunakan framework Flutter.

## Fitur Utama:
* **Login System**: Autentikasi admin dengan username `admin` dan password `admin123`.
* **Session Persistence**: Menggunakan `SharedPreferences` agar status login tetap terjaga meskipun aplikasi ditutup.
* **Manajemen Stok (CRUD)**: Menambah, melihat, mengubah, dan menghapus data barang secara lokal.
* **Indikator Stok**: Label otomatis berwarna **Merah** jika stok $\le 5$ dan **Hijau** jika stok aman.
* **Integrasi Eksternal**: Fitur chat otomatis ke WhatsApp Supplier dan cek lokasi gudang via Google Maps.

## Teknologi yang Digunakan:
* Flutter SDK
* SharedPreferences (Data Persistence)
* Url Launcher (Integrasi WA & Maps)
* Material Design 3

## Cara Menjalankan:
1. Pastikan Flutter SDK sudah terinstal.
2. Jalankan `flutter pub get` di terminal.
3. Jalankan `flutter run` atau tekan F5 di VS Code.