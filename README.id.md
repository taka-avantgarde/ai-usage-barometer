🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 Bahasa Indonesia · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

**Pantau Claude, Codex, dan Gemini secara sekilas dalam waktu nyata di 3 tempat Mac: bilah menu, ikon Dock, dan bilah mengambang.**

| Layanan AI | Warna | Sumber yang didukung |
|:---|:---|:---|
| **Claude** | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | Claude Code (API penggunaan OAuth & Rantai Kunci) |
| **Codex** | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | Codex CLI & token web (`5h` & `1w`) |
| **Gemini** | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` | Google Antigravity Desktop & IDE (`5h` & `1w`) |

<img src="assets/hero.svg" alt="AI Usage Barometer di bilah menu, ikon Dock, dan bilah mengambang" width="725">

## ⚡ Instalasi — tempel satu baris ini di Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

Itu aplikasinya. Tanpa Homebrew, tanpa Xcode. macOS 13 atau lebih baru. Saat pertama dijalankan ia menanyakan mau ditaruh di mana — bilah menu, ikon Dock, atau bilah mengambang — dan Anda bisa mengubahnya kapan saja dari menunya.

## Satu item di bilah menu

Claude, Codex, dan Gemini berbagi satu item, dipisahkan garis tipis. Bilah bergaya baterai: **bagian terisi adalah kapasitas tersisa**, ekor bertitik adalah yang sudah terpakai. Persentase juga menunjukkan sisa.

```text
5h ███░·  1w ██░░·  │  5h ████·  1w ███░·  │  5h ████·  1w ███░·
└──── Claude ────┘     └───── Codex ─────┘     └──── Gemini ────┘
```

Bilah menu digambar sebagai gambar vektor sehingga tiap layanan mempertahankan warnanya dalam satu item. Jika tidak memungkinkan, otomatis beralih ke teks biasa.

Kedua palet memakai warna jenuh dengan kontras tinggi: Claude menggunakan
oranye dan Codex sian. Saat tersisa 11–30%, warna peringatan mencampurkan
oranye; saat tersisa 10% atau kurang, warna kritis mencampurkan merah cerah.
Codex mempertahankan unsur biru kuat pada kedua campuran:

| Tahap | Pemakaian | Claude | Codex | Gemini |
|---|---:|---|---|---|
| normal | 0–69% terpakai | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` |
| peringatan | 70–89% terpakai | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` | ![#5E7B3A](assets/colors/gemini-warning.svg) `#5E7B3A` |
| kritis | 90–100% terpakai | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` | ![#8C3B5A](assets/colors/gemini-critical.svg) `#8C3B5A` |

## Pengaturan

Klik bilah lalu pilih **⚙ Display settings**. Panel pengaturan tetap terbuka sehingga beberapa opsi dapat diubah berurutan tanpa membukanya lagi setelah setiap klik. Perubahan langsung berlaku.

Antarmuka plugin hanya tersedia dalam bahasa Inggris. Dokumentasi GitHub ini tetap tersedia dalam 14 bahasa.

| Pengaturan | Efek |
|---|---|
| Tampilkan Claude | Tampilkan atau sembunyikan Claude |
| Tampilkan Claude 5h | Tampilkan atau sembunyikan jendela 5 jam |
| Persentase Claude 5h | Tampilkan atau sembunyikan persentasenya |
| Tampilkan Claude 1w (7d) | Tampilkan atau sembunyikan jendela 7 hari |
| Persentase Claude 1w (7d) | Tampilkan atau sembunyikan persentasenya |
| Tampilkan Codex | Tampilkan atau sembunyikan Codex |
| Tampilkan jendela Codex 1 | Tampilkan atau sembunyikan jendela pertama yang dilaporkan Codex (e.g. Codex 5h) |
| Persentase jendela Codex 1 | Tampilkan atau sembunyikan persentasenya |
| Tampilkan jendela Codex 2 | Tampilkan atau sembunyikan jendela kedua, jika ada (e.g. Codex 7d) |
| Persentase jendela Codex 2 | Tampilkan atau sembunyikan persentasenya |
| Tampilkan Gemini | Tampilkan atau sembunyikan Gemini |
| Tampilkan Gemini 5h / % | Tampilkan atau sembunyikan jendela 5h dan persentasenya |
| Tampilkan Gemini 1w / % | Tampilkan atau sembunyikan jendela 1 minggu (7d) dan persentasenya |
| Interval penyegaran | 1, 3, atau 5 menit |

Saat semua meter disembunyikan, item netral `AI …` tetap tersedia untuk membuka pengaturan. Warna hanya ditentukan oleh bilah yang tampil. Pengaturan tersimpan di `~/.cache/claude-codex-bar/` dan bertahan setelah pembaruan.

