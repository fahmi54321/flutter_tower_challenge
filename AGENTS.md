# AGENTS.md

# Project

Multiplayer Tower Math Game (Flutter)

Game ini adalah mini game berbasis Flutter yang mensimulasikan kompetisi antar tim untuk menaikkan tower hingga mencapai target angka menggunakan operasi matematika sederhana.

Game terdiri dari dua halaman utama:

1. Lobby Page
2. Game Page

Game harus mendukung **multi team**.

---

# Core Concept

Setiap tim memiliki:

- 1 Target Tower
- 5 Player Towers

Pemain bergabung ke tim dengan mengklik slot tower kosong.

Ketika pemain bergabung, mereka akan masuk ke Game Page untuk menaikkan tower mereka.

---

# Data Model

Agent harus menggunakan struktur data berikut:

```
Team
- name: String
- target: int
- players: List<int?>
```

Penjelasan:

players adalah list berisi 5 slot:

- angka → tower sudah dimainkan
- null → slot kosong

Contoh:

Team A

players = [200, 450, 700, null, null]

---

# Lobby Page

## Layout

Lobby harus menampilkan **semua tim**.

Gunakan:

Scrollable vertical list.

Setiap tim ditampilkan dalam satu section.

Struktur:

Team Name

Target Tower | Player 1 | Player 2 | Player 3 | Player 4 | Player 5

Tower harus selalu **menempel ke bawah layar**.

---

# Target Tower

Karakteristik:

- berada di paling kiri
- value = target
- memiliki mobil di atas tower
- tidak bisa diklik

Contoh target:

1000

---

# Player Towers

Setiap tim memiliki **5 tower pemain**.

---

## Player Tower Filled

Jika slot berisi angka:

Karakteristik:

- memiliki icon user
- menampilkan angka tower
- tinggi tower berdasarkan nilai
- warna tower berdasarkan progress

Tower ini **tidak bisa diklik**.

---

## Player Tower Empty

Jika slot = null

Karakteristik:

- tower rendah
- icon "+"
- warna abu abu

Tower ini **bisa diklik**.

---

# Join Team Interaction

Jika user klik tower kosong:

1. Jalankan animasi klik
2. Slot berubah menjadi pemain
3. Navigasi ke Game Page
4. Game Page mengetahui:

teamName
playerIndex

---

# Tower Height Logic

Tinggi tower dihitung dari:

height = (value / target) \* maxHeight

maxHeight = 180 px

Minimum height:

40 px

---

# Tower Color Logic

progress = value / target

Rules:

progress < 0.3 → Green
progress < 0.6 → Yellow
progress < 0.9 → Orange
progress ≥ 0.9 → Red

Slot kosong:

Grey

---

# Game Page

Game page menampilkan tower target dan tower pemain.

Layout:

Target Tower (Left) | Player Tower (Right)

---

# Target Tower

Karakteristik:

- berada di kiri layar
- selalu full
- memiliki mobil di atas
- tidak bisa diklik

---

# Player Tower

Karakteristik:

- berada di kanan layar
- lebih lebar dari target tower
- tinggi tower berdasarkan value
- tidak memiliki mobil

---

# Game Top Bar

Game page harus memiliki:

Back Button
Restart Button
Timer
Moves Counter

---

# Back Button

Fungsi:

Kembali ke Lobby Page.

---

# Restart Button

Reset tower pemain.

Reset:

value = startingValue
moves = 0

---

# Timer

Menampilkan waktu permainan.

Format:

"7 Min"

Pada versi simulasi timer tidak perlu berjalan.

---

# Moves Counter

Menampilkan jumlah operasi yang telah dilakukan.

Contoh:

5 Moves

---

# Game Controls

Tombol berada di bagian bawah layar.

Tombol:

+10
×2

---

# +10 Button

Saat ditekan:

value = value + 10
moves = moves + 1

Animasi tower naik.

---

# ×2 Button

Saat ditekan:

value = value \* 2
moves = moves + 1

Animasi tower naik lebih cepat.

---

# Win Condition

Jika:

value == target

Maka:

1. Tower pemain selesai
2. Jalankan animasi kemenangan
3. Kembali ke lobby
4. Tower pemain di lobby diperbarui

---

# Animations

Agent harus menggunakan animasi berikut.

---

## Tower Growth

Saat value berubah:

AnimatedContainer height change

Durasi:

300ms

Curve:

easeOut

---

## Button Click Animation

Saat tombol ditekan:

scale animation

1.0 → 0.9 → 1.0

Durasi:

150ms

---

## Join Tower Animation

Saat user klik "+":

tower scale animation

icon "+" berubah menjadi icon user.

---

# UI Principles

UI harus terlihat seperti casual mobile game.

Gunakan:

- warna cerah
- rounded corners
- icon besar
- spacing nyaman

---

# Reusable Widgets

Agent harus menggunakan widget reusable berikut:

TowerWidget
CarWidget

TowerWidget harus memiliki parameter:

value
target
showCar
filledPlayer
showAdd
width
onTap

---

# State Management

Untuk simulasi:

Gunakan StatefulWidget.

Untuk production:

Direkomendasikan:

Provider
Riverpod
Game Controller

---

# Code Structure

Direkomendasikan struktur:

lib/

main.dart

pages/

- lobby_page.dart
- game_page.dart

widgets/

- tower_widget.dart

models/

- team_model.dart

---

# AI Agent Goals

AI Agent harus mampu:

- Menghasilkan UI multi team
- Menghindari overflow layout
- Mengimplementasikan animasi klik
- Membuat widget reusable
- Menjaga business logic game tetap konsisten
- Membuat code modular

---

# Future Expansion

Game harus mudah dikembangkan untuk:

- realtime multiplayer
- leaderboard team
- matchmaking
- global ranking
- animated car movement
- team progress race

---
