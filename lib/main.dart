import 'package:flutter/material.dart';

void main() {
  runApp(const AlDhiyaaApp());
}

class AlDhiyaaApp extends StatelessWidget {
  const AlDhiyaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الضياء',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorSchemeSeed: const Color(0xFF0B6E69),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  final pages = const [
    DashboardPage(),
    PosPage(),
    InventoryPage(),
    CustomersPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الضياء', style: TextStyle(fontWeight: FontWeight.w800)),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: CircleAvatar(child: Icon(Icons.person))),
          ],
        ),
        drawer: wide ? null : Drawer(child: _menu()),
        body: Row(
          children: [
            if (wide) SizedBox(width: 250, child: _menu()),
            Expanded(child: pages[index]),
          ],
        ),
        bottomNavigationBar: wide ? null : NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (v) => setState(() => index = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'بيع'),
            NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'المخزون'),
            NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'العملاء'),
            NavigationDestination(icon: Icon(Icons.menu), label: 'المزيد'),
          ],
        ),
      ),
    );
  }

  Widget _menu() => ListView(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
    children: [
      const Padding(padding: EdgeInsets.all(16), child: Text('الضياء', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900))),
      _nav(Icons.home_outlined, 'الرئيسية', 0),
      _nav(Icons.point_of_sale_outlined, 'المبيعات', 1),
      _nav(Icons.inventory_2_outlined, 'المخزون', 2),
      _nav(Icons.people_outline, 'العملاء', 3),
      _nav(Icons.shopping_cart_outlined, 'المشتريات', 4),
      _nav(Icons.factory_outlined, 'الموردين', 4),
      _nav(Icons.receipt_long_outlined, 'المصروفات', 4),
      _nav(Icons.bar_chart_outlined, 'التقارير', 4),
      _nav(Icons.settings_outlined, 'الإعدادات', 4),
    ],
  );

  Widget _nav(IconData icon, String label, int value) => ListTile(
    selected: index == value,
    leading: Icon(icon),
    title: Text(label),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    onTap: () => setState(() => index = value),
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('صباح الخير 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Text('ملخص محل الضياء اليوم', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 20),
      Wrap(spacing: 14, runSpacing: 14, children: const [
        StatCard(title: 'مبيعات اليوم', value: '15,850 ج', icon: Icons.payments_outlined),
        StatCard(title: 'صافي الربح', value: '4,250 ج', icon: Icons.trending_up),
        StatCard(title: 'الفواتير', value: '48', icon: Icons.receipt_long_outlined),
        StatCard(title: 'قيمة المخزون', value: '285,000 ج', icon: Icons.inventory_2_outlined),
      ]),
      const SizedBox(height: 20),
      Wrap(spacing: 14, runSpacing: 14, children: const [
        InfoCard(title: 'مديونية العملاء', value: '32,400 ج', icon: Icons.people_outline),
        InfoCard(title: 'مستحقات الموردين', value: '18,700 ج', icon: Icons.factory_outlined),
        InfoCard(title: 'مخزون منخفض', value: '12 منتج', icon: Icons.warning_amber_rounded),
      ]),
      const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('أكثر المنتجات مبيعًا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        SizedBox(height: 16),
        ProductRow(name: 'طبق بلاستيك كبير', qty: '250 قطعة'),
        ProductRow(name: 'كوب زجاج', qty: '190 قطعة'),
        ProductRow(name: 'معلقة', qty: '160 قطعة'),
      ]))),
    ]),
  );
}

class PosPage extends StatelessWidget {
  const PosPage({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      Row(children: [
        Expanded(child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'ابحث باسم المنتج أو الباركود', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
        const SizedBox(width: 10),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.qr_code_scanner), label: const Text('مسح باركود')),
      ]),
      const SizedBox(height: 16),
      Expanded(child: Card(child: Column(children: [
        const ListTile(title: Text('فاتورة جديدة', style: TextStyle(fontWeight: FontWeight.w800)), trailing: Text('عميل نقدي')),
        const Divider(height: 1),
        const Expanded(child: Center(child: Text('امسح الباركود أو ابحث عن منتج لإضافته للفاتورة'))),
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          const Expanded(child: Text('الإجمالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
          const Text('0 ج', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(width: 12),
          FilledButton(onPressed: () {}, child: const Text('حفظ الفاتورة')),
        ])),
      ]))),
    ]),
  );
}

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});
  @override
  Widget build(BuildContext context) => _ListPage(title: 'المخزون', action: 'إضافة منتج', children: const [
    ProductRow(name: 'طبق بلاستيك كبير', qty: '73 قطعة • جيد'),
    ProductRow(name: 'كوب زجاج متوسط', qty: '120 قطعة • جيد'),
    ProductRow(name: 'علبة تخزين', qty: '7 قطعة • منخفض'),
  ]);
}

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});
  @override
  Widget build(BuildContext context) => _ListPage(title: 'العملاء', action: 'إضافة عميل', children: const [
    ProductRow(name: 'أحمد محمد', qty: 'مديونية: 4,500 ج'),
    ProductRow(name: 'محمد علي', qty: 'مديونية: 0 ج'),
  ]);
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    _MoreTile(icon: Icons.shopping_cart_outlined, title: 'المشتريات'),
    _MoreTile(icon: Icons.factory_outlined, title: 'الموردين'),
    _MoreTile(icon: Icons.receipt_long_outlined, title: 'المصروفات'),
    _MoreTile(icon: Icons.bar_chart_outlined, title: 'التقارير'),
    _MoreTile(icon: Icons.settings_outlined, title: 'الإعدادات'),
  ]);
}

class _ListPage extends StatelessWidget {
  final String title;
  final String action;
  final List<Widget> children;
  const _ListPage({required this.title, required this.action, required this.children});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900))), FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: Text(action))]),
    const SizedBox(height: 16),
    TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'بحث...', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
    const SizedBox(height: 12),
    ...children.map((e) => Card(child: e)),
  ]);
}

class StatCard extends StatelessWidget {
  final String title, value; final IconData icon;
  const StatCard({super.key, required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => SizedBox(width: 230, child: Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 28), const SizedBox(height: 14), Text(title, style: TextStyle(color: Colors.grey.shade600)), const SizedBox(height: 5), Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900))]))));
}

class InfoCard extends StatelessWidget {
  final String title, value; final IconData icon;
  const InfoCard({super.key, required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => SizedBox(width: 260, child: Card(child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w800)))));
}

class ProductRow extends StatelessWidget {
  final String name, qty;
  const ProductRow({super.key, required this.name, required this.qty});
  @override
  Widget build(BuildContext context) => ListTile(title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(qty), trailing: const Icon(Icons.chevron_left));
}

class _MoreTile extends StatelessWidget {
  final IconData icon; final String title;
  const _MoreTile({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_left)));
}
