🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 Bahasa Indonesia · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalasi — tempel satu baris di Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Perintah yang sama berfungsi dengan atau tanpa Homebrew. Bila diperlukan, perintah memasang Homebrew, jq, SwiftBar, dan plugin terpadu.

Bilah menu macOS hanya menampilkan satu item tanpa nama Claude atau Codex. Claude berwarna oranye gelap dan Codex biru.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 🎨 Tiga tingkat warna independen

Jendela `5h` dan `7d` dinilai secara terpisah. Tingkat 1: 0–69% digunakan; tingkat 2: 70–89%; tingkat 3: 90–100%.

| Tingkat | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

## Pengaturan

Dari menu, Claude dan Codex dapat ditampilkan atau disembunyikan secara terpisah. Setidaknya satu layanan tetap terlihat.

> **Codex 5h:** Codex tidak selalu mengembalikan batas 5 jam. Jika batas itu tidak ada atau tidak dikirim dalam data, bilah 5h Codex disembunyikan dan hanya jendela yang tersedia seperti 7d yang ditampilkan. Plugin tidak menebak batas yang hilang.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
