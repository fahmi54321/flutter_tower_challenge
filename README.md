## Ringkasan Penyelesaian Proyek

Dokumen ini menjelaskan secara singkat bagaimana saya menyelesaikan proyek **Multiplayer Tower Math Game (Flutter + Firebase RTDB)** berdasarkan spesifikasi tugas pada Notion.

Referensi tugas:  
`https://www.notion.so/Internship-Test-Assignment-Realtime-Team-Mini-Game-Flutter-Firebase-RTDB-31a836a2c99e8009b18fe2b7501f9f1a`

---

## 1. Memahami Tugas & Mendesain dengan AI

- Saya membaca dokumen tugas di Notion untuk memahami:
  - Kebutuhan fitur (lobby multi team, game tower, realtime, leaderboard, match mode, dll).
  - Keterbatasan teknis (Flutter + Firebase Realtime Database, Flame, dsb).
- Setelah memahami kebutuhan, saya:
  - Mendiskusikan desain alur game, data model, dan struktur halaman dengan AI (ChatGPT) secara iteratif.
  - Menghasilkan desain awal:
    - Model `Team` dan kemudian model kompetitif `MatchState`.
    - Alur Lobby → Game, dan alur mode match kompetitif.
    - Rencana bertahap dalam bentuk fase (Phase 0–21) agar implementasi bisa dipecah kecil-kecil.

---

## 2. Menyusun `AGENTS.md` & `PLAN.md` Sesuai Task dan Project

- Setelah desain dasar cukup jelas, saya membuat:
  - `AGENTS.md` sebagai kontrak untuk AI agent:
    - Menjelaskan core concept game, UI yang diharapkan, data model `Team`, logika tower, animasi, dan struktur file.
  - `PLAN.md` sebagai rencana implementasi bertahap:
    - Phase 0–14 untuk mode simulasi (Lobby + Game).
    - Phase 15–20 untuk fitur lanjutan dan mode kompetitif.
    - Phase 21 untuk mode simulasi dengan bot.
- Saya menyesuaikan `PLAN.md` dan `AGENTS.md` dengan **initial Flutter project** yang saya pakai:
  - Flutter SDK: **3.38.7**.
  - Dependency utama:
    ```yaml
    flame: ^1.30.1
    flame_forge2d: ^0.19.0+4
    firebase_core: ^4.5.0
    firebase_auth: ^6.2.0
    firebase_database: ^12.1.4
    uuid: ^4.5.3
    collection: ^1.19.1
    ```
  - Hal ini memastikan rencana di `PLAN.md` realistis dengan versi library yang saya gunakan.

---

## 3. Menggunakan GitHub Copilot untuk Memahami `AGENTS.md` & `PLAN.md`

- Setelah dokumen aturan dan rencana siap, saya mengaktifkan **GitHub Copilot** di editor.
- Tujuan utamanya:
  - Membantu Copilot “mengerti konteks” dari `AGENTS.md` dan `PLAN.md`.
  - Membiarkan Copilot memberi saran kode yang konsisten dengan:
    - Struktur data (`Team`, `MatchState`, dll).
    - Struktur folder (`pages/`, `widgets/`, `model/`, `services/`, `game/`).
    - Aturan UI dan animasi yang sudah dituliskan.
- Copilot saya gunakan sebagai asisten auto-completion dan stub code, tetapi seluruh arsitektur, flow, dan fase tetap mengacu ke `PLAN.md`.

---

## 4. Implementasi Phase 1–9 (Mode Simulasi Dasar)

Saya memulai implementasi dari **Phase 1 sampai Phase 9** yang fokus pada mode simulasi awal:

- **Phase 1 – Project Setup**
  - Menyiapkan routing dasar (`main.dart`), theme, dan struktur folder (`pages/`, `widgets/`, `model/`).
- **Phase 2 – Data Model**
  - Membuat model `Team` (`name`, `target`, `List<int?> players`).
- **Phase 3 – Reusable Widgets**
  - Membuat `TowerWidget` dan `CarWidget` sebagai komponen reusable.
- **Phase 4 – Lobby Page**
  - Membangun `LobbyPage` yang menampilkan semua tim dan tower pemain.
- **Phase 5 – Join Interaction**
  - Implementasi klik slot kosong → join ke tim → navigasi ke `GamePage`.
- **Phase 6 – Game Page UI**
  - Tata letak `Target Tower` di kiri dan `Player Tower` di kanan.
- **Phase 7 – Game Controls**
  - Menambahkan tombol `+10` dan `×2` di bagian bawah.
- **Phase 8 – Game Top Bar**
  - Menambahkan AppBar dengan tombol Back, Restart, Timer (simulasi), dan Moves Counter.
- **Phase 9 – Tower Logic**
  - Mengimplementasikan tinggi tower:
    - `height = (value / target) * maxHeight` dengan `maxHeight = 180` dan `minHeight = 40`.

Pada tahap ini, mode simulasi dasar (Lobby + Game) sudah berjalan dari ujung ke ujung.

---

## 5. Melanjutkan Phase 10–20 (Fitur Lanjutan & Mode Kompetitif)

Setelah beberapa sesi, saya sempat terkena batas token di AI, jadi pekerjaan dilanjutkan dalam sesi berikutnya untuk **Phase 10–20**:

- **Phase 10 – Tower Color Logic**
  - Mengatur warna tower berdasarkan progress (hijau → kuning → oranye → merah), slot kosong abu-abu.
- **Phase 11 – Win Condition**
  - Menyelesaikan logika `value == target` → animasi/snackbar → kembali ke Lobby dan update tower.
