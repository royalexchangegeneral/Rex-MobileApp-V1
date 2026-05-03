import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'category_articles_screen.dart';
import 'video_player_screen.dart';

class DiscoverInsuranceScreen extends StatelessWidget {
  const DiscoverInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Discover Insurance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Video section
            Text('Featured Video', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 14),
            _buildFeaturedVideoCard(context),
            SizedBox(height: 28),

            // Categories section
            Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _buildCategoryCard(context, Icons.description_outlined, 'Policy Basics', '8 articles', AppTheme.primaryNavy, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryArticlesScreen.policyBasics()));
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryCard(context, Icons.assignment_outlined, 'Claims Guide', '6 articles', AppTheme.accentOrange, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryArticlesScreen.claimsGuide()));
                })),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCategoryCard(context, Icons.directions_car_outlined, 'Motor Insurance', '5 articles', const Color(0xFF4A90D9), onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryArticlesScreen.motorInsurance()));
                })),
                SizedBox(width: 12),
                Expanded(child: _buildCategoryCard(context, Icons.home_outlined, 'Property Cover', '4 articles', const Color(0xFFE91E63), onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryArticlesScreen.propertyCover()));
                })),
              ],
            ),
            SizedBox(height: 28),

            // Insurance 101 section
            Text('Insurance 101: The Basics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insurance is a way to protect yourself, your family, and your belongings from unexpected events. Think of it as a safety net — when things go wrong, insurance helps cover the costs so you don\'t have to handle it all on your own.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.6),
                  ),
                  SizedBox(height: 16),
                  Text('Here\'s how it works:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 10),
                  _buildBulletPoint('You pay a premium', 'A small amount regularly.'),
                  const SizedBox(height: 8),
                  _buildBulletPoint('We provide coverage', 'If an event happens (like an accident, damage or theft), the insurance helps pay for it.'),
                  SizedBox(height: 8),
                  _buildBulletPoint('Peace of mind', 'You can focus on life, knowing you\'re financially protected.'),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Types of Insurance
            Text('Types of Insurance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            _buildInsuranceTypeCard(Icons.directions_car, 'Vehicle Insurance', 'Covers damages or loss of your vehicle.', const Color(0xFF4A90D9)),
            const SizedBox(height: 10),
            _buildInsuranceTypeCard(Icons.home, 'Property Insurance', 'Protects your home or valuable belongings.', const Color(0xFFE91E63)),
            const SizedBox(height: 10),
            _buildInsuranceTypeCard(Icons.shield_outlined, 'General Insurance', 'Protects your valuable assets from fire, theft and burglary.', AppTheme.primaryNavy),
            const SizedBox(height: 20),

            // Bottom note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppTheme.accentOrange, size: 20),
                      SizedBox(width: 8),
                      Text('Why It Matters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'With insurance, you transfer the risk from yourself to the insurer. It\'s not about avoiding risk — it\'s about managing it smartly.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Get Insured Today', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: SizedBox(
          width: 52,
          height: 52,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
            backgroundColor: AppTheme.accentOrange,
            shape: const CircleBorder(),
            elevation: 1,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false, onTap: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (route) => false);
              }),
              _buildNavItem(Icons.description_outlined, 'Policies', false),
              const SizedBox(width: 48),
              _buildNavItem(Icons.assignment_outlined, 'Claims', false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()));
              }),
              _buildNavItem(Icons.person_outline, 'Profile', false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedVideoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with "New" badge
          GestureDetector(
            onTap: () => _openYouTubeVideo(context),
            child: Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C3E50),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage(
                      image: AssetImage('assets/images/2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('New', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Understanding Your Insurance Policy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 6),
                Text(
                  'Learn the key components of your insurance policy and how to maximize your coverage benefits.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('12 min', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    GestureDetector(
                      onTap: () => _openYouTubeVideo(context),
                      child: const Text('Watch Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, IconData icon, String title, String subtitle, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            const SizedBox(height: 8),
            const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentOrange)),
          ],
        ),
      ),
    );
  }

  void _openYouTubeVideo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VideoPlayerScreen(
          videoId: 'Jzq8seU_p2I',
          title: 'Understanding Your Insurance Policy',
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: AppTheme.accentOrange, shape: BoxShape.circle),
        ),
        SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.5),
              children: [
                TextSpan(text: '$title: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsuranceTypeCard(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
        ],
      ),
    );
  }
}
