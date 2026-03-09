# PLAN.md

# Project Plan

Multiplayer Tower Math Game (Flutter)

Dokumen ini menjelaskan rencana implementasi bertahap untuk membangun game tower matematika berbasis Flutter.

Dokumen ini digunakan oleh AI agent dan developer untuk memahami:

- urutan pekerjaan
- prioritas fitur
- struktur implementasi

---

# Phase 0 — Environment & Dependencies

Environment project **sudah disiapkan sebelumnya oleh developer**.

AI Agent **TIDAK PERLU**:

- mengubah Flutter version
- menambahkan dependency baru tanpa alasan kuat
- mengubah konfigurasi Firebase

Dependency berikut **sudah tersedia di project**:

```yaml
dependencies:
  flame: ^1.30.1
  flame_forge2d: ^0.19.0+4
  firebase_core: ^4.5.0
  firebase_auth: ^6.2.0
  firebase_database: ^12.1.4
  uuid: ^4.5.3
  collection: ^1.19.1
```

Penjelasan dependency:

flame
Digunakan untuk game engine dan rendering.

flame_forge2d
Digunakan jika dibutuhkan physics simulation pada tower atau mobil.

firebase_core
Inisialisasi Firebase.

firebase_auth
Autentikasi user.

firebase_database
Realtime database untuk multiplayer state.

uuid
Digunakan untuk membuat ID unik player atau session.

collection
Utility tambahan untuk manipulasi list dan map.

---

# Firebase Configuration

Firebase **sudah dikonfigurasi oleh developer**.

Hal berikut **sudah tersedia**:

- Firebase Project
- Firebase initialization
- Google Services configuration

Untuk Android:

File berikut sudah tersedia:

```id="firebase-android-config"
android/app/google-services.json
```

AI Agent **tidak perlu membuat ulang konfigurasi Firebase**.

Jika Firebase digunakan, cukup lakukan:

```dart
await Firebase.initializeApp();
```

---

# Phase 1 — Project Setup

Tujuan fase ini adalah membuat struktur project yang stabil dan siap dikembangkan.

Tasks:

1. Setup routing aplikasi
2. Menyiapkan theme dasar
3. Membuat struktur folder

Struktur folder yang direkomendasikan:

```
lib/

main.dart

pages/
- lobby_page.dart
- game_page.dart

widgets/
- tower_widget.dart

models/
- team_model.dart
```

---

# Phase 2 — Data Model

Membuat model data utama game.

Model utama:

Team

Fields:

name
target
players

Players adalah list berisi 5 slot.

Contoh:

players = [200, 450, 700, null, null]

Penjelasan:

angka → pemain sudah bermain
null → slot kosong

---

# Phase 3 — Reusable Widgets

Membuat widget reusable yang akan dipakai di seluruh game.

Widgets utama:

TowerWidget
CarWidget

---

## TowerWidget Responsibilities

TowerWidget harus bisa menampilkan:

- tinggi tower
- warna tower
- icon user
- icon tambah
- mobil di atas tower

Parameter:

value
target
showCar
filledPlayer
showAdd
width
onTap

Tower harus menggunakan:

AnimatedContainer untuk animasi tinggi.

---

# Phase 4 — Lobby Page

Membangun halaman lobby yang menampilkan semua tim.

Layout:

Vertical scroll list.

Setiap tim memiliki section.

Struktur per tim:

Team Name

Target Tower | Player1 | Player2 | Player3 | Player4 | Player5

---

# Phase 5 — Join Interaction

Ketika user klik tower kosong:

Flow:

1. Jalankan animasi klik
2. Tandai slot sebagai pemain
3. Navigasi ke Game Page

Game Page menerima parameter:

teamName
playerIndex

---

# Phase 6 — Game Page UI

Game Page menampilkan dua tower.

Layout:

Target Tower (Left) | Player Tower (Right)

---

# Phase 7 — Game Controls

Menambahkan kontrol gameplay.

Tombol:

+10
×2

---

# Phase 8 — Game Top Bar

Menambahkan top bar di Game Page.

Isi:

Back Button
Restart Button
Timer
Moves Counter

---

# Phase 9 — Tower Logic

