import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import 'shop_protection_purchase_screen.dart';
import 'customer_renewal_screen.dart';

class ShopProtectionPlanScreen extends StatelessWidget {
  final bool isFromNewPolicy;
  const ShopProtectionPlanScreen({super.key, this.isFromNewPolicy = false});

  final List<String> _cardImages = const [
    'assets/images/e5.png',
    'assets/images/e5.png',
    'assets/images/e5.png',
    'assets/images/e5.png',
    'assets/images/e5.png',
  ];

  List<Map<String, String>> get _cardData => const [
    {'title': 'Option A', 'price': '₦4,000 yearly', 'sumInsured': '₦500,000.00', 'premium': '₦4000'},
    {'title': 'Option B', 'price': '₦6,000 yearly', 'sumInsured': '₦750,000.00', 'premium': '₦6000'},
    {'title': 'Option C', 'price': '₦8,100 yearly', 'sumInsured': '₦1,000,000.00', 'premium': '₦8100'},
    {'title': 'Option D', 'price': '₦12,100 yearly', 'sumInsured': '₦1,500,000.00', 'premium': '₦12100'},
    {'title': 'Option E', 'price': '₦16,250 yearly', 'sumInsured': '₦2,000,000.00', 'premium': '₦16250'},
  ];

  static const List<Color> _bgColors = [Color(0xFFE0F7FA), Color(0xFFB2EBF2), Color(0xFFE8F5E9), Color(0xFFE8EAF6), Color(0xFFFFF8E1)];
  static const List<Color> _icColors = [Color(0xFF00695C), Color(0xFF00695C), Color(0xFF2E7D32), Color(0xFF283593), Color(0xFFB8860B)];

  @override
  Widget build(BuildContext context) {
    if (isFromNewPolicy) return _buildFlatLayout(context);
    return _buildExploreLayout(context);
  }

  Widget _buildFlatLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Shop Protection Plan', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true),
      body: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: EdgeInsets.all(16),
        child: Column(children: [
          ...List.generate(_cardData.length, (i) {
            final d = _cardData[i];
            return Padding(padding: EdgeInsets.only(bottom: 12), child: Container(
              clipBehavior: Clip.hardEdge, decoration: BoxDecoration(color: _bgColors[i], borderRadius: BorderRadius.circular(12)),
              child: Padding(padding: EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d['title']!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text('For sum insured/benefit up to', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 8),
                _amt(d['sumInsured']!, '(Sum Insured)', context),
                SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopProtectionPurchaseScreen(optionTitle: d['title']!, price: d['price']!))),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.accentOrange : AppTheme.primaryNavy, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text('Buy Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))]),
                SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Premium', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    Text('${d['premium']} yearly', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface))]),
                  OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
                    style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.primaryNavy, side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.primaryNavy), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text('Renew Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)))]),
              ])),
            ));
          }),
          SizedBox(height: 20),
        ])),
    );
  }

  Widget _amt(String v, String l, BuildContext context) => RichText(text: TextSpan(style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface), children: [
    TextSpan(text: '$v ', style: const TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: l, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))]));

  Widget _buildExploreLayout(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor, body: CustomScrollView(slivers: [
      SliverAppBar(expandedHeight: 450, pinned: false,
        leading: Container(margin: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
        flexibleSpace: FlexibleSpaceBar(background: Column(children: [
          Expanded(child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/e5.png', fit: BoxFit.cover),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.5)]))),
          ])),
          Container(color: ThemeHelper.getCardColor(context), padding: EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Shop Protection Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)), SizedBox(height: 8),
            Text('Shops, supermarket business owners are exposed to risks of loss or damage resulting from fire, burglary, flood, windstorm etc. You get protection for your goods and shop/office from us through this insurance cover.', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface, height: 1.4)),
          ])),
        ]))),
      SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverList(delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildImageCard(_cardImages[index], index, context)),
        childCount: _cardImages.length))),
    ]));
  }

  Widget _buildImageCard(String imagePath, int index, BuildContext context) {
    final data = _cardData[index];
    return Container(height: 220, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover)),
      child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.4), Colors.black.withValues(alpha: 0.85)])),
        padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(data['price']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))]),
          const SizedBox(height: 6),
          Text(data['title']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('For sum insured/benefit up to ${data['sumInsured']}', style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Align(alignment: Alignment.centerRight, child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopProtectionPurchaseScreen(optionTitle: data['title']!, price: data['price']!))),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentOrange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Buy Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))),
        ])));
  }
}
