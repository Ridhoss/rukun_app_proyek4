# RukunAPP

## Kelompok 1 - RiSa

### Anggota Tim:

* Ridho Sulistyo Saputro (241511059)
* Rifky Hermawan (241511060)
* Salma Arifah Zahra (241511062)
* Samudra Putra Gunawan (241511063)

---

## Deskripsi Aplikasi

**RukunAPP** adalah aplikasi mobile yang dirancang untuk memfasilitasi kegiatan manajemen data kependudukan dan keungan warga dalam lingkup RT maupun RW.

Aplikasi ini bertujuan untuk:

* Mempermudah manajemen data kependudukan warga
* Membantu pihak RW maupun RT dalam mengelola segala kegiatan iuran keuangan
* Mempermudah pihak RW maupun RT dalam mengetahui laporan kependudukan

Dengan pendekatan **offline-first**, pengguna tetap dapat mengakses data kependudukan dan keuangan sesuai kebutuhan, dan data akan disinkronkan ketika perangkat kembali online.

---

## Fitur Utama

* Manajemen data kependudukan warga dalam lingkup RT maupun RW
* Manajemen keuangan atau data iuran warga dalam lingkup RT maupun RW
* Mode offline
* Sinkronisasi otomatis saat online

---

## Teknologi yang Digunakan

* **Flutter** → Framework utama untuk pengembangan aplikasi mobile
* **Hive** → Database lokal untuk penyimpanan offline
* **hive_flutter** → Integrasi Hive dengan Flutter
* **connectivity_plus** → Mengecek status koneksi internet
* **lottie** → Animasi UI
* **path_provider** → Mengakses direktori penyimpanan perangkat
* **shadcn_flutter** → UI Component shadcn untuk flutter

---

## Arsitektur Aplikasi

Aplikasi ini menggunakan pendekatan:

* **MVVM (Model - View - View Model)**
* **SRP (Single Responsibility Principle)**

Struktur utama:

```
lib/
├── models/
├── views/
├── viewmodels/
├── services/
├── routes/
```

---

## Cara Menjalankan Project

1. Clone repository

```
git clone [link repository]
```

2. Masuk ke folder project

```
cd nama_project
```

3. Install dependency

```
flutter pub get
```

4. Jalankan aplikasi

```
flutter run
```

---

## Tujuan Pengembangan

Aplikasi ini dikembangkan sebagai bagian dari:

> Proyek pengembangan aplikasi mobile untuk melakukan manajement kependudukan dan keuangan dalam lingkup Rukun Warga (RW).

---

## Catatan

Aplikasi ini masih dalam tahap pengembangan dan akan terus diperbaiki serta dikembangkan untuk meningkatkan fitur dan keamanan sistem.

---

## Repository

https://github.com/Ridhoss/rukun_app_proyek4.git
