import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MeterApp());
}

class MeterApp extends StatelessWidget {
  const MeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة العدادات والفواتير',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: const MainDashboardScreen(),
    );
  }
}

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  void _sendWhatsAppNotification(String phone, String text) async {
    final url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(text)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق إدارة العدادات والعقارات'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
            children: [
              _buildCard(context, Icons.speed, 'فاتورة قراءة جديدة', Colors.amber, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MeterReadingScreen()));
              }),
              _buildCard(context, Icons.receipt_long, 'كشف حساب دقيق', Colors.blue, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AccountStatementScreen()));
              }),
              _buildCard(context, Icons.attach_money, 'سند قبض وتأمين', Colors.teal, () {}),
              _buildCard(context, Icons.people, 'إدارة المستأجرين', Colors.purple, () {}),
              _buildCard(context, Icons.apartment, 'إدارة العقارات والوحدات', Colors.indigo, () {}),
              _buildCard(context, Icons.electric_meter, 'إدارة العدادات والخدمات', Colors.cyan, () {}),
              _buildCard(context, Icons.analytics, 'إحصائيات الدخل والخرج', Colors.pink, () {}),
              _buildCard(context, Icons.send, 'إرسال إشعار الواتساب', Colors.greenAccent, () {
                _sendWhatsAppNotification("967700000000", "عزيزي المستأجر، تم إصدار فاتورة الكهرباء والمياه الإيجار المستحقة.");
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class MeterReadingScreen extends StatefulWidget {
  const MeterReadingScreen({super.key});

  @override
  State<MeterReadingScreen> createState() => _MeterReadingScreenState();
}

class _MeterReadingScreenState extends State<MeterReadingScreen> {
  final _formKey = GlobalKey<FormState>();

  String serviceType = 'كهرباء';
  String unitLabel = 'KWh (كيلووات)';
  double prevReading = 1500.0;
  double currReading = 0.0;
  double unitPrice = 0.20;
  double rentPrice = 600.0;
  double consumption = 0.0;
  double utilityTotal = 0.0;
  double grandTotal = 0.0;

  void _recalculate() {
    setState(() {
      if (currReading >= prevReading) {
        consumption = currReading - prevReading;
        utilityTotal = consumption * unitPrice;
        grandTotal = utilityTotal + rentPrice;
      } else {
        consumption = 0.0;
        utilityTotal = 0.0;
        grandTotal = rentPrice;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إصدار فاتورة قراءة جديدة')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: serviceType,
                  decoration: const InputDecoration(labelText: 'اختر نوع الخدمة', border: OutlineInputBorder()),
                  items: ['كهرباء', 'مياه'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    setState(() {
                      serviceType = v!;
                      unitLabel = (v == 'كهرباء') ? 'KWh (كيلووات)' : 'm³ (متر مكعب)';
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text('الوحدة: شقة رقم 102 - عداد (#9082)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('القراءة السابقة: $prevReading $unitLabel', style: const TextStyle(color: Colors.amber)),
                const SizedBox(height: 12),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'القراءة الحالية ($unitLabel)',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    currReading = double.tryParse(val) ?? 0.0;
                    _recalculate();
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  color: const Color(0xFF252525),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      children: [
                        _infoRow('كمية الاستهلاك:', '$consumption $unitLabel'),
                        _infoRow('تكلفة الاستهلاك:', '${utilityTotal.toStringAsFixed(2)} \$'),
                        _infoRow('مبلغ الإيجار الشهري:', '${rentPrice.toStringAsFixed(2)} \$'),
                        const Divider(color: Colors.white24),
                        _infoRow('المبلغ الإجمالي:', '${grandTotal.toStringAsFixed(2)} \$', isBold: true, color: Colors.greenAccent),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String val, {bool isBold = false, Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(color: color, fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class AccountStatementScreen extends StatelessWidget {
  final List<Map<String, dynamic>> records = [
    {"date": "2026-08-01", "desc": "فاتورة إيجار + كهرباء شهر أغسطس", "debit": 650.0, "credit": 0.0, "balance": 650.0},
    {"date": "2026-08-05", "desc": "سند قبض - دفعة نقداً", "debit": 0.0, "credit": 500.0, "balance": 150.0},
    {"date": "2026-08-12", "desc": "رسوم صيانة مضخة المياه", "debit": 30.0, "credit": 0.0, "balance": 180.0},
    {"date": "2026-08-20", "desc": "سند قبض - تسديد باقي الحساب", "debit": 0.0, "credit": 180.0, "balance": 0.0},
  ];

  AccountStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double totalDebit = records.fold(0, (sum, i) => sum + (i['debit'] as double));
    double totalCredit = records.fold(0, (sum, i) => sum + (i['credit'] as double));
    double finalBalance = totalDebit - totalCredit;

    return Scaffold(
      appBar: AppBar(title: const Text('كشف حساب دقيق للمستأجر')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _summaryCard('إجمالي المدين (عليه)', '${totalDebit.toStringAsFixed(2)} \$', Colors.redAccent)),
                  const SizedBox(width: 6),
                  Expanded(child: _summaryCard('إجمالي الدائن (له)', '${totalCredit.toStringAsFixed(2)} \$', Colors.greenAccent)),
                  const SizedBox(width: 6),
                  Expanded(child: _summaryCard('الرصيد النهائي', '${finalBalance.abs().toStringAsFixed(2)} \$', finalBalance > 0 ? Colors.orange : Colors.blue)),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF2C2C2C)),
                      columns: const [
                        DataColumn(label: Text('التاريخ')),
                        DataColumn(label: Text('البيان / الحركة')),
                        DataColumn(label: Text('مدين (عليه)', style: TextStyle(color: Colors.redAccent))),
                        DataColumn(label: Text('دائن (له)', style: TextStyle(color: Colors.greenAccent))),
                        DataColumn(label: Text('الرصيد التراكمي')),
                      ],
                      rows: records.map((r) {
                        return DataRow(cells: [
                          DataCell(Text(r['date'].toString())),
                          DataCell(Text(r['desc'].toString())),
                          DataCell(Text(r['debit'] > 0 ? '${r['debit']}' : '-', style: const TextStyle(color: Colors.redAccent))),
                          DataCell(Text(r['credit'] > 0 ? '${r['credit']}' : '-', style: const TextStyle(color: Colors.greenAccent))),
                          DataCell(Text('${r['balance']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
