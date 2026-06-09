import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/app_theme.dart';
import 'comprehensive_nin_screen.dart';

class ComprehensiveImageUploadScreen extends StatefulWidget {
  final String vehicleType;
  final String sumInsured;
  final String premium;
  final String regNumber;
  final Map<String, String> personalInfo;
  final Map<String, dynamic> vehicleData;
  final bool isLoggedIn;
  final bool isAgent;

  const ComprehensiveImageUploadScreen(
      {super.key,
      required this.vehicleType,
      required this.sumInsured,
      required this.premium,
      required this.regNumber,
      this.personalInfo = const {},
      this.vehicleData = const {},
      this.isLoggedIn = false,
      this.isAgent = false});
  @override
  State<ComprehensiveImageUploadScreen> createState() =>
      _ComprehensiveImageUploadScreenState();
}

class _ComprehensiveImageUploadScreenState
    extends State<ComprehensiveImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  // 5 pre-loss photos mapped to API fields:
  // idtypec = Pre-loss photo 1 (Front View)
  // idtyped = Pre-loss photo 2 (Right Side)
  // idtypee = Pre-loss photo 3 (Left Side)
  // idtypef = Pre-loss photo 4 (Back View)
  // idtypeg = Pre-loss photo 5 (Dashboard)
  File? _preLoss1;
  File? _preLoss2;
  File? _preLoss3;
  File? _preLoss4;
  File? _preLoss5;

  Future<void> _pickFor(String field) async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ]),
        ),
      );
      if (source == null) return;
      final image = await _picker.pickImage(
          source: source, maxWidth: 1024, imageQuality: 80);
      if (image != null) {
        final file = File(image.path);
        setState(() {
          switch (field) {
            case 'preLoss1':
              _preLoss1 = file;
            case 'preLoss2':
              _preLoss2 = file;
            case 'preLoss3':
              _preLoss3 = file;
            case 'preLoss4':
              _preLoss4 = file;
            case 'preLoss5':
              _preLoss5 = file;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  bool get _allRequiredUploaded =>
      _preLoss1 != null &&
      _preLoss2 != null &&
      _preLoss3 != null &&
      _preLoss4 != null &&
      _preLoss5 != null;

  List<File> get _imageFiles => [
        if (_preLoss1 != null) _preLoss1!,
        if (_preLoss2 != null) _preLoss2!,
        if (_preLoss3 != null) _preLoss3!,
        if (_preLoss4 != null) _preLoss4!,
        if (_preLoss5 != null) _preLoss5!,
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final infoColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F8FF);
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final inactiveTrackColor =
        isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text(widget.vehicleType,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Text('Step 3 of 5',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                    Spacer(),
                    Text('Image Upload',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                      children: List.generate(
                          5,
                          (i) => Expanded(
                              child: Container(
                                  height: 4,
                                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                                  decoration: BoxDecoration(
                                      color: i < 3
                                          ? AppTheme.primaryNavy
                                          : inactiveTrackColor,
                                      borderRadius:
                                          BorderRadius.circular(2)))))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: infoColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.lightbulb_outline,
                              color: AppTheme.primaryNavy, size: 16),
                          const SizedBox(width: 6),
                          Text('Upload Tips:',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface))
                        ]),
                        const SizedBox(height: 10),
                        _buildTip(
                            'Take pictures in daylight for better clarity'),
                        const SizedBox(height: 4),
                        _buildTip('Avoid glare or shadows covering details'),
                        const SizedBox(height: 4),
                        _buildTip(
                            'Make sure vehicle is clean and plates readable'),
                        const SizedBox(height: 4),
                        _buildTip('Max file size: 2.5MB per image (JPEG/PNG)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Pre-loss Photos (5 required)',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  _uploadRow(
                      'Front View *', _preLoss1, () => _pickFor('preLoss1'),
                      cardColor: cardColor,
                      borderColor: borderColor,
                      labelColor: secondaryTextColor),
                  const SizedBox(height: 10),
                  _uploadRow('Right Side View *', _preLoss2,
                      () => _pickFor('preLoss2'),
                      cardColor: cardColor,
                      borderColor: borderColor,
                      labelColor: secondaryTextColor),
                  const SizedBox(height: 10),
                  _uploadRow(
                      'Left Side View *', _preLoss3, () => _pickFor('preLoss3'),
                      cardColor: cardColor,
                      borderColor: borderColor,
                      labelColor: secondaryTextColor),
                  const SizedBox(height: 10),
                  _uploadRow(
                      'Back View *', _preLoss4, () => _pickFor('preLoss4'),
                      cardColor: cardColor,
                      borderColor: borderColor,
                      labelColor: secondaryTextColor),
                  const SizedBox(height: 10),
                  _uploadRow(
                      'Dashboard View *', _preLoss5, () => _pickFor('preLoss5'),
                      cardColor: cardColor,
                      borderColor: borderColor,
                      labelColor: secondaryTextColor),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 24, 24, 32 + MediaQuery.of(context).padding.bottom),
              child: Column(children: [
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _allRequiredUploaded
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ComprehensiveNinScreen(
                                            vehicleType: widget.vehicleType,
                                            sumInsured: widget.sumInsured,
                                            premium: widget.premium,
                                            regNumber: widget.regNumber,
                                            personalInfo: widget.personalInfo,
                                            vehicleData: widget.vehicleData,
                                            imageFiles: _imageFiles,
                                            isLoggedIn: widget.isLoggedIn,
                                            isAgent: widget.isAgent,
                                          )));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.accentOrange
                                  : AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          disabledBackgroundColor:
                              AppTheme.disabledButtonColor(context),
                          disabledForegroundColor:
                              AppTheme.disabledButtonTextColor(context)),
                      child: const Text('Continue',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    )),
                const SizedBox(height: 12),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : AppTheme.primaryNavy,
                          side: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppTheme.primaryNavy),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text('Back',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    )),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadRow(
    String label,
    File? file,
    VoidCallback onTap, {
    required Color cardColor,
    required Color borderColor,
    required Color labelColor,
  }) {
    final isUploaded = file != null;
    final uploadedBackground = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF052E16)
        : Colors.green[50]!;
    final uploadedBorder = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF22C55E)
        : Colors.green;
    final uploadedText = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF86EFAC)
        : Colors.green[800]!;

    return Row(children: [
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: isUploaded ? uploadedBorder : borderColor),
            color: isUploaded ? uploadedBackground : cardColor),
        child: Text(isUploaded ? '✓ $label' : label,
            style: TextStyle(
                fontSize: 12, color: isUploaded ? uploadedText : labelColor)),
      )),
      const SizedBox(width: 8),
      GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.accentOrange
                    : AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.upload_file, color: Colors.white, size: 20),
          )),
    ]);
  }

  Widget _buildTip(String text) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('• ',
            style: TextStyle(
                fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4)))
      ]);
}
