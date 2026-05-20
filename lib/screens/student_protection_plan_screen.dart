import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import 'student_protection_purchase_screen.dart';
import 'customer_renewal_screen.dart';

class StudentProtectionPlanScreen extends StatelessWidget {
  final bool isFromNewPolicy;
  const StudentProtectionPlanScreen({super.key, this.isFromNewPolicy = false});

  final List<String> _cardImages = const [
    'assets/images/e8.png',
    'assets/images/e8.png',
    'assets/images/e8.png',
    'assets/images/e8.png',
    'assets/images/e8.png',
  ];

  List<Map<String, String>> get _cardData => const [
        {
          'title': 'Option A',
          'price': '₦5,250 yearly',
          'death': '₦500,000.00',
          'disability': '₦500,000.00',
          'medical': '₦50,000.00',
          'premium': '₦5250'
        },
        {
          'title': 'Option B',
          'price': '₦8,375 yearly',
          'death': '₦750,000.00',
          'disability': '₦750,000.00',
          'medical': '₦100,000.00',
          'premium': '₦8375'
        },
        {
          'title': 'Option C',
          'price': '₦11,500 yearly',
          'death': '₦1,000,000.00',
          'disability': '₦1,000,000.00',
          'medical': '₦150,000.00',
          'premium': '₦11500'
        },
        {
          'title': 'Option D',
          'price': '₦16,750 yearly',
          'death': '₦1,500,000.00',
          'disability': '₦1,500,000.00',
          'medical': '₦200,000.00',
          'premium': '₦16750'
        },
        {
          'title': 'Option E',
          'price': '₦22,000 yearly',
          'death': '₦2,000,000.00',
          'disability': '₦2,000,000.00',
          'medical': '₦250,000.00',
          'premium': '₦22000'
        },
      ];

  static const List<Color> _bgColors = [
    Color(0xFFE8F5E9),
    Color(0xFFE8F5E9),
    Color(0xFFFFF8E1),
    Color(0xFFF3E5F5),
    Color(0xFFE3F2FD)
  ];
  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _cardColor(BuildContext context, int index) =>
      _isDark(context) ? const Color(0xFF111827) : _bgColors[index];

  Color _borderColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF334155) : Colors.transparent;

  Color _secondaryTextColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFCBD5E1) : Colors.grey[700]!;

  Color _actionColor(BuildContext context) =>
      _isDark(context) ? AppTheme.accentOrange : AppTheme.primaryNavy;

  @override
  Widget build(BuildContext context) {
    if (isFromNewPolicy) return _buildFlatLayout(context);
    return _buildExploreLayout(context);
  }

  Widget _buildFlatLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.pop(context)),
          title: Text('Student Protection Plan',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          centerTitle: true),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(children: [
            ...List.generate(_cardData.length, (i) {
              final d = _cardData[i];
              return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        color: _cardColor(context, i),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor(context))),
                    child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['title']!,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface)),
                              const SizedBox(height: 2),
                              Text('For sum insured/benefit up to',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: _secondaryTextColor(context))),
                              const SizedBox(height: 8),
                              _amt(d['death']!, '(Death)', context),
                              const SizedBox(height: 4),
                              _amt(d['disability']!, '(Permanent Disability)',
                                  context),
                              _amt(
                                  d['medical']!, '(Medical Expenses)', context),
                              SizedBox(height: 12),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    StudentProtectionPurchaseScreen(
                                                        optionTitle:
                                                            d['title']!,
                                                        price: d['price']!))),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                _actionColor(context),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        child: Text('Buy Now',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold)))
                                  ]),
                              SizedBox(height: 10),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Premium',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: _secondaryTextColor(
                                                      context))),
                                          Text('${d['premium']} yearly',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface))
                                        ]),
                                    OutlinedButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const CustomerRenewalScreen())),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                _actionColor(context),
                                            side: BorderSide(
                                                color: _actionColor(context)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        child: Text('Renew Now',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600)))
                                  ]),
                            ])),
                  ));
            }),
            SizedBox(height: 20),
          ])),
    );
  }

  Widget _amt(String v, String l, BuildContext context) => RichText(
          text: TextSpan(
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
              children: [
            TextSpan(
                text: '$v ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
                text: l, style: TextStyle(color: _secondaryTextColor(context)))
          ]));

  Widget _buildExploreLayout(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(slivers: [
          SliverAppBar(
              expandedHeight: 450,
              pinned: false,
              leading: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle),
                  child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context))),
              flexibleSpace: FlexibleSpaceBar(
                  background: Column(children: [
                Expanded(
                    child: Stack(fit: StackFit.expand, children: [
                  Image.asset('assets/images/e8.png', fit: BoxFit.cover),
                  Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.5)
                      ]))),
                ])),
                Container(
                    color: ThemeHelper.getCardColor(context),
                    padding: EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Student Protection Plan',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                          SizedBox(height: 8),
                          Text(
                              'Sometimes children/ward drop out of school due to permanent disability or death of parent or guardian. This cover provides them the assurance of continuous education in situation where this occurs.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  height: 1.4)),
                        ])),
              ]))),
          SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildImageCard(
                              _cardImages[index], index, context)),
                      childCount: _cardImages.length))),
        ]));
  }

  Widget _buildImageCard(String imagePath, int index, BuildContext context) {
    final data = _cardData[index];
    return Container(
        height: 220,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
                image: AssetImage(imagePath), fit: BoxFit.cover)),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.85)
                    ])),
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(data['price']!,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))
              ]),
              const SizedBox(height: 6),
              Text(data['title']!,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                  '• Death: ${data['death']}\n• Disability: ${data['disability']}\n• Medical: ${data['medical']}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.white, height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const Spacer(),
              Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => StudentProtectionPurchaseScreen(
                                  optionTitle: data['title']!,
                                  price: data['price']!))),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text('Buy Now',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)))),
            ])));
  }
}