Menghitung tinggi tower.

Formula:

height = (value / target) \* maxHeight

maxHeight = 180 px

Minimum height:

40 px

---

# Phase 10 — Tower Color Logic

Warna tower ditentukan dari progress.

progress = value / target

Rules:

progress < 0.3 → Green
progress < 0.6 → Yellow
progress < 0.9 → Orange
progress ≥ 0.9 → Red

Slot kosong selalu grey.

---

# Phase 11 — Win Condition

Jika:

value == target

Flow:

1. Player menang
2. Jalankan animasi kemenangan
3. Kembali ke lobby
4. Update tower pemain

---

# Phase 12 — Animations

Animasi wajib:

Tower Growth
Button Click
Join Tower Animation

---

# Phase 13 — UI Improvements

Tambahan polish UI:

- rounded tower
- shadow tower
- warna cerah
- spacing nyaman

UI harus menyerupai casual mobile game.

---

# Phase 14 — Testing

Hal yang harus diuji:

- tidak ada overflow layout
- tower scaling benar
- animasi berjalan
- navigasi lobby → game → lobby

---

# Phase 15 — Future Features (Implemented)

Fitur future yang sudah diimplementasikan dalam versi saat ini:

- Realtime multiplayer menggunakan Firebase Realtime Database (Lobby & Game sinkron)
- Team leaderboard (halaman Leaderboard)
- Animated car race (Team Race di Lobby)
- Team progress bar (Leaderboard)

Fitur tambahan yang belum diimplementasikan:

- Sound effects
- Global ranking cross-room

---

# Phase 16 — Competitive Match Mode (Flame, 2 Tim)

Mode kompetitif baru menggunakan Flame dengan aturan:

1. Maksimal 8 pemain, dibagi 2 tim: **Tim A vs Tim B**.
2. Setiap tim memiliki:
   - Satu **angka target global** (sama untuk kedua tim, misalnya `1000`).
   - **20 menara aktif** sekaligus, masing-masing memiliki **nilai awal** unik (contoh: `10, 20, 25, 10, 40, ...`).
3. Syarat kemenangan:
   - Tim yang menyelesaikan **paling banyak menara** dalam **5 menit** dinyatakan menang.
4. Regenerasi menara:
   - Ketika sebuah menara selesai, **segera generate menara baru**.
   - Kedua tim selalu menerima **set menara identik** (nilai awal dan urutan sama).
   - Aturan pembuatan menara:
     - Nilai awal acak dalam rentang `5..100`.
     - Harus dapat diselesaikan dalam batasan numerik global.

---

# Phase 17 — Flame Game Board & Towers

Arena pertandingan akan menggunakan engine **Flame**:

- Papan permainan tim dirender dengan komponen Flame:
  - Setiap menara adalah **komponen Flame** terpisah.
  - Status visual menara diwakili oleh tampilan Flame:
    - 🟢 Tersedia
    - 🟡 Diklaim (menampilkan siapa yang mengklaim)
    - ✅ Selesai (abu-abu, menampilkan penyelesai + jumlah langkah)
- Layout utama (mode portrait):
  - Layar dibagi vertikal 50/50:
    - Bagian atas: **Arena Tim A**
    - Bagian bawah: **Arena Tim B**
- Setiap arena tim menampilkan:
  - Nilai target (di kiri, tampilan menonjol).
  - Grid / list scrollable 20 menara:
    - Menampilkan nilai awal menara.
    - Indikator status (🟢 / 🟡 / ✅).
  - Penghitung skor tim.
  - Timer countdown global (disinkronkan lewat Firebase).

Loop game Flame:

- Menggunakan **game loop internal Flame** untuk:
  - Memperbarui status menara.
  - Menjalankan animasi.
  - Memperbarui tampilan timer.
  - Memberi efek UI waktu nyata (highlight, feedback).

---

# Phase 18 — Tower Interaction & Claim Logic

Interaksi menara diatur penuh oleh Flame + Firebase:

- Input Flame:
  - Menara bisa disentuh menggunakan:
    - Tap callback / `TapDetector`.
  - Menyentuh menara memicu logika **upaya klaim** menara di Firebase (transaksi).
