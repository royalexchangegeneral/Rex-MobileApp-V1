import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'private_car_purchase_screen.dart';

class MotorThirdPartyScreen extends StatelessWidget {
  const MotorThirdPartyScreen({super.key});

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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable list of third party types
          CustomScrollView(
            slivers: [
              // Header with background image
              SliverAppBar(
                expandedHeight: 450,
                pinned: false,
                backgroundColor: Colors.white,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      // Image section
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/t0.png',
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.black.withOpacity(0.5),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // White text section
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Motor Third Party',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'This policy covers the third party against bodily injury and death resulting from a car accident caused by the insured the legal liability of the insured where damage was caused to another person\'s property',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // List of insurance types
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildInsuranceCard(
                          _thirdPartyCardImages[index],
                          index,
                          context,
                        ),
                      );
                    },
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

  Widget _buildInsuranceCard(String imagePath, int index, BuildContext context) {
    // Only show overlay on first card (index 0)
    if (index == 0) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price at top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'N15,000.00',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Title
              const Text(
                'Private Car',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Details
              const Text(
                '• For third party damage up to N3,000,000.00',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                '• Accidental bodily injury or death to the third party arising from the use of the vehicle.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Buy Now Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivateCarPurchaseScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Commercial Vehicle card (index 1)
    if (index == 1) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price at top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'N20,000 (Own Goods & Staff Buses)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'N100,000 (Trucks)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Title
              const Text(
                'Commercial Vehicle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Details
              const Text(
                '• Third Party property damage',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                '• Accidental bodily injury or death to the third party arising from the use of the vehicle.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Buy Now Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle buy action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Private Bus card (index 2)
    if (index == 2) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price at top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'N20,000.00',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Title
              const Text(
                'Private Bus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Details
              const Text(
                'For third party damage up to N3,000,000.00',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              // Buy Now Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle buy action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Commercial Bus card (index 3)
    if (index == 3) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price at top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Premium – N20,000 yearly',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Title
              const Text(
                'Commercial Bus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Details
              const Text(
                'For third party damage up to N3,000,000.00',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              // Buy Now Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle buy action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Motocycle card (index 4)
    if (index == 4) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price at top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Premium – N3000 Yearly',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Title
              const Text(
                'Motocycle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Details
              const Text(
                'For sum insured/benefit up to N1,000,000.00',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              // Buy Now Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle buy action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tricycle (Keke) card (index 5)
    if (index == 5) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price at top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Premium – N5000 Yearly',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Title
              const Text(
                'Tricycle (Keke)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Details
              const Text(
                'For sum insured/benefit up to N1,000,000.00',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              // Buy Now Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle buy action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Motor Comprehensive card (index 6)
    if (index == 6) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Motor Comprehensive (Private & Commercial)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 5),
              // Details
              const Text(
                'It also covers the liability of the insured to third parties in respect of:',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '- Third Party property damage',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 1),
              const Text(
                '- Accidental bodily injury or death to the third party arising from the use of the vehicle.',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 1),
              const Text(
                '- Claimant\'s cost and expenses incurred with the consent of the company.',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              // Buy Now Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle buy action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Royal Auto Bronze card (index 7)
    if (index == 7) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price at top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Premium – 3% + N15,000',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Title
              const Text(
                'Royal Auto Bronze',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              // Details
              const Text(
                '• It covers accidental damage to the insured\'s vehicle.',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '• It also covers the liability of the insured to third parties in respect of:',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '  – Third Party property damage',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 1),
              const Text(
                '  – Accidental bodily injury or death to the third party arising from the use of the vehicle',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(text: '• Towing Expense – N10,000...'),
                    TextSpan(
                      text: 'read more',
                      style: TextStyle(
                        color: AppTheme.accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Buy Now Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle buy action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Royal Auto Silver card (index 8)
    if (index == 8) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price at top right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Premium – 3.5% + N15,000',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Title
              const Text(
                'Royal Auto Silver',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              // Details
              const Text(
                '• It covers accidental damage to the insured\'s vehicle.',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '• It also covers the liability of the insured to third parties in respect of:',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '  – Third Party property damage',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 1),
              const Text(
                '  – Accidental bodily injury or death to the third party arising from the use of the vehicle',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(text: '• Towing Expense – N20,000...'),
                    TextSpan(
                      text: 'read more',
                      style: TextStyle(
                        color: AppTheme.accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Buy Now Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle buy action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Regular card without overlay for other cards
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
