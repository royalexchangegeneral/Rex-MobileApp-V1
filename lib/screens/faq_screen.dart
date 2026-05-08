import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class FaqScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearch;
  final bool isAgentFlow;
  const FaqScreen(
      {super.key,
      this.initialCategory,
      this.initialSearch,
      this.isAgentFlow = false});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = [
    'All',
    'policy',
    'Claims',
    'Account',
    'Quotes'
  ];
  final _searchController = TextEditingController();
  int _expandedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      final idx = _filters.indexWhere(
          (f) => f.toLowerCase() == widget.initialCategory!.toLowerCase());
      if (idx >= 0) _selectedFilter = idx;
    }
    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
    }
  }

  final List<Map<String, String>> _faqs = [
    {
      'question': 'What kind of insurance company is Rex Insurance?',
      'answer':
          'Rex Insurance is a general insurance company that helps Nigerians protect everyday things—your car on Lagos roads, your shop or office, your goods in transit, and even your travel plans. We help you stay financially protected when unexpected things happen.',
      'category': 'policy',
    },
    {
      'question': 'What can I insure with Rex Insurance?',
      'answer':
          'You can insure your car, house, shop, office equipment, business stock, goods on the road, and travel plans. Whether you\'re a business owner, salary earner, or entrepreneur, Rex has a solution that fits your needs.',
      'category': 'policy',
    },
    {
      'question': 'How much will insurance with Rex cost me?',
      'answer':
          'Your premium depends on the value of what you want to insure, the level of risk, and the type of cover you choose. We work with your budget and explain everything clearly—no hidden charges, no confusion.',
      'category': 'Quotes',
    },
    {
      'question': 'If something happens, how do I make a claim?',
      'answer':
          'Simply report the incident to us and provide the required documents. Our claims team will guide you step by step—from accident report or police report to assessment and payment—so you\'re not left stranded.',
      'category': 'Claims',
    },
    {
      'question': 'Will Rex Insurance really pay my claim?',
      'answer':
          'Yes. Rex Insurance is known for prompt claims payment. Once your claim is valid and documents are complete, we settle it as quickly as possible—because insurance should work when you need it most.',
      'category': 'Claims',
    },
    {
      'question':
          'Is Rex Insurance only for big companies and oil & gas firms?',
      'answer':
          'Not at all. We insure individuals, small business owners, traders, professionals, and large organisations. Whether it\'s one car or a whole fleet, one shop or several branches, Rex has you covered.',
      'category': 'policy',
    },
    {
      'question': 'Insurance terms are confusing—will I understand my policy?',
      'answer':
          'Yes. We break everything down in simple, everyday language. We\'ll tell you clearly what is covered, what is not covered, and what to do if anything happens—no grammar, no fine print tricks.',
      'category': 'policy',
    },
    {
      'question':
          'Is Rex Insurance a registered and trusted company in Nigeria?',
      'answer':
          'Absolutely. Rex Insurance is fully licensed and regulated by NAICOM, Nigeria\'s insurance regulator. Your policy and premiums are protected under Nigerian insurance laws.',
      'category': 'Account',
    },
    {
      'question': 'Can Rex Insurance help me choose the right cover?',
      'answer':
          'Yes. Our team listens to your situation—whether you\'re running a business, building a house, or moving goods—and recommends the right cover for your actual risks, not what you don\'t need.',
      'category': 'policy',
    },
    {
      'question':
          'Can Rex Insurance tailor a policy specifically for me or my business?',
      'answer':
          'Absolutely. We assess your situation and recommend customized coverage that matches your lifestyle, business operations, and risk exposure—no one-size-fits-all approach.',
      'category': 'policy',
    },
    {
      'question':
          'What if I don\'t understand the insurance terms in my policy?',
      'answer':
          'You\'re not alone—and that\'s okay. Our team explains your coverage in simple, everyday language so you clearly understand what is covered, what is not, and how to use your policy.',
      'category': 'policy',
    },
    {
      'question': 'How easy is it to buy or renew a policy with Rex?',
      'answer':
          'Very easy. You can buy or renew your policy through our offices, licensed agents, or digital platforms. We\'ve streamlined the process to save you time and eliminate stress.',
      'category': 'Account',
    },
    {
      'question': 'How fast does Rex Insurance pay claims?',
      'answer':
          'We pride ourselves on prompt and fair claims settlement. Once all required documents are submitted and verified, we process valid claims as quickly as possible—because delays defeat the purpose of insurance.',
      'category': 'Claims',
    },
    {
      'question': 'How can I contact Rex Insurance if I need help?',
      'answer':
          'You can walk into any of our offices, call our customer care lines, send an email, or reach us on social media and our website. We\'re always available to support you before and after you buy your policy.',
      'category': 'Account',
    },
  ];

  List<Map<String, String>> get _filteredFaqs {
    final query = _searchController.text.toLowerCase().trim();
    var faqs = _faqs;
    if (_selectedFilter > 0) {
      faqs = faqs
          .where((f) => f['category'] == _filters[_selectedFilter])
          .toList();
    }
    if (query.isNotEmpty) {
      final words =
          query.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      faqs = faqs.where((f) {
        final text = '${f['question']} ${f['answer']}'.toLowerCase();
        return words.every((word) => text.contains(word));
      }).toList();
    }
    return faqs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faqs = _filteredFaqs;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('FAQ',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                  fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search help',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: ThemeHelper.getCardColor(context),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: ThemeHelper.getBorderColor(context))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: ThemeHelper.getBorderColor(context))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.primaryNavy)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedFilter = index;
                      _expandedIndex = -1;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryNavy
                            : ThemeHelper.getCardColor(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryNavy
                                : ThemeHelper.getBorderColor(context)),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : ThemeHelper.getSecondaryTextColor(context)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // FAQ list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faq = faqs[index];
                final isExpanded = _expandedIndex == index;
                return Column(
                  children: [
                    InkWell(
                      onTap: () => setState(
                          () => _expandedIndex = isExpanded ? -1 : index),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                faq['question']!,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                            ),
                            Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            faq['answer']!,
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    ThemeHelper.getSecondaryTextColor(context),
                                height: 1.5),
                          ),
                        ),
                      ),
                    Divider(color: Colors.grey[200], height: 1),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isAgentFlow
          ? null
          : Transform.translate(
              offset: const Offset(0, 15),
              child: SizedBox(
                width: 52,
                height: 52,
                child: FloatingActionButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NewPolicyScreen())),
                  backgroundColor: AppTheme.accentOrange,
                  shape: const CircleBorder(),
                  elevation: 1,
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: widget.isAgentFlow
          ? buildAgentBottomNav(context, currentIndex: 0)
          : BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 4,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_outlined, 'Home', false,
                        onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerDashboardScreen()),
                          (route) => false);
                    }),
                    _buildNavItem(
                        Icons.description_outlined, 'Policies', false),
                    const SizedBox(width: 48),
                    _buildNavItem(Icons.assignment_outlined, 'Claims', false,
                        onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyClaimsScreen()));
                    }),
                    _buildNavItem(Icons.person_outline, 'Profile', false,
                        onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerProfileScreen()));
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
        ],
      ),
    );
  }
}
