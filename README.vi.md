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

Cả hai bảng màu đều có độ bão hòa và tương phản cao: Claude dùng cam, Codex dùng
lục lam. Khi còn 11–30%, màu cảnh báo pha cam; khi còn 10% trở xuống, màu nguy
cấp pha đỏ tươi. Codex giữ thành phần xanh lam mạnh trong cả hai màu pha:

| Mức | Đã dùng | Claude | Codex |
|---|---:|---|---|
| bình thường | 0–69% đã dùng | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` |
| cảnh báo | 70–89% đã dùng | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` |
| nguy cấp | 90–100% đã dùng | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` |

## Cài đặt

Nhấp vào thanh và chọn **⚙ Cài đặt hiển thị**. Bảng cài đặt vẫn mở để bạn thay đổi nhiều tùy chọn liên tiếp mà không phải mở lại sau mỗi lần nhấp. Thay đổi có hiệu lực ngay.

| Tùy chọn | Tác dụng |
|---|---|
| Hiện Claude | Hiện hoặc ẩn Claude |
| Hiện Claude 5h | Hiện hoặc ẩn khung 5 giờ |
| Phần trăm Claude 5h | Hiện hoặc ẩn phần trăm tương ứng |
| Hiện Claude 7d | Hiện hoặc ẩn khung 7 ngày |
| Phần trăm Claude 7d | Hiện hoặc ẩn phần trăm tương ứng |
| Hiện Codex | Hiện hoặc ẩn Codex |
| Hiện Codex 5h | Hiện hoặc ẩn khung 5 giờ khi có dữ liệu |
| Phần trăm Codex 5h | Hiện hoặc ẩn phần trăm 5 giờ |
| Hiện Codex 7d | Hiện hoặc ẩn khung 7 ngày |
| Phần trăm Codex 7d | Hiện hoặc ẩn phần trăm 7 ngày |
| Khoảng làm mới | 1, 3 hoặc 5 phút |
| Ngôn ngữ | 14 ngôn ngữ; mặc định theo macOS |

Khi ẩn mọi đồng hồ, mục trung tính `AI …` vẫn còn để mở cài đặt. Màu chỉ do các thanh đang hiển thị quyết định. Cài đặt nằm ở `~/.cache/claude-codex-bar/` và được giữ qua các bản cập nhật.

Khi tắt Claude hoặc Codex, việc cập nhật dữ liệu của dịch vụ đó sẽ dừng lại. Các cài đặt 5h, 7d và phần trăm vẫn hiển thị mờ và bị khóa; các giá trị trước đó sẽ được khôi phục khi bật lại dịch vụ.

Nếu bỏ chọn cả khung 5h và 7d của một dịch vụ, dịch vụ cùng các lỗi của nó sẽ bị ẩn hoàn toàn và nguồn dữ liệu sẽ không được truy vấn.

Tiện ích kiểm tra GitHub Releases nhiều nhất một lần mỗi ngày. Khi có bản cập nhật từ nhà vận hành, menu và cài đặt sẽ hiện thông báo, ghi chú và **Cập nhật ngay**.

## Nguồn dữ liệu

**Claude** được đọc từ endpoint OAuth `api.anthropic.com/api/oauth/usage`, dùng token mà Claude Code đã lưu trong Keychain của macOS (`Claude Code-credentials`, hoặc `~/.claude/.credentials.json`). Không ghi vào hai nơi đó, và token chỉ rời máy trong yêu cầu gửi tới Anthropic. Lần đầu chạy hãy chọn **Luôn cho phép**.

Kết quả được lưu đệm trong khoảng làm mới, nên mỗi khoảng chỉ gọi endpoint tối đa một lần. Nếu thất bại, giá trị hợp lệ gần nhất vẫn hiển thị.

**Codex** được đọc từ trợ lý cục bộ `codex-usage.sh` mà trình cài đặt đặt tại `~/SwiftBar/.ai-usage-barometer/`. Các khung của nó là động.

## Khắc phục sự cố

**Hiện cảnh báo Claude.** Không tìm thấy mục Keychain. Hãy đăng nhập Claude Code trên máy này rồi nhấn **Làm mới ngay**.

**Hiện cảnh báo Codex.** Thiếu trợ lý hoặc Codex chưa tạo dữ liệu. Chạy lại trình cài đặt rồi dùng Codex CLI một lần.

**Màu khác nhau giữa thanh menu và menu thả xuống.** macOS có thể coi thanh menu trong suốt là sáng dù menu tối. Khi có Python, trình vẽ vector hai màu luôn được dùng; văn bản một màu chỉ là phương án dự phòng khi thiếu Python.

## Gỡ cài đặt

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Giấy phép

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
