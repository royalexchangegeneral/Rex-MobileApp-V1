import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/app_theme.dart';

class ExploreServicesScreen extends StatefulWidget {
  const ExploreServicesScreen({super.key});

  @override
  State<ExploreServicesScreen> createState() => _ExploreServicesScreenState();
}

class _ExploreServicesScreenState extends State<ExploreServicesScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _services = [
    {
      'image': 'assets/images/e1.png',
      'title': 'Motor Third Party',
      'description':
          'This policy covers the third party against bodily injury and death resulting from a car accident caused by the insured the legal liability of the insured where damage was caused to another person\'s property',
    },
    {
      'image': 'assets/images/e2.png',
      'title': 'Royal Personal Care Plan',
      'description':
          'Ensure you have adequate provision for yourself against unforeseen circumstances. Facing everyday life risk could result in an accident. This product provides compensation for medical expenses, permanent disability and death',
    },
    {
      'image': 'assets/images/e3.png',
      'title': 'Royal Family Care Plan',
      'description':
          'Ensure your family have adequate provision for yourself against unexpected events such as accidents. This product provides compensation for you and your family members in a case of such event. Stay safe, stay protected with royal personal care product...',
    },
    {
      'image': 'assets/images/e4.png',
      'title': 'Royal Group Care Plan',
      'description':
          'Royal Group Care is an insurance product that is specially and uniquely designed for Groups, Associations and Staff of organizations to provide compensation in case of an accident resulting in bodily injury, medical expenses, permanent disability, or...',
    },
    {
      'image': 'assets/images/e5.png',
      'title': 'Shop Protection Plan',
      'description':
          'Shops, supermarket business owners are exposed to risks of loss or damage resulting from fire, burglary, flood, windstorm etc. You get protection for your goods and shop/office from us through this insurance cover...',
    },
    {
      'image': 'assets/images/e6.png',
      'title': 'Driver & Riders Protection Plan',
      'description':
          'This product is a compensation plan specially designed for licensed, personal drivers, corporate drivers, Commercial drivers, Dispatch riders, Tricycle riders and Motorcycle riders to provide payment for medical expenses in event of an accident result...',
    },
    {
      'image': 'assets/images/e7.png',
      'title': 'Home Protection Plan (Fire Only)',
      'description':
          'Every year, families suffer losses or damage to their household items as a result of fire, flood and windstorm. This product is designed to help you recover your losses in event of any of these risk occurring. It also covers liability to your neighbour',
    },
    {
      'image': 'assets/images/e8.png',
      'title': 'Parcel Protection Plan',
      'description':
          'This plan provides cover for your goods while in transit by road, rail, or inland waterway, it also covers your goods while boarding or unloading and while temporarily garaged in the course of transit. The product will indemnify you on goods lost or...',
    },
    {
      'image': 'assets/images/e9.png',
      'title': 'Student Protection Plan',
      'description':
          'Sometimes children / ward drop out of school due to permanent disability or death of parent or guardian. This cover provides them the assurance of continuous education in situation where this occurs',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView with service cards
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _services.length,
            itemBuilder: (context, index) {
              return _buildServiceCard(_services[index]);
            },
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Page indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _services.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: AppTheme.accentOrange,
                  dotColor: Colors.white,
                  spacing: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, String> service) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(service['image']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.95),
            ],
            stops: const [0.0, 0.4, 0.8],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Title
                    Text(
                      service['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      service['description']!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),

                    // Buy Now Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Buy ${service['title']}'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Buy Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
