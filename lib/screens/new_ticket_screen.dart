import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class NewTicketScreen extends StatefulWidget {
  final String? initialCategory;
  const NewTicketScreen({super.key, this.initialCategory});
  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  String? _selectedCategory;
  final _policyController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _attachments = [];
  final _categories = ['Policy Information', 'Claims', 'Service Request', 'Complaint', 'Policy Endorsement', 'Policy Certificate', 'Policy Confirmation', 'Policy Verification', 'No Claim Document', 'No Claim Verification', 'Request for brown card', 'Staff/Agent Information', 'Renewal Enquiries', 'Product Enquiries', 'Online Payment Issues', 'Duplicate Transactions', 'NIID Upload & Correction', 'Delayed Claim Payment', 'VIS Issue', 'Claim Notification', 'Claim Updates'];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) _selectedCategory = widget.initialCategory;
  }

  Future<void> _pickFile() async {
    final src = await showModalBottomSheet<ImageSource>(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
      ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
    ])));
    if (src == null) return;
    final f = await _picker.pickImage(source: src, imageQuality: 80);
    if (f != null) setState(() => _attachments.add(f));
  }

  @override
  void dispose() { _policyController.dispose(); _titleController.dispose(); _descController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('New Ticket', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.black), onPressed: () {})]),
      body: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Request Details card
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Request Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
              const SizedBox(height: 6),
              Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonFormField<String>(value: _selectedCategory, hint: Text('Select category', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v))),
              const SizedBox(height: 14),
              const Text('Policy Number (optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
              const SizedBox(height: 6),
              _field(_policyController, 'enter your policy number'),
              const SizedBox(height: 14),
              const Text('Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
              const SizedBox(height: 6),
              _field(_titleController, 'enter the title of your complaint'),
              const SizedBox(height: 14),
              const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
              const SizedBox(height: 6),
              _field(_descController, 'Provide detailed information about your request', lines: 4),
            ])),
          const SizedBox(height: 20),
          // Attachments card
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Attachments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 14),
              InkWell(onTap: _pickFile, child: Container(height: 100, decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.cloud_upload_outlined, size: 30, color: Colors.grey[400]),
                  const SizedBox(height: 4),
                  const Text('Drag and drop files here or', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  const Text('Browse Files', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text('Max file size: 10MB', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                ])))),
              const SizedBox(height: 10),
              ...List.generate(_attachments.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Icon(Icons.attach_file, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_attachments[i].name, style: TextStyle(fontSize: 12, color: Colors.grey[700]), overflow: TextOverflow.ellipsis)),
                  IconButton(icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 18), onPressed: () => setState(() => _attachments.removeAt(i)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ]))),
            ])),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket submitted successfully'), backgroundColor: Colors.green)); },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Submit request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
          const SizedBox(height: 80),
        ])),
      floatingActionButton: SizedBox(width: 50, height: 50, child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
        backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(), child: const Icon(Icons.add, color: Colors.white, size: 24))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(shape: const CircularNotchedRectangle(), notchMargin: 6,
        child: SizedBox(height: 50, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _nav(Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
          _nav(Icons.description_outlined, 'Policies', false, null), const SizedBox(width: 40),
          _nav(Icons.assignment_outlined, 'Claims', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
          _nav(Icons.person_outline, 'Profile', true, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
        ]))),
    );
  }

  Widget _field(TextEditingController c, String h, {int lines = 1}) => TextField(controller: c, maxLines: lines,
    style: const TextStyle(color: Colors.black, fontSize: 13),
    decoration: InputDecoration(hintText: h, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13), filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)));

  Widget _nav(IconData i, String l, bool s, VoidCallback? o) => InkWell(onTap: o, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(i, color: s ? AppTheme.primaryNavy : Colors.grey, size: 20), Text(l, style: TextStyle(fontSize: 10, color: s ? AppTheme.primaryNavy : Colors.grey))]));
}
