# تطبيق بنفسج ستور — دليل الإطلاق الكامل

تطبيق Flutter متصل مباشرة بقاعدة بياناتك الحالية ولوحة التحكم، عن طريق REST API جديد تم بناؤه في مجلد `api/v1` على نفس السيرفر.

---

## الخطوة 1: رفع API على السيرفر

1. من ملفات الموقع (zip الموقع)، انسخ مجلد `api/v1` كامل إلى `public_html/api/v1/` على السيرفر (بجانب مجلد `api` الحالي).
2. **مهم جداً للأمان:** افتح `api/v1/auth.php` وغيّر القيمة:
   ```php
   define('API_SECRET', 'CHANGE_THIS_TO_A_LONG_RANDOM_STRING_BEFORE_LAUNCH_2026');
   ```
   استبدلها بنص طويل وعشوائي (32+ حرف) لا يعرفه غيرك. هذا المفتاح يحمي تسجيل دخول العملاء.
3. شغّل ملف `migration_add_icon_column.sql` (لو ما شغّلته قبل) من phpMyAdmin — هذا ينشئ جدول `customer_carts` الجديد اللي يحتاجه التطبيق لسلة تسوق دائمة عبر كل الأجهزة.
4. جرب من المتصفح: `https://sir-alanakah.online/api/v1/config.php` — إذا ظهر JSON فيه اسم المتجر، يعني API شغّال.

---

## الخطوة 2: تجربة الكود محلياً (اختياري، لو معك جهاز)

```bash
flutter pub get
flutter run
```

لو ما معك بيئة Flutter محلية، مافي مشكلة — انتقل مباشرة لـ Codemagic، هو يبني كل شي بدون أي تنصيب على جهازك.

---

## الخطوة 3: رفع الكود لـ GitHub

Codemagic يحتاج الكود يكون في مستودع Git (GitHub / GitLab / Bitbucket).

```bash
cd banafsaj_app
git init
git add .
git commit -m "بنفسج ستور - أول نسخة من التطبيق"
```

أنشئ مستودع جديد فاضي على GitHub (بدون README)، وبعدين:
```bash
git remote add origin https://github.com/USERNAME/banafsaj-app.git
git branch -M main
git push -u origin main
```

---

## الخطوة 4: ربط Codemagic

1. روح [codemagic.io](https://codemagic.io) وسجّل دخول (يدعم تسجيل دخول مباشر بحساب GitHub).
2. اضغط **Add application** → اختار المستودع اللي رفعته.
3. Codemagic رح يكتشف ملف `codemagic.yaml` تلقائياً (موجود بجذر المشروع) ويعرض 3 خيارات بناء (workflows):
   - **android-debug-apk** → أسرع طريقة تختبر التطبيق على هاتف Android حقيقي، بدون أي إعدادات توقيع.
   - **android-release** → نسخة جاهزة لمتجر Google Play (تحتاج keystore).
   - **ios-release** → نسخة لمتجر App Store (تحتاج حساب Apple Developer).

### للتجربة السريعة (Android Debug):
اضغط **Start new build** → اختار `android-debug-apk` → Start build. بعد ما يخلص (~10 دقائق)، تنزّل ملف APK من تبويب **Artifacts** وتثبته على أي جوال أندرويد مباشرة (فعّل "تثبيت من مصادر غير معروفة" بإعدادات الجوال).

---

## الخطوة 5: نشر فعلي على Google Play

1. أنشئ حساب مطور Google Play (رسم 25$ مرة واحدة): https://play.google.com/console
2. أنشئ keystore للتوقيع:
   ```bash
   keytool -genkey -v -keystore banafsaj.jks -keyalg RSA -keysize 2048 -validity 10000 -alias banafsaj
   ```
3. في Codemagic، روح **Team settings → Environment variables** وأنشئ مجموعة اسمها `google_play` فيها:
   - `CM_KEYSTORE` — حوّل ملف `banafsaj.jks` إلى base64 (`base64 -i banafsaj.jks`) وحط القيمة هنا.
   - `CM_KEYSTORE_PASSWORD`, `CM_KEY_ALIAS`, `CM_KEY_PASSWORD` — حسب ما حددت عند إنشاء الـ keystore.
4. شغّل workflow `android-release` — رح يطلع لك ملف `.aab` جاهز ترفعه يدوياً لـ Google Play Console، أو تفعّل النشر الآلي بإزالة التعليق عن قسم `google_play` بآخر `codemagic.yaml` بعد ربط Service Account.

---

## الخطوة 6: نشر فعلي على App Store (iOS)

1. تحتاج حساب Apple Developer (99$/سنة): https://developer.apple.com
2. في Codemagic: **Team settings → Integrations → Apple Developer Portal** — اربط حسابك.
3. اسم التكامل اللي تربطه لازم يطابق `codemagic_appstore_integration` المكتوب في `codemagic.yaml`، أو غيّر الاسم بالملف ليطابق اللي سجلته.
4. شغّل workflow `ios-release` — أول مرة ممكن يطلب منك تأكيد على شاشة Apple، وبعدها يرفع تلقائياً لـ TestFlight.

---

## شكل التطبيق وما يقدر يسويه

- تصفح المنتجات والأقسام بنفس تصميم الموقع (Navy + Gold)
- سلة تسوق محفوظة في قاعدة البيانات (تشتغل بنفس حساب العميل عبر أي جهاز)
- تسجيل دخول / حساب جديد
- المفضلة، التقييمات، إتمام الطلب، تتبع الطلبات
- عناوين شحن متعددة محفوظة
- كوبونات الخصم

---

## ملاحظات مهمة

- التطبيق يتصل بـ `https://sir-alanakah.online/api/v1` — لو غيّرت الدومين بالمستقبل، عدّل `baseUrl` في `lib/services/api_service.dart`.
- لوحة التحكم (`/admin`) ما زالت تعمل كما هي على الموقع، بدون أي تغيير — التطبيق يستخدم نفس قاعدة البيانات بالضبط، يعني أي منتج تضيفه من لوحة التحكم يظهر فوراً بالتطبيق.
- الدفع حالياً COD (الدفع عند الاستلام) فقط داخل التطبيق، نفس الموقع. لو احتجت بطاقات بنكية لاحقاً، نضيف Moyasar SDK لـ Flutter في مرحلة لاحقة.
