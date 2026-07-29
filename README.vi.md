🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 Tiếng Việt · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Cài đặt — dán đúng một dòng này vào Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Cùng một lệnh hoạt động trên Mac dù đã có Homebrew hay chưa. Khi cần, lệnh sẽ cài Homebrew, `jq`, SwiftBar, plugin hợp nhất và các trình trợ giúp Claude/Codex.

Một mục SwiftBar hiển thị cả hai dịch vụ. **Thanh menu macOS không hiển thị tên Claude hoặc Codex.** Claude dùng tông cam, Codex dùng tông xanh dương.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0: đã sửa cả hai lỗi khôi phục

- **Claude sau khi đặt lại:** nếu Claude trả về `Warming up`, giá trị 0, cửa sổ null hoặc ảnh chụp cũ có thời điểm đặt lại đã qua, plugin không còn bị kẹt ở trạng thái lỗi. Thanh 5h và 7d được khôi phục thành đã đặt lại/đang chờ với 100% còn lại, rồi tự động thay bằng dữ liệu trực tiếp ở lần làm mới thành công tiếp theo. Không cần cài lại.
- **Codex 5h xuất hiện trở lại sau đó:** các cửa sổ Codex được phát hiện động. Nếu Codex lại trả về cửa sổ 300 phút, thanh `5h` sẽ tự động được thêm ở lần làm mới tiếp theo. Nếu không có, chỉ cửa sổ thực tế như `7d` được hiển thị.

Chọn **Refresh now** để yêu cầu cập nhật ngay.

## 🎨 Ba mức màu độc lập

Mỗi cửa sổ 5h hoặc 7d được đánh giá riêng.

| Mức | Đã dùng | Claude | Codex |
|---|---:|---|---|
| 1 — bình thường | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 — cảnh báo | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 — nguy cấp | 90–100% | `#ff7045` | `#ed5d40` |

Phần đầu được tạo thành PDF vector nhỏ bằng các công cụ tích hợp của macOS, không cần Xcode Command Line Tools.

## Cài đặt và chi tiết

Menu hiển thị tên dịch vụ, mức sử dụng, dung lượng còn lại và thời điểm đặt lại. Trong **Settings**, có thể hiện hoặc ẩn Claude và Codex riêng biệt; luôn giữ ít nhất một dịch vụ. Chu kỳ làm mới là 1, 3 hoặc 5 phút.

> **Codex 5h:** plugin không tự đoán giới hạn bị thiếu. Nó ẩn 5h cho đến khi Codex trả về cửa sổ 300 phút thật, rồi tự động thêm vào.

Các plugin độc lập hiện có được chuyển vào thư mục hỗ trợ ẩn để tránh mục trùng lặp mà vẫn giữ nguyên tệp.

## Yêu cầu và quyền riêng tư

- macOS; trình cài đặt xử lý Homebrew, `jq` và SwiftBar.
- Claude Code đã đăng nhập.
- Codex CLI hoặc ứng dụng Codex đã được dùng trên Mac.
- Token xác thực không bao giờ được in hoặc sao chép vào bộ nhớ đệm.
- Một số giao diện dữ liệu sử dụng không chính thức và có thể cần cập nhật tương thích sau này.

## Gỡ cài đặt

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Giấy phép

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
