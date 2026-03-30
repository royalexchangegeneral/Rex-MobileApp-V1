import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/app_theme.dart';
import 'comprehensive_summary_screen.dart';

class ComprehensiveNinScreen extends StatefulWidget {
  final String vehicleType;
  final String sumInsured;
  final String premium;
  final String regNumber;
  final Map<String, String> personalInfo;
  final Map<String, dynamic> vehicleData;

  const ComprehensiveNinScreen({super.key, required this.vehicleType, required this.sumInsured, required this.premium, required this.regNumber, this.personalInfo = const {}, this.vehicleData = const {}});
  @override
  State<ComprehensiveNinScreen> createState() => _ComprehensiveNinScreenState();
}

class _ComprehensiveNinScreenState extends State<ComprehensiveNinScreen> {
  final _ninController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;
  XFile? _uploadedFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickNinImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source == null) return;
    final image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image != null) setState(() => _uploadedFile = image);
  }

  @override
  void dispose() {
    _ninController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_ninController.text.isEmpty) return;
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _isVerifying = false; _isVerified = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('NIN', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
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
                    Text('Step 4 of 5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                    Spacer(),
                    Text('Identification', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: List.generate(5, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: i < 4 ? 4 : 0), decoration: BoxDecoration(color: i < 4 ? AppTheme.primaryNavy : Colors.grey[300], borderRadius: BorderRadius.circular(2)))))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter your NIN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ninController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    decoration: InputDecoration(hintText: 'enter nin', hintStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: OutlinedButton(
                    onPressed: _isVerifying ? null : _handleVerify,
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryNavy, side: const BorderSide(color: AppTheme.primaryNavy), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: _isVerifying ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_isVerified ? 'Verified ✓' : 'Verify', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  )),
                  const SizedBox(height: 24),
                  const Center(child: Text('OR', style: TextStyle(fontSize: 14, color: Colors.grey))),
                  const SizedBox(height: 24),
                  const Text('Upload NIN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _pickNinImage(),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey[400]),
                        const SizedBox(height: 4),
                        Text('JPEG, PNG, PDF 2MB', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        RichText(text: TextSpan(style: TextStyle(fontSize: 12, color: Colors.grey[600]), children: const [TextSpan(text: 'Browse file', style: TextStyle(color: AppTheme.primaryNavy, decoration: TextDecoration.underline)), TextSpan(text: ' from your phone')])),
                      ])),
                    ),
                  ),
                  if (_uploadedFile != null) ...[
                    const SizedBox(height: 12),
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)), child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(File(_uploadedFile!.path), width: 40, height: 40, fit: BoxFit.cover)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('NIN Document', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                        Text(_uploadedFile!.name, style: TextStyle(fontSize: 9, color: Colors.grey[500]), overflow: TextOverflow.ellipsis),
                      ])),
                      IconButton(icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20), onPressed: () => setState(() => _uploadedFile = null), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    ])),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: (_isVerified || _uploadedFile != null) ? () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => ComprehensiveSummaryScreen(vehicleType: widget.vehicleType, sumInsured: widget.sumInsured, premium: widget.premium, regNumber: widget.regNumber, personalInfo: widget.personalInfo, vehicleData: widget.vehicleData))) : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), disabledBackgroundColor: Colors.grey[300]),
                child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
