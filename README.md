# Al-Dhiyaa Gallery

نظام إدارة مبيعات ومخزون عربي لمعرض **الضياء**.

## ما تم تجهيزه

- Flutter متعدد المنصات: Android / Web / Windows.
- واجهة عربية RTL وMobile-first.
- Dashboard، مبيعات، منتجات، عملاء، مصروفات، تقارير وإعدادات.
- بيع نقدي أو آجل، والآجل يحسب +30% من السعر الأساسي.
- منتجات بمقاس/نوع وباركود ومخزون وحد أدنى.
- Barcode Scanner بالكاميرا على Android/Web. على Windows يوجد إدخال باركود يدوي لأن `mobile_scanner` لا يدعم Windows.
- حفظ محلي فوري حتى يعمل التطبيق بدون Backend أثناء التطوير أو عند انقطاع الإنترنت.
- طبقة اختيارية لـ Supabase جاهزة باستخدام `--dart-define` بدون وضع مفاتيح سرية داخل GitHub.
- قاعدة PostgreSQL/Supabase في `supabase/schema.sql`.
- PDF/printing/sharing dependencies جاهزة لإخراج الفواتير الإلكترونية ومشاركتها.
- GitHub Actions يبني Release APK للتثبيت على الهاتف وApp Bundle للنشر على Google Play.

## تشغيل سريع على الكمبيوتر

إذا لم تكن مجلدات Android/Web/Windows موجودة في نسخة clone، شغّل:

### Windows PowerShell
```powershell
./tool/bootstrap.ps1
```

### macOS/Linux
```bash
chmod +x tool/bootstrap.sh
./tool/bootstrap.sh
```

ثم:

```bash
flutter run
```

Web:
```bash
flutter run -d chrome
```

Windows:
```bash
flutter run -d windows
```

## تثبيت التطبيق على الهاتف مثل أي تطبيق Android

لبناء APK قابل للتثبيت مباشرة:

```bash
flutter build apk --release
```

الملف الناتج:

```text
build/app/outputs/flutter-apk/app-release.apk
```

انقل ملف APK إلى الهاتف وافتحه للتثبيت. هذه طريقة توزيع مباشرة خارج Google Play.

## Google Play

النشر الرسمي يستخدم Android App Bundle:

```bash
flutter build appbundle --release
```

الناتج:

```text
build/app/outputs/bundle/release/app-release.aab
```

الـ workflow الموجود في `.github/workflows/android-release.yml` يبني APK وAAB تلقائيًا ويرفعهما كـ GitHub Actions Artifacts.

**مهم:** قبل نشر AAB في Production يجب إعداد Play App Signing وupload keystore. لا يتم تخزين keystore أو كلمات المرور داخل المستودع.

## Supabase

التطبيق يعمل محليًا بدون Supabase. لتفعيل الوضع السحابي:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

ولـ release:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

لا تضع `service_role` key داخل تطبيق الهاتف. استخدم publishable/anon key مع RLS وسياسات قاعدة البيانات.

## قاعدة البيانات

`supabase/schema.sql` يحتوي الجداول الأساسية لـ:

- المنتجات والمقاسات والباركود.
- المخزون وحركة المخزون.
- المبيعات وبنود الفواتير.
- العملاء والمديونيات والمدفوعات.
- المشتريات والموردين والمدفوعات.
- المرتجعات.
- المصروفات.
- الإعدادات وسجل التدقيق.

## ملاحظات Production

النسخة الحالية هي قاعدة تشغيل قوية + Release pipeline. تشغيل المحل بشكل سحابي فعلي يحتاج إنشاء مشروع Supabase مستقل للمحل، تطبيق migration، ثم ضبط Authentication/RLS وربط repositories بالـAPI. لا تستخدم مشروعًا آخر أو مفاتيحه بالخطأ.
