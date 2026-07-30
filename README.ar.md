🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 العربية · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ التثبيت — الصق هذا السطر الواحد في Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

يعمل الأمر نفسه مع Homebrew أو بدونه ويثبت المتطلبات تلقائيًا.

## ✅ v0.2.7: استعادة مستقرة لشريط القوائم

يضم الإصدار v0.2.7 نسخة مجرّبة من مساعد Codex داخل هذا المستودع، ويزيل صيغة `;;&` غير المتوافقة مع Bash 3.2 المدمج في macOS، ويعيد إنشاء رأس الألوان المتجه بعد كل تحديث.

يُقيَّم Claude وCodex بصورة مستقلة، لذلك لا يؤدي غياب بيانات إحدى الخدمتين إلى إخفاء الأخرى. ولكل نافذة 5h/7d مستوى لون مستقل، مع الاحتفاظ بإعدادات **Settings** الحالية.

## مصدر بيانات Claude


تُلتقط بيانات Claude من JSON الموثق لـ`statusLine` عبر `rate_limits.five_hour` و`rate_limits.seven_day`. يحافظ المثبت على أي سطر حالة موجود مسبقًا.

بعد التثبيت افتح Claude Code وأكمل ردًا واحدًا. لا يظهر `rate_limits` إلا بعد أول استجابة API، وقد تغيب نافذة 5h أو 7d بشكل مستقل. يعرض البرنامج النوافذ الحقيقية فقط، ولا يحول `Warming up` أو البيانات المفقودة إلى 100% وهمية.

لا تتم قراءة رمز OAuth أو Keychain في macOS أو `~/.claude/.credentials.json`.

## عنصر واحد في شريط القوائم

يظهر Claude بالبرتقالي وCodex بالأزرق من دون الأسماء في شريط macOS، ويُلوّن كل حد بشكل مستقل.

| المستوى | الاستخدام | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 | 90–100% | `#ff7045` | `#ed5d40` |

يضيف Codex شريط `5h` تلقائيًا عندما يعيد نافذة حقيقية مدتها 300 دقيقة، ويعرض `7d` فقط عندما تكون النافذة الأسبوعية وحدها متاحة. يمكن إخفاء كل خدمة وتغيير فترة التحديث من **Settings**.

إذا لم تظهر أشرطة Claude، افتح Claude Code وأكمل ردًا. يحتاج `statusLine` إلى ثقة مساحة العمل ولا يعمل عندما تكون `disableAllHooks` بقيمة `true`.

## إزالة التثبيت

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
