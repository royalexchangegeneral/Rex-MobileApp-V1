import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'agent_dashboard_screen.dart';
import 'clients_list_screen.dart';
import 'agent_profile_screen.dart';
import 'agent_policies_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedReportType;
  int _selectedDateRange = -1;
  int _selectedFormat = -1;
  bool _downloading = false;
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  final List<String> _reportTypes = ['Sales Report'];
  final List<String> _dateRanges = ['Today', 'This Week', 'This Month', 'Custom'];
  final List<String> _periodValues = ['today', 'this_week', 'this_month', 'custom'];

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void dispose() { _fromDateController.dispose(); _toDateController.dispose(); super.dispose(); }

  Future<void> _downloadReport() async {
    if (_selectedReportType == null) { _snack('Please select a report type'); return; }
    if (_selectedDateRange == -1) { _snack('Please select a date range'); return; }
    if (_selectedFormat == -1) { _snack('Please select a download format'); return; }
    if (_selectedDateRange == 3 && (_fromDate == null || _toDate == null)) { _snack('Please select from and to dates'); return; }

    setState(() => _downloading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final agentCode = auth.userCode ?? '';
    final period = _periodValues[_selectedDateRange];
    final now = DateTime.now();
    String startDate, endDate;

    if (period == 'today') {
      startDate = _fmt(now); endDate = _fmt(now);
    } else if (period == 'this_week') {
      final ws = now.subtract(Duration(days: now.weekday - 1));
      startDate = _fmt(ws); endDate = _fmt(ws.add(const Duration(days: 6)));
    } else if (period == 'this_month') {
      startDate = _fmt(DateTime(now.year, now.month, 1));
      endDate = _fmt(DateTime(now.year, now.month + 1, 0));
    } else {
      startDate = _fmt(_fromDate!); endDate = _fmt(_toDate!);
    }

    try {
      final url = 'https://eportaltest.rexinsure.com/api/fetch-policy-report?agentcode=$agentCode&period=$period&startdate=$startDate&enddate=$endDate';
      print('=== FETCH REPORT ===');
      print('Payload: agentcode=$agentCode, period=$period, startdate=$startDate, enddate=$endDate');
      print('URL: $url');
      final r = await http.get(Uri.parse(url), headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 20));
      print('=== REPORT RESPONSE: ${r.statusCode} ===');
      print('Body: ${r.body}');

      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        print('=== PARSED RESPONSE TYPE: ${d.runtimeType} ===');
        
        // Parse grouped policy class data nested under 'data' key
        // Response: {status, message, period, data: {TP: {count, data}, PC: {count, data}, ...}}
        final Map<String, dynamic> grouped = {};
        int totalRecords = 0;
        
        if (d is Map) {
          final source = d['data'] is Map ? d['data'] as Map : d;
          source.forEach((key, value) {
            if (value is Map && value.containsKey('count') && value.containsKey('data')) {
              final cnt = value['count'] is int ? value['count'] : int.tryParse(value['count'].toString()) ?? 0;
              final records = value['data'] is List ? value['data'] as List : [];
              if (cnt > 0 || records.isNotEmpty) {
                grouped[key.toString()] = {'count': cnt, 'data': records};
                totalRecords += records.length;
              }
            }
          });
        }
        
        print('=== POLICY CLASSES: ${grouped.keys.toList()}, TOTAL RECORDS: $totalRecords ===');
        
        if (grouped.isEmpty || totalRecords == 0) { _snack('No data / report for that period'); setState(() => _downloading = false); return; }

        final extensions = ['csv', 'pdf', 'csv'];
        final ext = extensions[_selectedFormat];
        final dir = await getApplicationDocumentsDirectory();
        final fileName = 'RexVerse_Report_${period}_$startDate.$ext';
        final file = File('${dir.path}/$fileName');

        print('=== GENERATING $ext FILE: ${file.path} ===');

        if (_selectedFormat == 0) {
          await _generateGroupedCsv(file, grouped);
        } else if (_selectedFormat == 1) {
          await _generateGroupedPdf(file, grouped, period, startDate, endDate);
        } else {
          await _generateGroupedCsv(file, grouped);
        }

        print('=== FILE CREATED: ${await file.exists()}, SIZE: ${await file.length()} bytes ===');

        if (mounted) {
          final box = context.findRenderObject() as RenderBox?;
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'Policy Report - $period',
            sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : const Rect.fromLTWH(0, 0, 100, 100),
          );
          _snack('Report generated successfully', isSuccess: true);
        }
      } else {
        _snack('Failed to fetch report: ${r.statusCode}');
      }
    } catch (e) {
      print('Report error: $e');
      _snack('Error generating report: $e');
    }
    setState(() => _downloading = false);
  }

  Future<void> _generateGroupedCsv(File file, Map<String, dynamic> grouped) async {
    final buf = StringBuffer();
    final headers = ['refno', 'payrefno', 'policyno', 'prodcodenames', 'email', 'premium', 'startdate', 'enddate', 'policystatus', 'biller', 'created_at'];
    
    for (final entry in grouped.entries) {
      final className = entry.key;
      final classData = entry.value as Map;
      final count = classData['count'] ?? 0;
      final records = classData['data'] as List;
      
      buf.writeln('');
      buf.writeln('Policy Class: $className (Count: $count)');
      buf.writeln(headers.join(','));
      
      for (final record in records) {
        final m = record as Map;
        buf.writeln(headers.map((h) => '"${m[h] ?? ''}"').join(','));
      }
    }
    await file.writeAsString(buf.toString());
  }

  Future<void> _generateGroupedPdf(File file, Map<String, dynamic> grouped, String period, String startDate, String endDate) async {
    final pdf = pw.Document();
    final headers = ['Ref No', 'Policy No', 'Product', 'Names', 'Email', 'Premium', 'Start', 'End', 'Status'];
    final keys = ['refno', 'policyno', 'prodcode', 'names', 'email', 'premium', 'startdate', 'enddate', 'policystatus'];

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (ctx) {
        final widgets = <pw.Widget>[
          pw.Header(level: 0, text: 'RexVerse Policy Report'),
          pw.Text('Period: $period | From: $startDate | To: $endDate', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 10),
        ];

        for (final entry in grouped.entries) {
          final className = entry.key;
          final classData = entry.value as Map;
          final count = classData['count'] ?? 0;
          final records = classData['data'] as List;

          widgets.add(pw.Header(level: 1, text: 'Policy Class: $className (Count: $count)'));

          if (records.isNotEmpty) {
            widgets.add(pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              cellStyle: const pw.TextStyle(fontSize: 7),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headers: headers,
              data: records.map((r) {
                final m = r as Map;
                return keys.map((k) => (m[k] ?? '').toString()).toList();
              }).toList(),
            ));
          }
          widgets.add(pw.SizedBox(height: 10));
        }
        return widgets;
      },
    ));

    await file.writeAsBytes(await pdf.save());
  }

  void _snack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isSuccess ? Colors.green : Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Reports', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)), centerTitle: true, actions: const []),
      body: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reports', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          SizedBox(height: 8),
          Container(padding: EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: _selectedReportType, isExpanded: true,
              hint: Text('select report type', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 18),
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
              items: _reportTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedReportType = v),
            ))),
          SizedBox(height: 16),
          Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Select Date Range', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 10),
              Row(children: List.generate(_dateRanges.length, (i) {
                final sel = _selectedDateRange == i;
                return Expanded(child: Padding(padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  child: GestureDetector(onTap: () => setState(() => _selectedDateRange = i),
                    child: Container(padding: EdgeInsets.symmetric(vertical: 7, horizontal: 2),
                      decoration: BoxDecoration(color: sel ? const Color(0xFFE8923E) : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: sel ? const Color(0xFFD4A574) : Colors.grey[300]!)),
                      child: Center(child: Text(_dateRanges[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: sel ? Colors.white : Colors.black)))))));
              })),
              if (_selectedDateRange == 3) ...[
                SizedBox(height: 14),
                Text('From Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 6),
                GestureDetector(onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (picked != null) setState(() { _fromDate = picked; _fromDateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}'; });
                }, child: AbsorbPointer(child: TextField(controller: _fromDateController, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(hintText: 'dd/mm/yyyy', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12), filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14), suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey[500], size: 18))))),
                SizedBox(height: 12),
                Text('To Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 6),
                GestureDetector(onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (picked != null) setState(() { _toDate = picked; _toDateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}'; });
                }, child: AbsorbPointer(child: TextField(controller: _toDateController, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(hintText: 'dd/mm/yyyy', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12), filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14), suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey[500], size: 18))))),
              ],
              SizedBox(height: 16),
              Text('Download Format', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 10),
              Row(children: [
                _buildFormatCard(0, Icons.description_outlined, 'CSV', const Color(0xFF2E7D6F), const Color(0xFFE8F5E9)),
                const SizedBox(width: 12),
                _buildFormatCard(1, Icons.picture_as_pdf_outlined, 'PDF', const Color(0xFFE53935), const Color(0xFFFFEBEE)),
                const SizedBox(width: 12),
                _buildFormatCard(2, Icons.table_chart_outlined, 'Excel', const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
              ]),
            ])),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, height: 46, child: ElevatedButton(
            onPressed: _downloading ? null : _downloadReport,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2D64), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
            child: _downloading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Download Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: 60),
        ])),
      bottomNavigationBar: BottomNavigationBar(type: BottomNavigationBarType.fixed, selectedItemColor: const Color(0xFF1E2D64), unselectedItemColor: Colors.grey, currentIndex: 3, selectedFontSize: 11, unselectedFontSize: 11,
        onTap: (i) {
          if (i == 0) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AgentDashboardScreen()), (r) => false);
          if (i == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentPoliciesScreen()));
          if (i == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientsListScreen()));
          if (i == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentProfileScreen()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 22), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined, size: 22), label: 'Policy'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline, size: 22), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined, size: 22), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 22), label: 'Profile'),
        ]),
    );
  }

  Widget _buildFormatCard(int index, IconData icon, String label, Color iconColor, Color bgColor) {
    final sel = _selectedFormat == index;
    return Expanded(child: GestureDetector(onTap: () => setState(() => _selectedFormat = index),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? iconColor : Colors.grey[300]!, width: sel ? 1.5 : 1)),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        ]))));
  }
}
