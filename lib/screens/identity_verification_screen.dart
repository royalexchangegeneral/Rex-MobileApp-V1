import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  String _selectedIdType = 'NIN';

  final List<Map<String, String>> _idTypes = [
    {'type': 'BVN', 'icon': 'assets/icons/bvn.svg'},
    {'type': 'NIN', 'icon': 'assets/icons/bvn.svg'},
    {'type': 'Passport', 'icon': 'assets/icons/passport.svg'},
    {'type': "Driver's license", 'icon': 'assets/icons/bvn.svg'},
  ];

  void _continue() {
    switch (_selectedIdType) {
      case 'BVN':
        Navigator.pushNamed(context, '/enter-bvn');
        break;
      case 'NIN':
        Navigator.pushNamed(context, '/enter-nin');
        break;
      case 'Passport':
        Navigator.pushNamed(context, '/enter-passport');
        break;
      case "Driver's license":
        Navigator.pushNamed(context, '/enter-drivers-license');
        break;
    }
  }

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
        title: const Text(
          'Identity Verification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              
              // Illustration
              Center(
                child: SvgPicture.asset(
                  'assets/icons/top.svg',
                  width: 110,
                  height: 110,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Before you continue, we need to finish your KYC.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'To ensure the security of your account and protect against fraud, we require you to complete our identity verification process',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Select ID type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // ID Type Options
              ...List.generate(_idTypes.length, (index) {
                final idType = _idTypes[index];
                final isSelected = _selectedIdType == idType['type'];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIdType = idType['type']!;
                      });
                      // Navigate immediately when clicked
                      _continue();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: SvgPicture.asset(
                              idType['icon']!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              idType['type']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryBlue : Colors.grey[400]!,
                                width: 2,
                              ),
                              color: isSelected ? AppTheme.primaryBlue : Colors.white,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 16),
              
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create-password');
                  },
                  child: Text(
                    'Skip, I will do this later',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
