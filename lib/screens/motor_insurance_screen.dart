import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/explore_kyc_flow.dart';
import '../utils/theme_helper.dart';
import 'private_car_purchase_screen.dart';
import 'comprehensive_personal_info_screen.dart';
import 'royal_auto_purchase_screen.dart';

class MotorInsuranceScreen extends StatelessWidget {
  final bool requiresKycOnBuy;

  const MotorInsuranceScreen({super.key, this.requiresKycOnBuy = false});

  final List<String> _thirdPartyCardImages = const [
    'assets/images/t1.png',
    'assets/images/t2.png',
    'assets/images/t3.png',
    'assets/images/t4.png',
    'assets/images/t5.png',
    'assets/images/t6.png',
    'assets/images/t7.png',
    'assets/images/t8.png',
    'assets/images/t9.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 450,
                pinned: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset('assets/images/t0.png',
                                fit: BoxFit.cover),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.black.withOpacity(0.5)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: ThemeHelper.getCardColor(context),
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Motor Insurance',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                            SizedBox(height: 8),
                            Text(
                              'This policy covers the third party against bodily injury and death resulting from a car accident caused by the insured the legal liability of the insured where damage was caused to another person\'s property',
                              style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildInsuranceCard(
                          _thirdPartyCardImages[index], index, context),
                    ),
                    childCount: _thirdPartyCardImages.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard(
      String imagePath, int index, BuildContext context) {
    final cardData = _getCardData(index);
    return Container(
      height: cardData['height'] as double,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.85)
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(cardData['price'] as String,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))
              ],
            ),
            const SizedBox(height: 6),
            Text(cardData['title'] as String,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(cardData['description'] as String,
                style: const TextStyle(
                    fontSize: 12, color: Colors.white, height: 1.3),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _navigateToScreen(context, index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Buy Now',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getCardData(int index) {
    final data = [
      {
        'title': 'Private Car',
        'price': 'N15,000.00',
        'description':
            '• For third party damage up to N3,000,000.00\n• Accidental bodily injury or death to the third party arising from the use of the vehicle.',
        'height': 220.0
      },
      {
        'title': 'Commercial Vehicle',
        'price': 'N20,000.00',
        'description':
            '• Third Party property damage\n• Accidental bodily injury or death to the third party arising from the use of the vehicle.',
        'height': 220.0
      },
      {
        'title': 'Private Bus',
        'price': 'N20,000.00',
        'description': 'For third party damage up to N3,000,000.00',
        'height': 220.0
      },
      {
        'title': 'Commercial Bus',
        'price': 'Premium – N20,000 yearly',
        'description': 'For third party damage up to N3,000,000.00',
        'height': 220.0
      },
      {
        'title': 'Motorcycle',
        'price': 'Premium – N3000 Yearly',
        'description': 'For sum insured/benefit up to N1,000,000.00',
        'height': 220.0
      },
      {
        'title': 'Tricycle (Keke)',
        'price': 'Premium – N5000 Yearly',
        'description': 'For sum insured/benefit up to N1,000,000.00',
        'height': 220.0
      },
      {
        'title': 'Motor Comprehensive (Private & Commercial)',
        'price': '',
        'description':
            'It also covers the liability of the insured to third parties in respect of:\n- Third Party property damage\n- Accidental bodily injury or death to the third party arising from the use of the vehicle.',
        'height': 280.0
      },
      {
        'title': 'Royal Auto Bronze',
        'price': 'Premium – 3% + N15,000/m',
        'description': 'Coverage up to N3,000,000',
        'height': 220.0
      },
      {
        'title': 'Royal Auto Silver',
        'price': 'Premium – 3% + N15,000/m',
        'description': 'Coverage up to N3,000,000',
        'height': 220.0
      },
    ];
    return data[index];
  }

  void _navigateToScreen(BuildContext context, int index) {
    if (requiresKycOnBuy) {
      final cardData = _getCardData(index);
      final target = index == 6
          ? 'comprehensive_motor'
          : index == 7 || index == 8
              ? 'royal_auto'
              : 'private_car';
      startExploreKycFlow(
        context,
        target: target,
        productName: cardData['title'] as String,
        optionTitle: cardData['title'] as String,
        price: cardData['price'] as String,
      );
      return;
    }

    if (index == 6) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const ComprehensivePersonalInfoScreen()));
    } else if (index == 7 || index == 8) {
      final cardData = _getCardData(index);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RoyalAutoPurchaseScreen(
                  productName: cardData['title'] as String,
                  price: cardData['price'] as String)));
    } else {
      final cardData = _getCardData(index);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PrivateCarPurchaseScreen(
                  vehicleType: cardData['title'] as String,
                  price: cardData['price'] as String)));
    }
  }
}
