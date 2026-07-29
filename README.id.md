🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 Bahasa Indonesia · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalasi — tempel satu baris ini di Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Perintah yang sama bekerja pada Mac dengan atau tanpa Homebrew. Jika diperlukan, perintah akan memasang Homebrew, `jq`, SwiftBar, plugin gabungan, dan helper Claude/Codex.

Satu item SwiftBar menampilkan kedua layanan. **Bilah menu macOS tidak menampilkan nama Claude atau Codex.** Claude memakai nuansa oranye dan Codex nuansa biru.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0: kedua masalah pemulihan telah diperbaiki

- **Claude setelah reset:** jika Claude mengembalikan `Warming up`, nilai nol, jendela null, atau snapshot lama yang waktu resetnya sudah lewat, plugin tidak lagi tersangkut pada kesalahan. Bilah 5h dan 7d dipulihkan sebagai sudah direset/menunggu dengan 100% tersisa, lalu otomatis diganti dengan nilai live pada penyegaran sukses berikutnya. Tidak perlu memasang ulang.
- **Codex 5h kembali kemudian:** jendela Codex dideteksi secara dinamis. Jika Codex kembali mengirim jendela 300 menit, bilah `5h` otomatis ditambahkan pada penyegaran berikutnya. Jika tidak ada, hanya jendela yang tersedia seperti `7d` yang ditampilkan.

Pilih **Refresh now** untuk meminta pembaruan segera.

## 🎨 Tiga tingkat warna independen

Setiap jendela 5h atau 7d dinilai secara terpisah.

| Tingkat | Penggunaan | Claude | Codex |
|---|---:|---|---|
| 1 — normal | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 — peringatan | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 — kritis | 90–100% | `#ff7045` | `#ed5d40` |

Header dibuat sebagai PDF vektor kecil memakai alat bawaan macOS, tanpa Xcode Command Line Tools.

## Pengaturan dan detail

Menu menampilkan nama layanan, penggunaan, kapasitas tersisa, dan waktu reset. Di **Settings**, Claude dan Codex dapat ditampilkan atau disembunyikan secara terpisah; setidaknya satu layanan tetap terlihat. Interval penyegaran dapat dipilih 1, 3, atau 5 menit.

> **Codex 5h:** plugin tidak menebak batas yang hilang. Bilah 5h disembunyikan sampai Codex mengirim jendela 300 menit yang nyata, lalu ditambahkan otomatis.

Plugin mandiri yang sudah ada dipindahkan ke folder dukungan tersembunyi agar tidak muncul ganda tanpa menghapus file.

## Persyaratan dan privasi

- macOS; installer menangani Homebrew, `jq`, dan SwiftBar.
- Claude Code sudah masuk.
- Codex CLI atau aplikasi Codex sudah digunakan di Mac.
- Token autentikasi tidak pernah dicetak atau disalin ke cache.
- Sebagian antarmuka data penggunaan tidak resmi dan mungkin memerlukan pembaruan kompatibilitas di masa mendatang.

## Hapus instalasi

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Lisensi

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
