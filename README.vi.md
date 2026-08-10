🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 Tiếng Việt · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Cài đặt — dán một dòng này vào Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Cùng một lệnh hoạt động dù có hay không có Homebrew. Chỉ cài những gì còn thiếu: Homebrew, `jq`, SwiftBar, plugin và các trợ lý cục bộ. Chạy lại an toàn, dùng chính dòng này để cập nhật.

## Chỉ một mục trên thanh menu

Claude và Codex dùng chung một mục, ngăn bởi một vạch mảnh. Thanh theo kiểu pin: **phần đầy là dung lượng còn lại**, phần chấm là đã dùng. Phần trăm cũng là lượng còn lại.

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

Thanh menu được vẽ dạng ảnh vector nên mỗi dịch vụ giữ được màu riêng trong cùng một mục. Nếu không thể, hệ thống tự chuyển sang văn bản thuần.

Cả hai bảng màu đều sáng và pha trắng: Claude dùng trắng cam, Codex dùng trắng
xanh da trời. Màu sẽ đậm dần trong cùng tông khi mức sử dụng tăng:

| Mức | Đã dùng | Claude | Codex |
|---|---:|---|---|
| bình thường | 0–69% đã dùng | ![#F2C6A0](assets/colors/claude-healthy.svg) `#F2C6A0` | ![#BEEAF3](assets/colors/codex-healthy.svg) `#BEEAF3` |
| cảnh báo | 70–89% đã dùng | ![#EDA66F](assets/colors/claude-warning.svg) `#EDA66F` | ![#96DCE9](assets/colors/codex-warning.svg) `#96DCE9` |
| nguy cấp | 90–100% đã dùng | ![#E88952](assets/colors/claude-critical.svg) `#E88952` | ![#6BC9DC](assets/colors/codex-critical.svg) `#6BC9DC` |

## Cài đặt

Nhấp vào thanh và dùng **⚙ Cài đặt hiển thị**. Mỗi mục đảo trạng thái khi nhấp và có hiệu lực ngay.

| Tùy chọn | Tác dụng |
|---|---|
| Hiện Claude | Hiện hoặc ẩn Claude |
| Hiện Claude 5h | Hiện hoặc ẩn khung 5 giờ |
| Phần trăm Claude 5h | Hiện hoặc ẩn phần trăm tương ứng |
| Hiện Claude 7d | Hiện hoặc ẩn khung 7 ngày |
| Phần trăm Claude 7d | Hiện hoặc ẩn phần trăm tương ứng |
| Hiện Codex | Hiện hoặc ẩn Codex |
| Phần trăm Codex | Hiện hoặc ẩn phần trăm của Codex |
| Thanh menu hai màu | Vector (hai màu) hoặc văn bản (một màu) |
| Khoảng làm mới | 1, 3 hoặc 5 phút |
| Ngôn ngữ | 14 ngôn ngữ; mặc định theo macOS |

Ẩn hết sẽ để lại một mục trống không nhấp được, nên thanh 5 giờ của Claude luôn được giữ. Màu chỉ do các thanh đang hiển thị quyết định. Cài đặt nằm ở `~/.cache/claude-codex-bar/` và được giữ qua các bản cập nhật.

## Nguồn dữ liệu

**Claude** được đọc từ endpoint OAuth `api.anthropic.com/api/oauth/usage`, dùng token mà Claude Code đã lưu trong Keychain của macOS (`Claude Code-credentials`, hoặc `~/.claude/.credentials.json`). Không ghi vào hai nơi đó, và token chỉ rời máy trong yêu cầu gửi tới Anthropic. Lần đầu chạy hãy chọn **Luôn cho phép**.

Kết quả được lưu đệm trong khoảng làm mới, nên mỗi khoảng chỉ gọi endpoint tối đa một lần. Nếu thất bại, giá trị hợp lệ gần nhất vẫn hiển thị.

**Codex** được đọc từ trợ lý cục bộ `codex-usage.sh` mà trình cài đặt đặt tại `~/SwiftBar/.ai-usage-barometer/`. Các khung của nó là động.

## Khắc phục sự cố

**Hiện cảnh báo Claude.** Không tìm thấy mục Keychain. Hãy đăng nhập Claude Code trên máy này rồi nhấn **Làm mới ngay**.

**Hiện cảnh báo Codex.** Thiếu trợ lý hoặc Codex chưa tạo dữ liệu. Chạy lại trình cài đặt rồi dùng Codex CLI một lần.

**Màu khác nhau giữa thanh menu và menu thả xuống.** macOS có thể coi thanh menu trong suốt là sáng dù menu tối. Vì vậy mỗi mức chỉ dùng một màu; nếu vẫn lệch, hãy tắt vẽ hai màu.

## Gỡ cài đặt

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Giấy phép

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
