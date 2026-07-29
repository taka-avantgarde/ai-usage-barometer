🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 Tiếng Việt · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Cài đặt — dán một dòng vào Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Cùng một lệnh hoạt động dù đã có Homebrew hay chưa. Khi cần, lệnh sẽ cài Homebrew, jq, SwiftBar và plugin hợp nhất.

Thanh menu macOS chỉ hiển thị một mục, không hiện tên Claude hoặc Codex. Claude có màu cam đậm, Codex màu xanh dương.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 🎨 Ba mức màu độc lập

Các cửa sổ `5h` và `7d` được đánh giá riêng. Mức 1: đã dùng 0–69%; mức 2: 70–89%; mức 3: 90–100%.

| Mức | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

Phần tiêu đề trên thanh menu được dựng thành một PDF vector nhỏ chỉ bằng các công cụ tích hợp của macOS thay vì văn bản ANSI 24-bit. Nhờ đó SwiftBar giữ đúng màu HEX của từng cửa sổ mà không cần Xcode Command Line Tools.

## Cài đặt

Trong menu thả xuống, có thể hiện hoặc ẩn Claude và Codex riêng biệt. Ít nhất một dịch vụ luôn được giữ lại.

> **Codex 5h:** Codex không phải lúc nào cũng trả về giới hạn 5 giờ. Nếu tài khoản không có giới hạn đó hoặc dữ liệu không chứa nó, thanh 5h của Codex sẽ bị ẩn và chỉ hiển thị cửa sổ thực có như 7d. Plugin không tự đoán giới hạn bị thiếu.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
