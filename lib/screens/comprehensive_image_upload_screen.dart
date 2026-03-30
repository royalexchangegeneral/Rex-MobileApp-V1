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

  const ComprehensiveImageUploadScreen({super.key, required this.vehicleType, required this.sumInsured, required this.premium, required this.regNumber, this.personalInfo = const {}, this.vehicleData = const {}});
  @override
  State<ComprehensiveImageUploadScreen> createState() => _ComprehensiveImageUploadScreenState();
}

class _ComprehensiveImageUploadScreenState extends State<ComprehensiveImageUploadScreen> {
  final List<XFile> _uploadedFiles = [];
  final ImagePicker _picker = ImagePicker();
  final List<String> _labels = ['Front View', 'Right Side', 'Left Side', 'Back View', 'Dashboard'];

  Future<void> _pickImage() async {
    if (_uploadedFiles.length >= 5) return;
    
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    
    if (source == null) return;
    
    final image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setState(() => _uploadedFiles.add(image));
    }
  }

  void _removeFile(int index) => setState(() => _uploadedFiles.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(widget.vehicleType, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
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
                    Text('Step 3 of 5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                    Spacer(),
                    Text('image upload', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: List.generate(5, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: i < 4 ? 4 : 0), decoration: BoxDecoration(color: i < 3 ? AppTheme.primaryNavy : Colors.grey[300], borderRadius: BorderRadius.circular(2)))))),
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
                    decoration: BoxDecoration(color: const Color(0xFFF3F8FF), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [Icon(Icons.lightbulb_outline, color: AppTheme.primaryNavy, size: 16), SizedBox(width: 6), Text('Upload Tips:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black))]),
                        const SizedBox(height: 10),
                        _buildTip('Take pictures in daylight for better clarity and good lighting'),
                        const SizedBox(height: 6),
                        _buildTip('Avoid glare or shadows covering details'),
                        const SizedBox(height: 6),
                        _buildTip('Make sure vehicle is clean and plates readable'),
                        const SizedBox(height: 6),
                        RichText(text: const TextSpan(style: TextStyle(fontSize: 10, color: Colors.black87, height: 1.4), children: [
                          TextSpan(text: '• Required Photo Angles: - '),
                          TextSpan(text: 'Front View ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: '(Make sure the number plate is clearly visible)', style: TextStyle(fontStyle: FontStyle.italic)),
                          TextSpan(text: ', '),
                          TextSpan(text: 'Left and Right side View', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: ', '),
                          TextSpan(text: 'Back View ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: '(Ensure the rear of the car is fully visible)', style: TextStyle(fontStyle: FontStyle.italic)),
                          TextSpan(text: ' '),
                          TextSpan(text: 'Dashboard View ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: '(Take a clear photo of the dashboard)', style: TextStyle(fontStyle: FontStyle.italic)),
                        ])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Upload a file (upload 4 images of the vehicle)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _pickImage(),
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.cloud_upload_outlined, size: 30, color: Colors.grey[400]),
                        const SizedBox(height: 6),
                        Text('Drop your files here', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        RichText(text: TextSpan(style: TextStyle(fontSize: 10, color: Colors.grey[600]), children: const [TextSpan(text: 'Browse file', style: TextStyle(color: AppTheme.primaryNavy, decoration: TextDecoration.underline)), TextSpan(text: ' from your phone')])),
                      ])),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_uploadedFiles.length, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!, width: 0.5), borderRadius: BorderRadius.circular(6)),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(File(_uploadedFiles[i].path), width: 36, height: 36, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(i < _labels.length ? _labels[i] : 'Image ${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black)),
                            Text(_uploadedFiles[i].name, style: TextStyle(fontSize: 9, color: Colors.grey[500]), overflow: TextOverflow.ellipsis),
                          ],
                        )),
                        IconButton(icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 16), onPressed: () => _removeFile(i), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ]),
                    ),
                  )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _uploadedFiles.length >= 4 ? () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => ComprehensiveNinScreen(vehicleType: widget.vehicleType, sumInsured: widget.sumInsured, premium: widget.premium, regNumber: widget.regNumber, personalInfo: widget.personalInfo, vehicleData: widget.vehicleData))) : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), disabledBackgroundColor: Colors.grey[300]),
                child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontSize: 12, color: Colors.black87)), Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)))]);
}
