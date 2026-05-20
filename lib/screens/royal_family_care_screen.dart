import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import 'family_care_purchase_screen.dart';
import 'customer_renewal_screen.dart';

class RoyalFamilyCareScreen extends StatelessWidget {
  final bool isFromNewPolicy;
  const RoyalFamilyCareScreen({super.key, this.isFromNewPolicy = false});

  final List<String> _cardImages = const [
    'assets/images/e3.png',
    'assets/images/e3.png',
    'assets/images/e3.png',
    'assets/images/e3.png',
    'assets/images/e3.png',
  ];

  List<Map<String, String>> get _cardData => const [
        {
          'title': 'Option A',
          'price': 'Parent: ₦2,625 / Child: ₦1,125',
          'death': '₦250,000.00',
          'disability': '₦250,000.00',
          'medical': '₦50,000.00',
          'childDisability': '₦250,000',
          'childMedical': '₦50,000',
          'parentPremium': '₦2625',
          'childPremium': '₦1125'
        },
        {
          'title': 'Option B',
          'price': 'Parent: ₦5,250 / Child: ₦2,250',
          'death': '₦500,000.00',
          'disability': '₦500,000.00',
          'medical': '₦100,000.00',
          'childDisability': '₦500,000',
          'childMedical': '₦100,000',
          'parentPremium': '₦5250',
          'childPremium': '₦2250'
        },
        {
          'title': 'Option C',
          'price': 'Parent: ₦10,500 / Child: ₦4,500',
          'death': '₦1,000,000.00',
          'disability': '₦1,000,000.00',
          'medical': '₦200,000.00',
          'childDisability': '₦1,000,000',
          'childMedical': '₦200,000',
          'parentPremium': '₦10500',
          'childPremium': '₦4500'
        },
        {
          'title': 'Option D',
          'price': 'Parent: ₦15,750 / Child: ₦6,750',
          'death': '₦1,500,000.00',
          'disability': '₦1,500,000.00',
          'medical': '₦300,000.00',
          'childDisability': '₦1,500,000',
          'childMedical': '₦300,000',
          'parentPremium': '₦15750',
          'childPremium': '₦6750'
        },
        {
          'title': 'Option E',
          'price': 'Parent: ₦21,000 / Child: ₦9,000',
          'death': '₦2,000,000.00',
          'disability': '₦2,000,000.00',
          'medical': '₦400,000.00',
          'childDisability': '₦2,000,000',
          'childMedical': '₦400,000',
          'parentPremium': '₦21000',
          'childPremium': '₦9000'
        },
      ];

  static const List<Color> _bgColors = [
    Color(0xFFFFF8E1),
    Color(0xFFE8F5E9),
    Color(0xFFE0F7FA),
    Color(0xFFE8EAF6),
    Color(0xFFFCE4EC)
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
          title: Text('Royal Family Care',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          centerTitle: true),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            ...List.generate(_cardData.length, (i) {
              final d = _cardData[i];
              return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        color: _cardColor(context, i),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor(context))),
                    child: Padding(
                        padding: const EdgeInsets.all(14),
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
                              Text('Parent',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _secondaryTextColor(context))),
                              const SizedBox(height: 4),
                              _amt(d['death']!, '(Death)', context),
                              const SizedBox(height: 4),
                              _amt(d['disability']!, '(Permanent Disability)',
                                  context),
                              _amt(
                                  d['medical']!, '(Medical Expenses)', context),
                              const SizedBox(height: 8),
                              Text('Child',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _secondaryTextColor(context))),
                              const SizedBox(height: 4),
                              _amt(d['childDisability']!, '(Disability)',
                                  context),
                              _amt(d['childMedical']!, '(Medical Expenses)',
                                  context),
                              const SizedBox(height: 12),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    FamilyCarePurchaseScreen(
                                                        optionTitle:
                                                            d['title']!,
                                                        price: d['price']!))),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                _actionColor(context),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        child: const Text('Buy Now',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold)))
                                  ]),
                              const SizedBox(height: 10),
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
                                          Text(
                                              'Parent: ${d['parentPremium']} / Child: ${d['childPremium']} yearly',
                                              style: TextStyle(
                                                  fontSize: 12,
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
                                        child: const Text('Renew Now',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600)))
                                  ]),
                            ])),
                  ));
            }),
            const SizedBox(height: 20),
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
                  Image.asset('assets/images/e3.png', fit: BoxFit.cover),
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
                          Text('Royal Family Care',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                          SizedBox(height: 8),
                          Text(
                              'Ensure your family have adequate provision against unexpected events such as accidents. This product provides compensation for you and your family members in case of such event. Stay safe, stay protected.',
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
        height: 240,
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
                  '• Death: ${data['death']}\n• Disability: ${data['disability']}\n• Medical: ${data['medical']}\n• Child: Disability ${data['childDisability']} / Medical ${data['childMedical']}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.white, height: 1.3),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
              const Spacer(),
              Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FamilyCarePurchaseScreen(
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
