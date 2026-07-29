🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 العربية · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ التثبيت — الصق هذا السطر الواحد في Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

يعمل الأمر نفسه على أجهزة Mac سواء كان Homebrew مثبتًا أم لا. وعند الحاجة يثبّت Homebrew و`jq` وSwiftBar والإضافة الموحدة ومساعدي Claude/Codex.

يعرض عنصر SwiftBar واحد الخدمتين معًا. **لا يعرض شريط قوائم macOS اسمي Claude أو Codex.** يستخدم Claude درجات البرتقالي ويستخدم Codex درجات الأزرق.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0: تم إصلاح مشكلتي الاستعادة

- **Claude بعد إعادة الضبط:** إذا أعاد Claude العبارة `Warming up` أو قيمًا صفرية أو نوافذ null أو لقطة قديمة تجاوز وقت إعادة ضبطها، فلن تبقى الإضافة عالقة في حالة خطأ. تستعيد شريطي 5h و7d كحالة معاد ضبطها/في الانتظار مع 100% متبقية، ثم تستبدلهما بالقيم الحية عند أول تحديث ناجح. لا حاجة إلى إعادة التثبيت.
- **عودة نافذة Codex 5h لاحقًا:** تُكتشف نوافذ Codex ديناميكيًا. إذا أعاد Codex نافذة 300 دقيقة، يظهر شريط `5h` تلقائيًا عند التحديث التالي. وإذا لم تظهر، تُعرض النافذة المتاحة فقط مثل `7d`.

اختر **Refresh now** لطلب تحديث فوري.

## 🎨 ثلاثة مستويات ألوان مستقلة

تُقيّم كل نافذة 5h أو 7d بصورة مستقلة.

| المستوى | الاستخدام | Claude | Codex |
|---|---:|---|---|
| 1 — عادي | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 — تحذير | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 — حرج | 90–100% | `#ff7045` | `#ed5d40` |

يُنشأ العنوان كملف PDF متجهي صغير بأدوات macOS المدمجة، من دون Xcode Command Line Tools.

## الإعدادات والتفاصيل

تعرض القائمة أسماء الخدمات والاستخدام والسعة المتبقية ووقت إعادة الضبط. في **Settings** يمكن إظهار Claude وCodex أو إخفاؤهما كلٌ على حدة، مع بقاء خدمة واحدة على الأقل. يمكن اختيار تحديث كل 1 أو 3 أو 5 دقائق.

> **Codex 5h:** لا تخمّن الإضافة حدًا مفقودًا. تخفي 5h حتى يعيد Codex نافذة حقيقية مدتها 300 دقيقة، ثم تضيفها تلقائيًا.

تُنقل الإضافات المستقلة الموجودة إلى مجلد دعم مخفي لمنع التكرار مع الحفاظ على الملفات.

## المتطلبات والخصوصية

- macOS؛ يتولى المثبّت Homebrew و`jq` وSwiftBar.
- تسجيل الدخول إلى Claude Code.
- استخدام Codex CLI أو تطبيق Codex على جهاز Mac.
- لا تُطبع رموز المصادقة ولا تُنسخ إلى ذاكرة التخزين المؤقت.
- بعض واجهات بيانات الاستخدام غير رسمية وقد تحتاج إلى تحديثات توافق مستقبلية.

## إلغاء التثبيت

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## الترخيص

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
