🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 Bahasa Indonesia · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalasi — tempel satu baris ini di Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Perintah yang sama bekerja dengan atau tanpa Homebrew dan memasang komponen yang diperlukan secara otomatis.

## ✅ v0.2.7: pemulihan menu bar yang stabil

v0.2.7 menyertakan helper Codex yang telah diuji langsung di repositori ini, menghapus sintaks `;;&` yang tidak kompatibel dengan Bash 3.2 bawaan macOS, dan membuat ulang header vektor berwarna tepat setelah setiap pembaruan.

Claude dan Codex dinilai secara terpisah: data yang tidak tersedia dari satu layanan tidak lagi menyembunyikan layanan lainnya. Setiap jendela 5h/7d memiliki tahap warna sendiri dan pilihan **Settings** yang sudah ada tetap dipertahankan.

## Sumber data Claude


Penggunaan Claude ditangkap dari JSON `statusLine` yang terdokumentasi melalui `rate_limits.five_hour` dan `rate_limits.seven_day`. Status line yang sudah ada tetap dipertahankan.

Setelah memasang, buka Claude Code dan selesaikan satu respons. `rate_limits` baru muncul setelah respons API pertama dan setiap jendela dapat tidak tersedia secara terpisah. Hanya jendela nyata yang ditampilkan; `Warming up` atau data yang hilang tidak pernah diubah menjadi 100% palsu.

Token OAuth, macOS Keychain, dan `~/.claude/.credentials.json` tidak dibaca.

## Satu item menu bar

Claude berwarna oranye, Codex biru, tanpa nama layanan di menu bar macOS. Setiap jendela diberi warna secara independen.

| Tahap | Penggunaan | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 | 90–100% | `#ff7045` | `#ed5d40` |

Codex otomatis menambahkan `5h` saat mengembalikan jendela nyata 300 menit; bila hanya jendela mingguan, hanya `7d` yang tampil. **Settings** memungkinkan menyembunyikan layanan dan memilih 1, 3, atau 5 menit.

Jika Claude belum muncul, buka Claude Code dan selesaikan satu respons. `statusLine` memerlukan workspace trust dan tidak berjalan saat `disableAllHooks: true`.

## Hapus instalasi

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