- Overlay upaya menara (modal Flutter di atas Flame):
  - Pemicu: user mengetuk menara **🟢 Tersedia** di tim mereka.
  - Alur:
    1. Mencoba **mengklaim menara** melalui **transaksi** di Firebase RTDB.
    2. Jika klaim berhasil → buka overlay modal.
    3. Jika klaim gagal → tampilkan pesan `"Menara sudah diklaim"`.
  - Di dalam overlay:
    - Tombol operasi:
      - `+10` → `value = value + 10`.
      - `×2` → `value = value * 2`.
      - Setiap operasi menambah counter `moves`.
    - **Kondisi menang**: `currentValue == target`:
      - Simpan status `✅ selesai` ke Firebase (transaksional).
      - Tutup overlay.
      - Jalankan animasi keberhasilan (Flame + Flutter).
    - **Kondisi tidak tercapai**:
      - Jika kedua operasi tidak valid (akan melebihi batas numerik).
      - Tampilkan `"Tidak dapat dijangkau - Silakan restart"`.
      - Paksa user untuk restart atau menutup overlay.
    - Tombol **Restart**:
      - Reset keadaan lokal:
        - `currentValue = startingValue`.
        - `moves = 0`.
      - **Tidak** melepas klaim (pemain tetap pemilik menara).

---

# Phase 19 — Numeric Constraints & Validation

Aturan numerik global yang harus selalu dipatuhi:

- Hanya bilangan bulat.
- Rentang nilai: `0 ≤ value ≤ 200.000`.
- Operasi yang diizinkan:
  - `+10`: menambah 10.
  - `×2`: mengalikan dengan 2.
- Gerakan tidak sah:
  - Jika hasil operasi **di luar rentang** (`< 0` atau `> 200.000`):
    - Tombol operasi tersebut harus dinonaktifkan / tampil abu-abu.
    - Operasi tidak boleh dieksekusi.
- Validasi ini diterapkan:
  - Di sisi client (UI, agar tombol disable).
  - Di sisi server/RTDB (validasi tambahan jika diperlukan).

---

# Phase 20 — AFK Detection & Auto-Release Towers

Sistem pemantauan AFK wajib untuk mode kompetitif:

- Pelacakan aktivitas pemain:
  - Simpan cap waktu `lastSeenAt` untuk setiap pemain di Firebase.
  - Update setiap ~5 detik saat aplikasi aktif.
  - Ambang AFK: **30 detik** tanpa aktivitas → pemain dianggap AFK.
- Pelepasan otomatis menara yang diklaim:
  - Jika pemain sedang mengklaim menara dan menjadi AFK:
    - Setelah **15 detik** AFK, menara dilepas otomatis.
    - Status menara kembali ke 🟢 Tersedia.
    - Pemain lain dapat melihat notifikasi bahwa menara kembali tersedia.
- Indikator pemain AFK:
  - Tampilkan badge AFK di daftar pemain.
  - Nama pemain di daftar tim digelapkan / di-abu-kan.
- Pelacakan skor lanjutan:
  - Menara diselesaikan per pemain.
  - Rata-rata langkah per penyelesaian.
  - Waktu dihabiskan per menara.
  - Persentase waktu dalam status AFK per pemain.

---

# Phase 21 — Simulation Mode (Bot Players)

Mode simulasi untuk menguji koordinasi waktu nyata menggunakan pemain bot.

Tujuan:

- Menguji flow realtime match (Flame + Firebase) bahkan hanya dengan satu perangkat.
- Memungkinkan stress-test sederhana tanpa banyak pemain manusia.

Opsi implementasi:

1. Bot di dalam aplikasi:
   - Menggunakan Dart `Timer` / isolates untuk menjalankan logika bot di background.
2. Beberapa instance aplikasi:
   - Menjalankan app di banyak emulator/perangkat, masing-masing mengontrol 1 bot.

Perilaku bot:

- Memilih menara 🟢 tersedia secara acak dari tim yang ditugaskan.
- Menggunakan algoritma pemecah optimal (atau hampir optimal dengan sedikit random delay) untuk mencapai target dengan operasi `+10` dan `×2`.
- Menyimpan solusi/progres ke Firebase seperti pemain sungguhan.
- Meniru waktu manusia:
  - Penundaan 1–3 detik antara setiap gerakan.

