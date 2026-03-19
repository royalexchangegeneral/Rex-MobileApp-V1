import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class CategoryArticlesScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Map<String, String>> articles;

  const CategoryArticlesScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.articles,
  });

  factory CategoryArticlesScreen.policyBasics() => CategoryArticlesScreen(
    title: 'Policy Basics',
    icon: Icons.description_outlined,
    color: AppTheme.primaryNavy,
    articles: const [
      {'title': 'What is an Insurance Policy?', 'read': '5 min read', 'desc': 'Learn the fundamentals of insurance policies and how they protect you.', 'body': 'An insurance policy is a contract between you and an insurance company. You agree to pay a premium, and in return, the insurer agrees to cover certain financial losses. Policies outline what is covered, what is excluded, the duration of coverage, and the conditions under which claims can be made.\n\nInsurance policies exist to help individuals and businesses manage risk. Instead of bearing the full cost of an unexpected event, you share that risk with the insurer. This means if something goes wrong — like an accident, theft, or natural disaster — you are not left to handle the financial burden alone.\n\nEvery policy has key components: the premium (what you pay), the deductible (what you pay before coverage kicks in), the coverage limit (maximum the insurer will pay), and the terms and conditions that govern the agreement.'},
      {'title': 'Understanding Your Premium', 'read': '4 min read', 'desc': 'How premiums are calculated and what affects your cost.', 'body': 'Your insurance premium is the amount you pay regularly to keep your policy active. It can be paid monthly, quarterly, or annually depending on your agreement with the insurer.\n\nSeveral factors affect your premium: the type of coverage you choose, the value of what you are insuring, your risk profile, and your claims history. For example, a comprehensive motor insurance policy will cost more than a basic third-party cover because it offers wider protection.\n\nTo get the best value, compare different coverage options, ask about available discounts, and ensure you are not over-insured or under-insured. Rex Insurance works with your budget to find the right balance between cost and coverage.'},
      {'title': 'Policy Terms Explained', 'read': '6 min read', 'desc': 'Breaking down common insurance terms in simple language.', 'body': 'Insurance documents can seem complex, but understanding a few key terms makes everything clearer.\n\nPremium: The amount you pay for your insurance coverage.\nDeductible: The portion of a claim you pay out of pocket before the insurer covers the rest.\nCoverage Limit: The maximum amount the insurer will pay for a covered loss.\nExclusion: Specific situations or items not covered by your policy.\nEndorsement: An amendment or addition to your existing policy.\nBeneficiary: The person or entity who receives the insurance payout.\n\nAt Rex Insurance, we explain every term in plain language so you always know exactly what your policy covers and what to expect.'},
      {'title': 'How to Read Your Policy Document', 'read': '7 min read', 'desc': 'A step-by-step guide to understanding your policy document.', 'body': 'Your policy document is your contract with the insurer. Here is how to read it effectively:\n\n1. Declarations Page: This summary shows your name, policy number, coverage dates, premium amount, and coverage limits.\n\n2. Insuring Agreement: This section describes what the insurer promises to cover.\n\n3. Conditions: These are the rules you must follow to keep your coverage valid, such as paying premiums on time and reporting incidents promptly.\n\n4. Exclusions: Read this carefully — it lists what is NOT covered.\n\n5. Endorsements: Any changes or additions to the standard policy.\n\nTake your time reading each section. If anything is unclear, contact Rex Insurance and our team will walk you through it.'},
      {'title': 'Coverage vs Exclusions', 'read': '5 min read', 'desc': 'Know what is covered and what is not in your policy.', 'body': 'Every insurance policy has two important sections: what is covered and what is excluded.\n\nCoverage refers to the events, damages, or losses the insurer will pay for. For example, a motor insurance policy may cover accidents, theft, and fire damage.\n\nExclusions are specific situations the policy does not cover. Common exclusions include wear and tear, intentional damage, and losses from illegal activities.\n\nUnderstanding both helps you avoid surprises when making a claim. If you need coverage for something that is excluded, ask about adding an endorsement to your policy.'},
      {'title': 'Renewing Your Policy', 'read': '3 min read', 'desc': 'How and when to renew your insurance policy.', 'body': 'Insurance policies have a set duration, usually one year. When your policy is about to expire, you need to renew it to maintain coverage.\n\nRex Insurance sends renewal reminders before your policy expires. You can renew through our offices, licensed agents, or digital platforms. During renewal, you can also review and adjust your coverage based on any changes in your situation.\n\nDo not let your policy lapse — a gap in coverage means you are unprotected during that period.'},
      {'title': 'Policy Endorsements', 'read': '4 min read', 'desc': 'How to make changes to your existing policy.', 'body': 'An endorsement is a formal change to your insurance policy. You might need one if your circumstances change — for example, adding a new vehicle to your motor policy or increasing your coverage limit.\n\nTo request an endorsement, contact Rex Insurance with the details of the change you need. Our team will process the update and issue an amended policy document. Some endorsements may affect your premium, and we will explain any cost changes upfront.'},
      {'title': 'Choosing the Right Cover', 'read': '6 min read', 'desc': 'Tips for selecting the best insurance coverage for your needs.', 'body': 'Choosing the right insurance cover starts with understanding your risks. Ask yourself: What do I need to protect? What would happen financially if something went wrong?\n\nConsider the value of your assets, your budget for premiums, and the level of risk you face. A business owner with a fleet of vehicles has different needs than someone insuring a single car.\n\nRex Insurance helps you assess your situation and recommends customized coverage. We do not believe in one-size-fits-all — your policy should match your actual needs and lifestyle.'},
    ],
  );

  factory CategoryArticlesScreen.claimsGuide() => CategoryArticlesScreen(
    title: 'Claims Guide',
    icon: Icons.assignment_outlined,
    color: AppTheme.accentOrange,
    articles: const [
      {'title': 'How to File a Claim', 'read': '5 min read', 'desc': 'Step-by-step process for filing your insurance claim.', 'body': 'Filing a claim with Rex Insurance is straightforward:\n\n1. Report the incident to us as soon as possible. You can call, visit our office, or use the app.\n\n2. Fill out the claim form with accurate details about what happened.\n\n3. Attach supporting documents such as police reports, photos of damage, receipts, or medical reports.\n\n4. Submit your claim and receive a reference number for tracking.\n\nOur claims team will guide you through each step to ensure nothing is missed. The sooner you report, the faster we can process your claim.'},
      {'title': 'Documents You Need for a Claim', 'read': '4 min read', 'desc': 'Essential documents required when making a claim.', 'body': 'Having the right documents ready speeds up your claim. Depending on the type of claim, you may need:\n\n- Completed claim form\n- Copy of your insurance policy\n- Police report (for theft or accidents)\n- Photos or videos of the damage\n- Repair estimates or invoices\n- Medical reports (for personal injury claims)\n- Proof of ownership for damaged items\n\nRex Insurance will tell you exactly what is needed for your specific claim type. Keep copies of all documents for your records.'},
      {'title': 'The Claims Assessment Process', 'read': '6 min read', 'desc': 'What happens after you submit your claim.', 'body': 'After you submit your claim, our team begins the assessment process:\n\n1. Acknowledgement: We confirm receipt of your claim and assign a claims handler.\n\n2. Investigation: We review the documents, may inspect the damage, and verify the details.\n\n3. Evaluation: We determine the claim amount based on your policy coverage and the extent of the loss.\n\n4. Decision: Your claim is either approved, partially approved, or declined with a clear explanation.\n\n5. Settlement: Approved claims are paid out as quickly as possible.\n\nThroughout this process, you can contact us for updates on your claim status.'},
      {'title': 'Claim Settlement Timeline', 'read': '3 min read', 'desc': 'How long it takes to process and settle your claim.', 'body': 'The time it takes to settle a claim depends on the complexity of the case and how quickly all required documents are submitted.\n\nSimple claims with complete documentation can be processed within a few business days. More complex claims involving investigations or third parties may take longer.\n\nRex Insurance is committed to prompt claims settlement. We process valid claims as quickly as possible because we understand that delays defeat the purpose of insurance.'},
      {'title': 'Common Claim Mistakes to Avoid', 'read': '5 min read', 'desc': 'Avoid these errors to ensure a smooth claims experience.', 'body': 'Avoid these common mistakes when filing a claim:\n\n- Delaying your report: Notify us as soon as possible after an incident.\n- Incomplete documentation: Submit all required documents to avoid delays.\n- Inaccurate information: Provide truthful and accurate details.\n- Not reading your policy: Know what is covered before filing.\n- Disposing of evidence: Keep damaged items and photos until the claim is settled.\n\nFollowing these guidelines helps ensure your claim is processed smoothly and quickly.'},
      {'title': 'Tracking Your Claim Status', 'read': '3 min read', 'desc': 'How to monitor the progress of your claim.', 'body': 'Once your claim is submitted, you can track its progress through several channels:\n\n- Call our customer care line for updates\n- Visit any Rex Insurance office\n- Use the Rex Insurance app to check your claim status\n\nYour claims reference number is your key to getting updates. Keep it safe and use it whenever you contact us about your claim.'},
    ],
  );

  factory CategoryArticlesScreen.motorInsurance() => CategoryArticlesScreen(
    title: 'Motor Insurance',
    icon: Icons.directions_car_outlined,
    color: const Color(0xFF4A90D9),
    articles: const [
      {'title': 'Third-Party Motor Insurance', 'read': '5 min read', 'desc': 'Understanding the basics of third-party vehicle coverage.', 'body': 'Third-party motor insurance is the minimum legal requirement for vehicle owners in Nigeria. It covers damage or injury you cause to other people, their vehicles, or their property in an accident.\n\nThis policy does not cover damage to your own vehicle. It is the most affordable option and is suitable for those who want basic legal compliance.\n\nIf you cause an accident, the insurer pays the third party for their losses, protecting you from potentially large out-of-pocket expenses.'},
      {'title': 'Comprehensive Motor Cover', 'read': '6 min read', 'desc': 'Full protection for your vehicle against all risks.', 'body': 'Comprehensive motor insurance provides the widest level of protection for your vehicle. It covers:\n\n- Damage to your own vehicle from accidents\n- Theft of your vehicle\n- Fire damage\n- Third-party liability (injury or damage to others)\n- Natural disasters and flooding\n\nWhile it costs more than third-party cover, comprehensive insurance gives you peace of mind knowing your vehicle is fully protected against a wide range of risks.'},
      {'title': 'What to Do After an Accident', 'read': '4 min read', 'desc': 'Immediate steps to take following a road accident.', 'body': 'If you are involved in a road accident:\n\n1. Ensure everyone is safe. Call emergency services if anyone is injured.\n2. Do not move the vehicles unless they are blocking traffic dangerously.\n3. Take photos of the scene, damage to all vehicles, and any injuries.\n4. Exchange information with the other driver (name, phone, insurance details).\n5. File a police report at the nearest station.\n6. Notify Rex Insurance as soon as possible with all the details.\n\nDo not admit fault at the scene. Let the insurance companies and authorities determine liability.'},
      {'title': 'Fleet Insurance for Businesses', 'read': '5 min read', 'desc': 'Covering multiple vehicles under one policy.', 'body': 'Fleet insurance is designed for businesses that operate multiple vehicles. Instead of managing separate policies for each vehicle, fleet insurance covers all of them under a single policy.\n\nBenefits include simplified administration, potential cost savings, and consistent coverage across your entire fleet. Whether you have delivery vans, company cars, or heavy-duty trucks, Rex Insurance can tailor a fleet policy to your business needs.'},
      {'title': 'Motor Insurance Renewal Tips', 'read': '3 min read', 'desc': 'How to get the best deal when renewing your motor policy.', 'body': 'When renewing your motor insurance:\n\n- Review your current coverage to ensure it still meets your needs\n- Update the insured value of your vehicle to reflect its current market value\n- Check if you qualify for a no-claims discount\n- Compare third-party vs comprehensive options\n- Renew before your policy expires to avoid a coverage gap\n\nRex Insurance makes renewal easy through our offices, agents, and digital platforms.'},
    ],
  );

  factory CategoryArticlesScreen.propertyCover() => CategoryArticlesScreen(
    title: 'Property Cover',
    icon: Icons.home_outlined,
    color: const Color(0xFFE91E63),
    articles: const [
      {'title': 'Home Insurance Basics', 'read': '5 min read', 'desc': 'Protecting your home from fire, theft and natural disasters.', 'body': 'Home insurance protects your most valuable asset — your home. It covers damage or loss caused by events such as fire, theft, flooding, and storms.\n\nA standard home insurance policy covers the structure of your building and can be extended to include the contents inside. This means your furniture, electronics, and personal belongings can also be protected.\n\nWhether you own or rent, home insurance gives you financial security if the unexpected happens.'},
      {'title': 'Office & Business Property Cover', 'read': '6 min read', 'desc': 'Insurance solutions for your business premises and equipment.', 'body': 'Business property insurance protects your office, shop, warehouse, or factory against damage and loss. Coverage typically includes:\n\n- Building structure damage from fire, flood, or storms\n- Equipment and machinery breakdown\n- Stock and inventory loss\n- Business interruption (loss of income while repairs are made)\n\nFor business owners, property insurance is essential. A single incident can cause significant financial loss, and having the right cover ensures your business can recover quickly.'},
      {'title': 'Valuables & Contents Insurance', 'read': '4 min read', 'desc': 'Covering your personal belongings inside your property.', 'body': 'Contents insurance covers the items inside your home or office — furniture, electronics, clothing, jewellery, and other personal belongings.\n\nIf your belongings are damaged, destroyed, or stolen, contents insurance helps you replace them without bearing the full cost yourself.\n\nWhen taking out contents insurance, make an inventory of your valuable items and their estimated replacement cost. This helps ensure you have adequate coverage.'},
      {'title': 'Property Insurance Claims', 'read': '5 min read', 'desc': 'How to file a claim for property damage or loss.', 'body': 'If your property is damaged or you experience a loss:\n\n1. Secure the property to prevent further damage if safe to do so.\n2. Document the damage with photos and videos.\n3. File a police report if theft or vandalism is involved.\n4. Contact Rex Insurance to report the incident and start your claim.\n5. Submit the claim form along with supporting documents.\n\nOur team will arrange an assessment and guide you through the process to ensure a smooth and timely settlement.'},
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text('${articles.length} articles', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('All Articles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 14),
            ...List.generate(articles.length, (index) {
              final article = articles[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index < articles.length - 1 ? 12 : 0),
                child: _buildArticleCard(context, article, index),
              );
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 50,
        height: 50,
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
          backgroundColor: AppTheme.accentOrange,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false, onTap: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (route) => false);
              }),
              _buildNavItem(Icons.description_outlined, 'Policies', false),
              const SizedBox(width: 40),
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

  Widget _buildArticleCard(BuildContext context, Map<String, String> article, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ArticleDetailScreen(
        articles: articles,
        initialIndex: index,
        color: color,
      ))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(Icons.article_outlined, color: color, size: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article['title']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 3),
                  Text(article['desc']!, style: TextStyle(fontSize: 10, color: Colors.grey[500], height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(article['read']!, style: TextStyle(fontSize: 9, color: Colors.grey[400])),
          ],
        ),
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

class _ArticleDetailScreen extends StatefulWidget {
  final List<Map<String, String>> articles;
  final int initialIndex;
  final Color color;

  const _ArticleDetailScreen({
    required this.articles,
    required this.initialIndex,
    required this.color,
  });

  @override
  State<_ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<_ArticleDetailScreen> {
  late int _currentIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() => _currentIndex = index);
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.articles[_currentIndex];
    final color = widget.color;
    final hasPrev = _currentIndex > 0;
    final hasNext = _currentIndex < widget.articles.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${_currentIndex + 1} of ${widget.articles.length}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(article['read']!, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Text(article['title']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(article['body']!, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.7)),
            ),
            const SizedBox(height: 24),

            // Prev / Next navigation
            Row(
              children: [
                if (hasPrev)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _goTo(_currentIndex - 1),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back_ios, size: 14, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Previous', style: TextStyle(fontSize: 9, color: Colors.grey[400])),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.articles[_currentIndex - 1]['title']!,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (hasPrev && hasNext) const SizedBox(width: 10),
                if (hasNext)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _goTo(_currentIndex + 1),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Next', style: TextStyle(fontSize: 9, color: Colors.grey[400])),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.articles[_currentIndex + 1]['title']!,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, size: 14, color: color),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
