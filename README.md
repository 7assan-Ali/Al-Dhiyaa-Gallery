# Al-Dhiyaa Gallery

نظام إدارة مبيعات ومخزون عربي لمعرض **الضياء**.

## الحالة الحالية
- Flutter متعدد المنصات: Android / Web / Windows.
- واجهة RTL عربية وMobile-first.
- Dashboard، مبيعات، منتجات، عملاء، مصروفات، تقارير، إعدادات.
- بيع نقدي أو آجل، والآجل يحسب +30% تلقائيًا.
- منتجات بمقاس/نوع وباركود ومخزون وحد أدنى.
- قارئ باركود بالكاميرا على Android/Web؛ وعلى Windows يوجد إدخال باركود يدوي لأن إضافة الكاميرا المستخدمة لا تدعم Windows.
- حفظ محلي فوري عبر SharedPreferences حتى يمكن تشغيل النسخة مباشرة بدون إعدادات سحابية.
- مخطط قاعدة البيانات الكامل موجود في `supabase/schema.sql` تمهيدًا لربط Supabase.

## التشغيل
```bash
flutter pub get
flutter run
```

للتشغيل على الويب:
```bash
flutter run -d chrome
```

لـ Windows:
```bash
flutter run -d windows
```

## ملاحظات مهمة
النسخة الأولى مصممة لتكون قابلة للتشغيل فورًا. التخزين المحلي يعمل بدون أي API keys. مرحلة الربط السحابي يمكن تنفيذها فوق نفس الـmodels والواجهات باستخدام ملف `supabase/schema.sql`.

## بنية المشروع
```text
lib/main.dart              # التطبيق والواجهات والمنطق الأساسي
supabase/schema.sql        # PostgreSQL schema + constraints + RLS starter
README.md
```