- **Phase 12 – Animations**
  - Menyempurnakan:
    - Animasi pertumbuhan tower (`AnimatedContainer`).
    - Animasi klik tombol (`PressButton` dengan `AnimatedScale`).
    - Animasi join tower kosong.
- **Phase 13 – UI Improvements**
  - UI lebih “casual mobile game”: rounded, shadow, warna cerah, spacing nyaman.
- **Phase 14 – Testing**
  - Pengujian manual di emulator:
    - Overflow, scaling tower, animasi, flow navigasi.
- **Phase 15 – Future Features (Simulasi)**
  - Menambahkan:
    - Realtime sync `Lobby` & `Game` via Firebase RTDB.
    - Halaman `Leaderboard` dengan ranking per team.
    - `Team Race` di Lobby (mobil berjalan berdasarkan progress tower).
- **Phase 16–20 – Mode Kompetitif dengan Flame**
  - Membuat model `MatchState`, `MatchTower`, `MatchPlayer`.
  - `MatchService` untuk membuat/watching match dan transaksi klaim tower.
  - `MatchGame` (Flame) untuk papan 2 tim (atas/bawah) dengan 20 tower aktif.
  - `MatchPage` (Flutter + Flame):
    - Meng-handle tap tower, klaim via Firebase, overlay `+10`/`×2`/Restart/Selesai.
  - Numeric constraints global:
    - `0 ≤ value ≤ 200000`, tombol disable jika operasi keluar batas.
  - AFK detection:
    - `lastSeenAt`, heartbeat 5 detik sekali, auto-release klaim tower jika pemain AFK terlalu lama.

**Phase 21 (bot simulation)** ditulis di `PLAN.md`, tetapi **belum saya implementasikan** di kode karena keterbatasan waktu/limit.

---

## 6. Penutup

Secara garis besar, saya:

1. Memahami spesifikasi dari Notion dan mendesain alur game bersama AI.
2. Menerjemahkan desain menjadi `AGENTS.md` dan `PLAN.md` yang terstruktur.
3. Menggunakan GitHub Copilot sebagai asisten untuk mempercepat penulisan kode, tetap mengikuti `PLAN.md`.
4. Mengimplementasikan Phase 1–20 secara bertahap (mode simulasi + mode kompetitif).
5. Mendokumentasikan progres dan status fase di `PLAN.md` dan ringkasan di dokumen ini.

---

## Penjelasan Halaman Utama

### Lobby Page

- **Tujuan:**
  - Menjadi titik masuk utama pemain.
  - Menampilkan semua tim dan status tower pemain.
- **Fungsi utama:**
  - Menampilkan list tim dalam bentuk section:
    - Target tower + 5 tower pemain per tim.
  - Slot tower kosong (`null`) bisa diklik untuk **join ke tim**.
  - Menampilkan **Team Race** (mobil yang bergerak berdasarkan progress tim).
  - Akses ke:
    - **GamePage** (mode simulasi) ketika join slot kosong.
    - **LeaderboardPage** melalui ikon leaderboard.
    - **MatchPage** (debug button) untuk masuk ke mode kompetitif.

### Game Page (Mode Simulasi)

- **Tujuan:**
  - Halaman permainan utama untuk satu pemain dan satu tower dalam tim.
- **Fungsi utama:**
  - Menampilkan:
    - Target tower di kiri (penuh, ada mobil).
    - Player tower di kanan (berubah tinggi sesuai value).
  - AppBar:
    - Back ke Lobby.
    - Restart (reset value dan moves).
    - Timer (simulasi, teks statis).
    - Moves counter.
  - Tombol kontrol:
    - `+10` → value bertambah 10.
    - `×2` → value dikali 2.
  - Win condition:
    - Jika `value == target`, menampilkan notifikasi kemenangan dan kembali ke Lobby dengan nilai tower ter-update.

### Leaderboard Page

- **Tujuan:**
  - Menampilkan peringkat tim berdasarkan performa tower.
- **Fungsi utama:**
  - Menggunakan data realtime dari Firebase untuk:
    - Mengurutkan tim berdasarkan jumlah tower selesai dan progress terbaik.
    - Menampilkan:
      - Nama tim, target.
      - Progress bar (animated) untuk best progress tim.
      - Statistik singkat (completed towers, best progress %).
  - Memberi gambaran cepat tim mana yang paling progresif.

### Match Page (Mode Kompetitif, Flame)

- **Tujuan:**
  - Menjadi papan pertandingan realtime 2 tim (A vs B) dengan 20 menara aktif, menggunakan Flame.
- **Fungsi utama:**
  - Menampilkan `MatchGame` (Flame) dengan:
    - Arena atas = Tim A, arena bawah = Tim B.
    - 20 tower per tim (grid 4×5) dengan status:
      - 🟢 Available
      - 🟡 Claimed
      - ✅ Completed
    - Target global dan skor Tim A/B.
  - Overlay klaim tower:
    - Saat pemain mengetuk tower 🟢 available:
      - Mencoba klaim via transaksi Firebase.
      - Jika sukses → membuka modal dengan:
        - Nilai awal, current value, langkah.
        - Tombol `+10`, `×2`, `Restart`, dan `Selesai`.
    - Menyimpan progres ke Firebase seperti pemain sungguhan.
  - Numeric constraints dan AFK detection:
    - Menjaga agar operasi tetap dalam batas nilai.
    - Melepas klaim tower jika pemain AFK terlalu lama.

Halaman-halaman ini bersama-sama membentuk:

- Mode simulasi tower per pemain/tim (Lobby + Game + Leaderboard).
- Fondasi mode kompetitif realtime (Lobby + Match + backend Firebase).
