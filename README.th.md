🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 ไทย

# 🎚️ AI Usage Barometer

## ⚡ ติดตั้ง — วางเพียงหนึ่งบรรทัดใน Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

คำสั่งเดียวกันใช้ได้ทั้งเครื่องที่มีและไม่มี Homebrew โดยจะติดตั้ง Homebrew เมื่อจำเป็น พร้อม jq, SwiftBar และปลั๊กอินรวม

แถบเมนู macOS แสดงเพียงรายการเดียวโดยไม่แสดงชื่อ Claude หรือ Codex ส่วน Claude เป็นสีส้มเข้มและ Codex เป็นสีน้ำเงิน

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 🎨 สี 3 ระดับแบบแยกอิสระ

หน้าต่าง `5h` และ `7d` จะถูกประเมินแยกกัน ระดับ 1: ใช้ 0–69%; ระดับ 2: 70–89%; ระดับ 3: 90–100%.

| ระดับ | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

## การตั้งค่า

ในเมนูสามารถเลือกแสดงหรือซ่อน Claude และ Codex แยกกันได้ โดยต้องคงไว้อย่างน้อยหนึ่งบริการ

> **Codex 5h:** Codex ไม่ได้ส่งขีดจำกัด 5 ชั่วโมงเสมอไป หากบัญชีไม่มีขีดจำกัดนี้หรือข้อมูลการใช้งานไม่ได้ส่งมา แถบ 5h ของ Codex จะถูกซ่อนและแสดงเฉพาะช่วงที่มีจริง เช่น 7d ปลั๊กอินจะไม่คาดเดาขีดจำกัดที่ไม่มีอยู่

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
