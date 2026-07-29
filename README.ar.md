🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 العربية · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ التثبيت — الصق سطرًا واحدًا في Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

يعمل الأمر نفسه سواء كان Homebrew مثبتًا أم لا. يثبت Homebrew عند الحاجة ثم jq وSwiftBar والإضافة الموحدة.

يظهر عنصر واحد فقط في شريط macOS من دون اسمي Claude أو Codex. يظهر Claude بالبرتقالي الداكن وCodex بالأزرق.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 🎨 ثلاثة مستويات ألوان مستقلة

يتم تقييم نافذتي `5h` و`7d` بشكل مستقل. المستوى 1: استخدام 0–69%، المستوى 2: 70–89%، المستوى 3: 90–100%.

| المستوى | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

## الإعدادات

يمكن إظهار Claude أو Codex أو إخفاؤهما بشكل مستقل من القائمة. يجب إبقاء خدمة واحدة على الأقل ظاهرة.

> **Codex 5h:** لا يعيد Codex دائمًا حد الخمس ساعات. إذا لم يكن موجودًا أو لم يظهر في بيانات الاستخدام، تُخفى خانة 5h الخاصة بـ Codex وتظهر النوافذ المتاحة فقط مثل 7d. لا تخمّن الإضافة حدًا مفقودًا.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
