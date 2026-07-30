🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 Tiếng Việt · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Cài đặt — dán một dòng này vào Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Cùng một lệnh hoạt động dù đã có Homebrew hay chưa và tự động cài các thành phần cần thiết.

## ✅ v0.2.7: khôi phục thanh menu ổn định

v0.2.7 đóng gói helper Codex đã được kiểm thử ngay trong kho mã này, loại bỏ cú pháp `;;&` không tương thích với Bash 3.2 mặc định của macOS và tạo lại phần đầu vector có màu chính xác sau mỗi lần cập nhật.

Claude và Codex được đánh giá độc lập: thiếu dữ liệu của một dịch vụ sẽ không còn làm dịch vụ kia biến mất. Mỗi cửa sổ 5h/7d giữ cấp màu riêng và các lựa chọn **Settings** hiện có được bảo toàn.

## Nguồn dữ liệu Claude


Mức sử dụng Claude được lấy từ JSON `statusLine` đã được tài liệu hóa, qua `rate_limits.five_hour` và `rate_limits.seven_day`. Dòng trạng thái hiện có vẫn được giữ nguyên.

Sau khi cài, hãy mở Claude Code và hoàn tất một phản hồi. `rate_limits` chỉ xuất hiện sau phản hồi API đầu tiên và từng cửa sổ có thể vắng mặt độc lập. Chỉ giới hạn thực được hiển thị; `Warming up` hoặc dữ liệu thiếu không bao giờ bị biến thành 100% giả.

Không đọc token OAuth, macOS Keychain hay `~/.claude/.credentials.json`.

## Một mục trên thanh menu

Claude dùng màu cam, Codex dùng màu xanh và không hiện tên trên thanh menu macOS. Mỗi cửa sổ được tô màu độc lập.

| Mức | Sử dụng | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 | 90–100% | `#ff7045` | `#ed5d40` |

Codex tự thêm `5h` khi trả về cửa sổ 300 phút thật; nếu chỉ có cửa sổ tuần thì chỉ hiện `7d`. **Settings** cho phép ẩn dịch vụ và chọn 1, 3 hoặc 5 phút.

Nếu chưa thấy Claude, hãy mở Claude Code và hoàn tất một phản hồi. `statusLine` cần workspace trust và không chạy khi `disableAllHooks: true`.

## Gỡ cài đặt

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
