import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'comprehensive_nin_screen.dart';

class ComprehensiveImageUploadScreen extends StatefulWidget {
  final String vehicleType;
  final String sumInsured;
  final String premium;
  final String regNumber;

  const ComprehensiveImageUploadScreen({super.key, required this.vehicleType, required this.sumInsured, required this.premium, required this.regNumber});
  @override
  State<ComprehensiveImageUploadScreen> createState() => _ComprehensiveImageUploadScreenState();
}

class _ComprehensiveImageUploadScreenState extends State<ComprehensiveImageUploadScreen> {
  final List<String> _uploadedFiles = [];

  void _addFile(String fileName) {
    if (_uploadedFiles.length < 5) setState(() => _uploadedFiles.add(fileName));
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
      body: Column(
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
          Expanded(
            child: SingleChildScrollView(
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
                        const Row(children: [Icon(Icons.lightbulb_outline, color: AppTheme.primaryNavy, size: 20), SizedBox(width: 8), Text('Upload Tips:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black))]),
                        const SizedBox(height: 12),
                        _buildTip('Take pictures in daylight for better clarity and good lighting'),
                        const SizedBox(height: 8),
                        _buildTip('Avoid glare or shadows covering details'),
                        const SizedBox(height: 8),
                        _buildTip('Make sure vehicle is clean and plates readable'),
                        const SizedBox(height: 8),
                        RichText(text: const TextSpan(style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4), children: [
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
                  Text('Upload a file (upload 4 images of the vehicle)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      if (_uploadedFiles.length < 5) _addFile('${['Front-view', 'Right_view', 'Side_view', 'Back_view', 'Dashboard_view'][_uploadedFiles.length]}.jpg');
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('Drop your files here', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        RichText(text: TextSpan(style: TextStyle(fontSize: 12, color: Colors.grey[600]), children: const [TextSpan(text: 'Browse file', style: TextStyle(color: AppTheme.primaryNavy, decoration: TextDecoration.underline)), TextSpan(text: ' from your phone')])),
                      ])),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_uploadedFiles.length, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        Expanded(child: Text(_uploadedFiles[i], style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
                        IconButton(icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20), onPressed: () => _removeFile(i), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ]),
                    ),
                  )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _uploadedFiles.length >= 4 ? () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => ComprehensiveNinScreen(vehicleType: widget.vehicleType, sumInsured: widget.sumInsured, premium: widget.premium, regNumber: widget.regNumber))) : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), disabledBackgroundColor: Colors.grey[300]),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontSize: 12, color: Colors.black87)), Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)))]);
}
