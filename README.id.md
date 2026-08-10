🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 Bahasa Indonesia · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalasi — tempel satu baris ini di Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Perintah yang sama bekerja dengan atau tanpa Homebrew. Hanya yang belum ada yang dipasang: Homebrew, `jq`, SwiftBar, plugin, dan pembantu lokalnya. Aman dijalankan ulang, gunakan baris yang sama untuk memperbarui.

## Satu item di bilah menu

Claude dan Codex berbagi satu item, dipisahkan garis tipis. Bilah bergaya baterai: **bagian terisi adalah kapasitas tersisa**, ekor bertitik adalah yang sudah terpakai. Persentase juga menunjukkan sisa.

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

Bilah menu digambar sebagai gambar vektor sehingga tiap layanan mempertahankan warnanya dalam satu item. Jika tidak memungkinkan, otomatis beralih ke teks biasa.

Warna mengikuti pemakaian, jadi bilah yang hampir habis tampak lebih pekat:

| Tahap | Pemakaian | Claude | Codex |
|---|---:|---|---|
| normal | 0–69% terpakai | `#C68976` | `#7299B9` |
| peringatan | 70–89% terpakai | `#B9755F` | `#3EA2B4` |
| kritis | 90–100% terpakai | `#B0644D` | `#F17D66` |

## Pengaturan

Klik bilah dan gunakan **⚙ Pengaturan tampilan**. Setiap entri beralih saat diklik dan langsung berlaku.

| Pengaturan | Efek |
|---|---|
| Tampilkan Claude | Tampilkan atau sembunyikan Claude |
| Tampilkan Claude 5h | Tampilkan atau sembunyikan jendela 5 jam |
| Persentase Claude 5h | Tampilkan atau sembunyikan persentasenya |
| Tampilkan Claude 7d | Tampilkan atau sembunyikan jendela 7 hari |
| Persentase Claude 7d | Tampilkan atau sembunyikan persentasenya |
| Tampilkan Codex | Tampilkan atau sembunyikan Codex |
| Persentase Codex | Tampilkan atau sembunyikan persentase Codex |
| Bilah menu dua warna | Vektor (dua warna) atau teks (satu warna) |
| Interval penyegaran | 1, 3, atau 5 menit |
| Bahasa | 14 bahasa; mengikuti macOS secara bawaan |

Menyembunyikan semuanya akan menyisakan item kosong yang tak bisa diklik, sehingga bilah 5 jam Claude selalu dipertahankan. Warna hanya ditentukan oleh bilah yang tampil. Pengaturan tersimpan di `~/.cache/claude-codex-bar/` dan bertahan setelah pembaruan.

## Sumber data

**Claude** dibaca dari endpoint OAuth `api.anthropic.com/api/oauth/usage`, memakai token yang sudah disimpan Claude Code di Keychain macOS (`Claude Code-credentials`, atau `~/.claude/.credentials.json`). Tidak ada penulisan ke keduanya, dan token hanya meninggalkan Mac dalam permintaan ke Anthropic. Saat pertama kali, pilih **Selalu Izinkan**.

Hasil disimpan sementara selama interval, jadi endpoint dipanggil paling banyak sekali per interval. Jika gagal, nilai valid terakhir tetap ditampilkan.

**Codex** dibaca dari pembantu lokal `codex-usage.sh` yang ditempatkan pemasang di `~/SwiftBar/.ai-usage-barometer/`. Jendelanya dinamis.

## Pemecahan masalah

**Muncul peringatan Claude.** Item Keychain tidak ditemukan. Masuk ke Claude Code di Mac ini lalu klik **Segarkan sekarang**.

**Muncul peringatan Codex.** Pembantu tidak ada atau Codex belum menghasilkan data. Jalankan ulang pemasang lalu gunakan Codex CLI sekali.

**Warna berbeda antara bilah menu dan menu.** macOS bisa memperlakukan bilah menu transparan sebagai terang meski menu gelap. Karena itu tiap tahap hanya memakai satu warna; jika masih janggal, matikan penggambaran dua warna.

## Copot pemasangan

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Lisensi

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