Kontrol debug yang diharapkan:

- UI khusus (hanya untuk developer) untuk:
  - Meluncurkan 1–6 bot.
  - Mengatur bot ke tim (auto-balance atau manual assign ke Tim A/B).
  - Memulai / menghentikan simulasi bot.
  - Menyesuaikan tingkat keterampilan bot (gerakan optimal vs acak).

Status:

- Belum diimplementasikan dalam kode (hanya rencana di dokumen ini).

---

# Success Criteria

Game dianggap berhasil jika:

- Lobby menampilkan multi team.
- Player bisa join slot kosong.
- Game page berjalan.
- Tower naik sesuai operasi.
- Tidak ada UI overflow.
- Animasi berjalan smooth.
- Mode kompetitif berbasis Flame dapat ditambahkan bertahap mengikuti Phase 16–20 tanpa merusak mode simulasi awal.

---

# Phase Status Summary

- **Phase 0 — Environment & Dependencies**: ✅ Sudah disiapkan oleh developer.
- **Phase 1 — Project Setup**: ✅ DONE (routing, theme dasar, struktur folder sesuai).
- **Phase 2 — Data Model**: ✅ DONE (`Team` dengan `name`, `target`, `List<int?> players`).
- **Phase 3 — Reusable Widgets**: ✅ DONE (`TowerWidget`, `CarWidget`, animasi dasar ada).
- **Phase 4 — Lobby Page**: ✅ DONE (multi-team list, target + 5 player towers per tim).
- **Phase 5 — Join Interaction**: ✅ DONE (klik slot kosong → join → navigate ke `GamePage` dengan parameter).
- **Phase 6 — Game Page UI**: ✅ DONE (Target Tower kiri, Player Tower kanan).
- **Phase 7 — Game Controls**: ✅ DONE (tombol `+10` dan `×2` berfungsi).
- **Phase 8 — Game Top Bar**: ✅ DONE (Back, Restart, Timer statis, Moves Counter).
- **Phase 9 — Tower Logic**: ✅ DONE (height = (value/target) * 180 dengan min 40px).
- **Phase 10 — Tower Color Logic**: ✅ DONE (warna berdasarkan progress, slot kosong abu-abu).
- **Phase 11 — Win Condition**: ✅ DONE (value == target → snackBar + kembali ke Lobby + update tower).
- **Phase 12 — Animations**: ✅ DONE (tower growth via AnimatedContainer, button click, join tower).
- **Phase 13 — UI Improvements**: ✅ DONE (rounded tower, shadow, warna cerah, layout casual mobile).
- **Phase 14 — Testing**: ⚠️ PARTIAL (sudah ada testing manual, belum ada automated tests).
- **Phase 15 — Future Features (simulasi)**: ⚠️ PARTIAL (realtime, leaderboard, car race, progress bar sudah; sound & global ranking belum).
- **Phase 16 — Competitive Match Mode (Flame, 2 tim)**: ⚠️ PARTIAL (model & 20 tower + skor sudah; join 8 pemain, auto team assignment, regenerasi tower & win screen belum).
- **Phase 17 — Flame Game Board & Towers**: ⚠️ PARTIAL (board dua arena + tower & skor sudah; timer countdown & animasi lanjut belum).
- **Phase 18 — Tower Interaction & Claim Logic**: ⚠️ PARTIAL (tap + klaim + overlay + complete sudah; unreachable-detection matematis & animasi khusus belum).
- **Phase 19 — Numeric Constraints & Validation**: ✅ DONE di client (0 ≤ value ≤ 200.000, tombol disable); validasi server-side belum.
- **Phase 20 — AFK Detection & Auto-Release**: ⚠️ PARTIAL (`lastSeenAt` + heartbeat + auto-release klaim sudah; badge AFK & statistik per pemain di UI belum).
- **Phase 21 — Simulation Mode (Bot Players)**: ⛔ NOT IMPLEMENTED (belum ada bot, kontrol debug, atau algoritma solver).

---
