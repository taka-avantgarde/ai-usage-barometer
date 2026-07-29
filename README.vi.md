🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 Tiếng Việt · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Cài đặt — dán một dòng vào Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Cùng một lệnh hoạt động dù đã có Homebrew hay chưa. Khi cần, lệnh sẽ cài Homebrew, jq, SwiftBar và plugin hợp nhất.

Thanh menu macOS chỉ hiển thị một mục, không hiện tên Claude hoặc Codex. Claude có màu cam, Codex màu xanh dương.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## Cài đặt

Trong menu thả xuống, có thể hiện hoặc ẩn Claude và Codex riêng biệt. Ít nhất một dịch vụ luôn được giữ lại.

> **Codex 5h:** Codex không phải lúc nào cũng trả về giới hạn 5 giờ. Nếu tài khoản không có giới hạn đó hoặc dữ liệu không chứa nó, thanh 5h của Codex sẽ bị ẩn và chỉ hiển thị cửa sổ thực có như 7d. Plugin không tự đoán giới hạn bị thiếu.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
