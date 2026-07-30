🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 ไทย

# 🎚️ AI Usage Barometer

## ⚡ ติดตั้ง — วางบรรทัดเดียวนี้ใน Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

คำสั่งเดียวกันใช้ได้ทั้งเครื่องที่มีและไม่มี Homebrew และติดตั้งส่วนประกอบที่จำเป็นให้อัตโนมัติ

## ✅ v0.2.7: กู้คืนแถบเมนูให้เสถียร

v0.2.7 รวม helper ของ Codex ที่ผ่านการทดสอบไว้ใน repository นี้โดยตรง ลบไวยากรณ์ `;;&` ที่ใช้ไม่ได้กับ Bash 3.2 มาตรฐานของ macOS และสร้างส่วนหัวแบบเวกเตอร์ที่ใช้สีตรงตามกำหนดใหม่หลังการอัปเดตทุกครั้ง

Claude และ Codex จะถูกประเมินแยกจากกัน ข้อมูลที่หายไปของบริการหนึ่งจะไม่ทำให้อีกบริการหายไป แต่ละหน้าต่าง 5h/7d มีระดับสีของตัวเอง และยังคงตัวเลือก **Settings** เดิมไว้

## แหล่งข้อมูล Claude


ข้อมูลการใช้ Claude มาจาก JSON `statusLine` ที่มีเอกสารกำกับ ผ่าน `rate_limits.five_hour` และ `rate_limits.seven_day` โดยยังคงผลลัพธ์ status line เดิมของผู้ใช้ไว้

หลังติดตั้ง ให้เปิด Claude Code และรอให้ตอบกลับหนึ่งครั้ง `rate_limits` จะปรากฏหลัง API response แรก และหน้าต่าง 5h หรือ 7d อาจไม่มีแยกจากกัน จะแสดงเฉพาะขีดจำกัดจริงเท่านั้น และจะไม่เปลี่ยน `Warming up` หรือข้อมูลที่หายไปเป็น 100% ปลอม

ไม่อ่าน OAuth token, macOS Keychain หรือ `~/.claude/.credentials.json`

## หนึ่งรายการบนแถบเมนู

Claude ใช้สีส้ม Codex ใช้สีน้ำเงิน และไม่แสดงชื่อบริการบนแถบเมนู macOS แต่ละหน้าต่างเปลี่ยนสีอย่างอิสระ

| ระดับ | การใช้ | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 | 90–100% | `#ff7045` | `#ed5d40` |

Codex จะเพิ่ม `5h` อัตโนมัติเมื่อได้รับหน้าต่างจริง 300 นาที ถ้ามีเฉพาะรายสัปดาห์จะแสดงเพียง `7d` ใน **Settings** สามารถซ่อนบริการและเลือก 1, 3 หรือ 5 นาทีได้

หากแถบ Claude ยังไม่ปรากฏ ให้เปิด Claude Code และรับคำตอบหนึ่งครั้ง `statusLine` ต้องได้รับ workspace trust และจะไม่ทำงานเมื่อ `disableAllHooks: true`

## ถอนการติดตั้ง

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