Saat Claude atau Codex dinonaktifkan, pembaruan data untuk layanan tersebut dihentikan. Pengaturan 5 jam, 7 hari, dan persentase tetap terlihat redup serta terkunci; nilai sebelumnya dipulihkan saat layanan diaktifkan kembali.

Jika jendela 5 jam dan 7 hari suatu layanan sama-sama tidak dicentang, layanan beserta galatnya disembunyikan sepenuhnya dan sumber datanya tidak diakses.

Plugin memeriksa GitHub Releases paling banyak sekali sehari. Jika ada pembaruan dari operator, menu dan pengaturan menampilkan pemberitahuan, catatan rilis, dan **Perbarui sekarang**.

## Aplikasinya — pilih tempatnya

Bilah menu tidak selalu tersedia. Di sebagian Mac, item status ditaruh di luar
layar dan tidak pernah digambar, dan di samping poni bisa jadi memang tidak ada
ruang. Aplikasi menaruh pengukur yang sama di tempat yang Anda pilih.

| Tempat | Keterangan |
|---|---|
| **Bilah menu** | Item status milik aplikasi sendiri, satu baris |
| **Ikon Dock** | Ikon Dock itu sendiri menjadi pengukurnya. Tidak memakan layar |
| **Bilah mengambang** | Bilah kecil yang selalu di depan. Seret ke mana saja |

Ketiganya berdiri sendiri — nyalakan kombinasi apa pun. Klik kanan pada bilah,
ikon Dock, atau item bilah menu untuk membuka pengaturan: tiap layanan nyala
atau mati, persentase, tempatnya, dan **Details…** untuk panel berisi waktu
pemulihan.

Mematikan satu pengukur mengembalikan lebarnya: itemnya menyusut pas dengan sisa isinya, dan bilah menu mendapat selisihnya.

Panah oranye berarti ada pembaruan yang menunggu. **Update to vX.Y.Z** di menu yang sama memasangnya di tempat.

Satu baris saja, tanpa Xcode. macOS 13 atau lebih baru.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

Aplikasi ini sudah ditandatangani dan dinotarisasi Apple, jadi langsung bisa dibuka setelah diunduh — tanpa peringatan, tanpa klik kanan.

Atau jalankan dari kode sumber, dan untuk itu Xcode memang diperlukan:

```bash
git clone https://github.com/taka-avantgarde/ai-usage-barometer.git
cd ai-usage-barometer/app && swift run
```

## Sumber data

**Claude** dibaca dari endpoint OAuth `api.anthropic.com/api/oauth/usage`, memakai token yang sudah disimpan Claude Code di Keychain macOS (`Claude Code-credentials`, atau `~/.claude/.credentials.json`). Tidak ada penulisan ke keduanya, dan token hanya meninggalkan Mac dalam permintaan ke Anthropic. Saat pertama kali, pilih **Selalu Izinkan**.

Hasil disimpan sementara selama interval, jadi endpoint dipanggil paling banyak sekali per interval. Jika gagal, nilai valid terakhir tetap ditampilkan.

**Codex** dibaca dari pembantu lokal `codex-usage.sh` yang ditempatkan pemasang di `.ai-usage-barometer/`. Jendelanya dinamis baik jumlah maupun namanya — perubahan paket bisa mengubah `5h`/`7d` menjadi sesuatu seperti `30d` — jadi kedua sakelar di atas mengikuti jendela pertama dan kedua yang benar-benar dikembalikan Codex, dan panel pengaturan akan mengganti namanya agar sesuai.

## Pemecahan masalah

**Muncul peringatan Claude.** Buka menu dropdown untuk melihat alasannya. *Sign in to Claude Code again* berarti token OAuth kedaluwarsa — masuk ulang lewat CLI Claude Code atau ekstensi IDE. **Ini bukan aplikasi desktop Claude**: masuk ke Claude.app tidak memperbarui token ini. *Rate limited* akan hilang sendiri; plugin menunggu 15 menit dan menampilkan sisa waktu.

**Muncul peringatan Codex.** Pembantu tidak ada atau Codex belum menghasilkan data. Jalankan ulang pemasang lalu gunakan Codex CLI sekali.

**Gemini menampilkan peringatan.** Antigravity belum dijalankan atau pembantu lokal sedang menunggu data. Buka Antigravity Desktop atau Antigravity IDE.

**Warna berbeda antara bilah menu dan menu.** macOS bisa memperlakukan bilah menu transparan sebagai terang meski menu gelap. Renderer vektor dua warna digunakan saat Python tersedia; teks satu warna hanya digunakan sebagai fallback saat Python tidak tersedia.

## Copot pemasangan

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Lisensi

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
