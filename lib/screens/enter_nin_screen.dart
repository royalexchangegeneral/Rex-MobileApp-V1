import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/explore_kyc_flow.dart';

class EnterNinScreen extends StatefulWidget {
  const EnterNinScreen({super.key});

  @override
  State<EnterNinScreen> createState() => _EnterNinScreenState();
}

class _EnterNinScreenState extends State<EnterNinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ninController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isVerifying = false;
  bool _hasAttemptedVerification = false;
  bool _verificationSucceeded = false;
  bool _didSkipNin = false;
  bool _nameMismatchAcknowledged = false;
  String? _verifiedFirstName;
  String? _verifiedLastName;
  String? _selectedState;
  String? _selectedLga;

  static const Map<String, List<String>> _stateLgas = {
    'Abia': [
      'Aba North',
      'Aba South',
      'Arochukwu',
      'Bende',
      'Isiala Ngwa North',
      'Isiala Ngwa South',
      'Umuahia North',
      'Umuahia South'
    ],
    'Adamawa': [
      'Demsa',
      'Fufore',
      'Girei',
      'Mubi North',
      'Mubi South',
      'Numan',
      'Yola North',
      'Yola South'
    ],
    'Akwa Ibom': ['Eket', 'Etinan', 'Ikot Ekpene', 'Oron', 'Uyo'],
    'Anambra': [
      'Aguata',
      'Awka North',
      'Awka South',
      'Nnewi North',
      'Nnewi South',
      'Onitsha North',
      'Onitsha South'
    ],
    'Bauchi': ['Bauchi', 'Dass', 'Katagum', 'Misau', 'Ningi', 'Tafawa Balewa'],
    'Bayelsa': [
      'Brass',
      'Ekeremor',
      'Nembe',
      'Ogbia',
      'Sagbama',
      'Southern Ijaw',
      'Yenagoa'
    ],
    'Benue': ['Gboko', 'Guma', 'Katsina-Ala', 'Makurdi', 'Otukpo', 'Vandeikya'],
    'Borno': ['Bama', 'Biu', 'Dikwa', 'Jere', 'Konduga', 'Maiduguri'],
    'Cross River': [
      'Akamkpa',
      'Calabar Municipal',
      'Calabar South',
      'Ikom',
      'Obudu',
      'Ogoja'
    ],
    'Delta': [
      'Aniocha North',
      'Ethiope East',
      'Ika North East',
      'Oshimili South',
      'Sapele',
      'Ughelli North',
      'Warri South'
    ],
    'Ebonyi': [
      'Abakaliki',
      'Afikpo North',
      'Afikpo South',
      'Ebonyi',
      'Ezza North',
      'Ikwo'
    ],
    'Edo': [
      'Egor',
      'Esan Central',
      'Esan West',
      'Ikpoba-Okha',
      'Oredo',
      'Uhunmwonde'
    ],
    'Ekiti': [
      'Ado Ekiti',
      'Ekiti East',
      'Ekiti South-West',
      'Ikere',
      'Irepodun/Ifelodun',
      'Oye'
    ],
    'Enugu': [
      'Enugu East',
      'Enugu North',
      'Enugu South',
      'Nsukka',
      'Oji River',
      'Udi'
    ],
    'FCT': [
      'Abaji',
      'Bwari',
      'Gwagwalada',
      'Kuje',
      'Kwali',
      'Municipal Area Council'
    ],
    'Gombe': ['Akko', 'Balanga', 'Billiri', 'Dukku', 'Gombe', 'Kaltungo'],
    'Imo': [
      'Ikeduru',
      'Mbaitoli',
      'Ngor Okpala',
      'Orlu',
      'Orsu',
      'Owerri Municipal',
      'Owerri North',
      'Owerri West'
    ],
    'Jigawa': ['Birnin Kudu', 'Dutse', 'Gumel', 'Hadejia', 'Kazaure'],
    'Kaduna': [
      'Chikun',
      'Igabi',
      'Kaduna North',
      'Kaduna South',
      'Kafanchan',
      'Zaria'
    ],
    'Kano': [
      'Dala',
      'Fagge',
      'Gwale',
      'Kano Municipal',
      'Nassarawa',
      'Tarauni',
      'Ungogo'
    ],
    'Katsina': ['Daura', 'Dutsin-Ma', 'Funtua', 'Katsina', 'Malumfashi'],
    'Kebbi': ['Argungu', 'Birnin Kebbi', 'Jega', 'Koko/Besse', 'Yauri'],
    'Kogi': ['Adavi', 'Ajaokuta', 'Idah', 'Kabba/Bunu', 'Lokoja', 'Okene'],
    'Kwara': [
      'Asa',
      'Ilorin East',
      'Ilorin South',
      'Ilorin West',
      'Offa',
      'Oyun'
    ],
    'Lagos': [
      'Agege',
      'Ajeromi-Ifelodun',
      'Alimosho',
      'Amuwo-Odofin',
      'Apapa',
      'Eti-Osa',
      'Ibeju-Lekki',
      'Ifako-Ijaiye',
      'Ikeja',
      'Ikorodu',
      'Kosofe',
      'Lagos Island',
      'Lagos Mainland',
      'Mushin',
      'Ojo',
      'Oshodi-Isolo',
      'Somolu',
      'Surulere'
    ],
    'Nasarawa': ['Akwanga', 'Karu', 'Keffi', 'Lafia', 'Nasarawa', 'Wamba'],
    'Niger': ['Bida', 'Chanchaga', 'Kontagora', 'Lapai', 'Minna', 'Suleja'],
    'Ogun': [
      'Abeokuta North',
      'Abeokuta South',
      'Ado-Odo/Ota',
      'Ifo',
      'Ijebu Ode',
      'Sagamu'
    ],
    'Ondo': [
      'Akoko South-West',
      'Akure North',
      'Akure South',
      'Ondo East',
      'Ondo West',
      'Owo'
    ],
    'Osun': [
      'Ede North',
      'Ede South',
      'Ife Central',
      'Ilesa East',
      'Ilesa West',
      'Osogbo'
    ],
    'Oyo': [
      'Akinyele',
      'Egbeda',
      'Ibadan North',
      'Ibadan North-East',
      'Ibadan South-West',
      'Ogbomosho North',
      'Oyo East'
    ],
    'Plateau': [
      'Barkin Ladi',
      'Bassa',
      'Jos East',
      'Jos North',
      'Jos South',
      'Mangu',
      'Pankshin'
    ],
    'Rivers': [
      'Bonny',
      'Eleme',
      'Obio/Akpor',
      'Okrika',
      'Port Harcourt',
      'Tai'
    ],
    'Sokoto': [
      'Binji',
      'Dange Shuni',
      'Gwadabawa',
      'Sokoto North',
      'Sokoto South',
      'Wamakko'
    ],
    'Taraba': ['Bali', 'Gashaka', 'Jalingo', 'Takum', 'Wukari', 'Zing'],
    'Yobe': ['Damaturu', 'Fika', 'Gashua', 'Nguru', 'Potiskum'],
    'Zamfara': ['Anka', 'Gusau', 'Kaura Namoda', 'Maru', 'Talata Mafara'],
  };

  List<String> get _states {
    final states = _stateLgas.keys.toList();
    if (_selectedState != null && !states.contains(_selectedState)) {
      states.add(_selectedState!);
    }
    return states;
  }

  List<String> get _lgas {
    if (_selectedState == null) return const [];
    final lgas = [...?_stateLgas[_selectedState]];
    if (_selectedLga != null && !lgas.contains(_selectedLga)) {
      lgas.add(_selectedLga!);
    }
    return lgas;
  }

  @override
  void initState() {
    super.initState();
    _ninController.addListener(() => setState(() {}));
    _loadSignupDetails();
  }

  @override
  void dispose() {
    _ninController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _verifyNin() async {
    final ninError = _nin(_ninController.text);
    if (ninError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ninError)),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _hasAttemptedVerification = false;
      _didSkipNin = false;
      _nameMismatchAcknowledged = false;
      _verifiedFirstName = null;
      _verifiedLastName = null;
    });

    try {
      final payload = {
        'Intcode': 'TESTCODE',
        'Password': 'royal1234',
        'number': _ninController.text.trim(),
      };

      debugPrint('=== VERIFY NIN REQUEST ===');
      debugPrint(
          'URL: https://eportaltest.rexinsure.com/api/mobile/verify/nin');
      debugPrint('Payload: ${json.encode(payload)}');

      final response = await http
          .post(
            Uri.parse(
                'https://eportaltest.rexinsure.com/api/mobile/verify/nin'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('=== VERIFY NIN RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      Map<String, dynamic>? kyc;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final status = data['status']?.toString().toLowerCase();
        final candidate = data['data']?['data']?['kyc'];
        if (status == 'success' && candidate is Map<String, dynamic>) {
          final firstName = candidate['firstname']?.toString() ?? '';
          if (firstName.trim().isNotEmpty) kyc = candidate;
        }
      }

      if (kyc != null) {
        _populateFromKyc(kyc);
      } else {
        _clearDetails(preserveIdentity: true);
      }

      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _hasAttemptedVerification = true;
        _verificationSucceeded = kyc != null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kyc != null
                ? 'NIN verified. Please review the details before continuing.'
                : 'NIN verification failed. Please enter your details manually.',
          ),
          backgroundColor: kyc != null ? Colors.green : Colors.orange,
        ),
      );

      if (kyc != null && _hasNameMismatch) {
        await _showNameMismatchDialog();
      }
    } catch (e) {
      _clearDetails(preserveIdentity: true);
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _hasAttemptedVerification = true;
        _verificationSucceeded = false;
        _nameMismatchAcknowledged = false;
        _verifiedFirstName = null;
        _verifiedLastName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('NIN verification failed. Please enter details manually.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _loadSignupDetails() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _firstNameController.text = prefs.getString('signup_first_name') ?? '';
      _lastNameController.text = prefs.getString('signup_last_name') ?? '';
      _emailController.text = prefs.getString('signup_email') ?? '';
      _dobController.text = prefs.getString('signup_dob') ?? '';
      final savedState = prefs.getString('signup_state') ?? '';
      final savedLga = prefs.getString('signup_lga') ?? '';
      _selectedState = savedState.isEmpty ? null : savedState;
      _selectedLga = savedLga.isEmpty ? null : savedLga;
      _addressController.text = prefs.getString('signup_address') ?? '';
    });
  }

  void _skipNinVerification() {
    FocusScope.of(context).unfocus();
    setState(() {
      _ninController.clear();
      _isVerifying = false;
      _hasAttemptedVerification = true;
      _verificationSucceeded = false;
      _didSkipNin = true;
      _nameMismatchAcknowledged = false;
      _verifiedFirstName = null;
      _verifiedLastName = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You can complete NIN verification later.'),
      ),
    );
  }

  void _populateFromKyc(Map<String, dynamic> kyc) {
    final state = _matchState(kyc['residence_state']?.toString() ?? '');
    final lga = _matchLga(state, kyc['residence_lga']?.toString() ?? '');

    _verifiedFirstName = kyc['firstname']?.toString().trim();
    _verifiedLastName = kyc['surname']?.toString().trim();
    _dobController.text = _normalizeDob(kyc['birthdate']?.toString() ?? '');
    _selectedState = state;
    _selectedLga = lga;
    _addressController.text = kyc['residence_address']?.toString() ?? '';
  }

  void _clearDetails({bool preserveIdentity = false}) {
    if (!preserveIdentity) {
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
    }
    _nameMismatchAcknowledged = false;
    _verifiedFirstName = null;
    _verifiedLastName = null;
    _dobController.clear();
    _selectedState = null;
    _selectedLga = null;
    _addressController.clear();
  }

  String _normalizeNameForCompare(String? value) {
    return (value ?? '').toLowerCase().replaceAll(RegExp(r"[^a-z]"), '').trim();
  }

  bool get _hasNameMismatch {
    if (!_verificationSucceeded) return false;
    final verifiedFirst = _normalizeNameForCompare(_verifiedFirstName);
    final verifiedLast = _normalizeNameForCompare(_verifiedLastName);
    if (verifiedFirst.isEmpty && verifiedLast.isEmpty) return false;

    final enteredFirst = _normalizeNameForCompare(_firstNameController.text);
    final enteredLast = _normalizeNameForCompare(_lastNameController.text);

    return enteredFirst != verifiedFirst || enteredLast != verifiedLast;
  }

  String get _enteredFullName {
    return '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
        .trim();
  }

  String get _verifiedFullName {
    return '${_verifiedFirstName ?? ''} ${_verifiedLastName ?? ''}'.trim();
  }

  Future<bool> _showNameMismatchDialog() async {
    if (!mounted) return false;

    final acknowledged = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Name mismatch'),
            content: Text(
              'The name entered during KYC does not match the name returned by NIN verification.\n\n'
              'Entered name: ${_enteredFullName.isEmpty ? 'Not provided' : _enteredFullName}\n'
              'NIN name: ${_verifiedFullName.isEmpty ? 'Not provided' : _verifiedFullName}\n\n'
              'Please confirm you want to continue with the name you entered.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Review'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Acknowledge & Continue'),
              ),
            ],
          ),
        ) ??
        false;

    if (acknowledged && mounted) {
      setState(() => _nameMismatchAcknowledged = true);
    }

    return acknowledged;
  }

  String? _matchState(String value) {
    if (value.trim().isEmpty) return null;
    return _stateLgas.keys.cast<String?>().firstWhere(
          (state) => state!.toLowerCase() == value.trim().toLowerCase(),
          orElse: () => value.trim(),
        );
  }

  String? _matchLga(String? state, String value) {
    if (value.trim().isEmpty) return null;
    final lgas =
        state == null ? const <String>[] : _stateLgas[state] ?? const [];
    return lgas.cast<String?>().firstWhere(
          (lga) => lga!.toLowerCase() == value.trim().toLowerCase(),
          orElse: () => value.trim(),
        );
  }

  String _normalizeDob(String value) {
    if (value.trim().isEmpty) return '';
    final normalized = value.trim().replaceAll('/', '-');
    final parts = normalized.split('-');
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
      }
      if (parts[2].length == 4) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    }
    return normalized;
  }

  Future<void> _continue() async {
    if (!_hasAttemptedVerification) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attempt NIN verification first')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    if (_hasNameMismatch && !_nameMismatchAcknowledged) {
      final acknowledged = await _showNameMismatchDialog();
      if (!acknowledged) return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('signup_nin', _ninController.text.trim());
    await prefs.setString(
        'signup_first_name', _firstNameController.text.trim());
    await prefs.setString('signup_last_name', _lastNameController.text.trim());
    await prefs.setString('signup_email', _emailController.text.trim());
    await prefs.setString('signup_dob', _dobController.text.trim());
    await prefs.setString('signup_state', _selectedState ?? '');
    await prefs.setString('signup_lga', _selectedLga ?? '');
    await prefs.setString('signup_address', _addressController.text.trim());

    if (!mounted) return;
    final exploreResumeScreen = await ExploreKycFlow.pendingResumeScreen();
    if (!mounted) return;
    if (exploreResumeScreen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => exploreResumeScreen),
      );
      return;
    }

    final hasExistingPolicy = prefs.getBool('has_existing_policy') ?? false;
    final phoneAlreadyVerified =
        (prefs.getString('signup_phone') ?? '').trim().isNotEmpty;
    if (!hasExistingPolicy && phoneAlreadyVerified) {
      Navigator.pushNamed(context, '/create-password');
    } else {
      Navigator.pushNamed(
        context,
        '/verify-phone',
        arguments: _emailController.text.trim(),
      );
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Please enter $label';
    return null;
  }

  String? _nin(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Please enter your NIN';
    if (!RegExp(r'^\d{11}$').hasMatch(raw)) {
      return 'NIN must be exactly 11 digits';
    }
    return null;
  }

  String? _name(String? value, String label) {
    final required = _required(value, label);
    if (required != null) return required;
    final trimmed = value!.trim();
    if (trimmed.length < 2) return '$label must be at least 2 characters';
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(trimmed)) {
      return '$label can only contain letters';
    }
    return null;
  }

  String? _email(String? value) {
    final required = _required(value, 'your email');
    if (required != null) return required;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _dob(String? value) {
    final required = _required(value, 'date of birth');
    if (required != null) return required;
    final parsed = DateTime.tryParse(value!.trim());
    if (parsed == null) return 'Please select a valid date of birth';
    if (parsed.isAfter(DateTime.now())) {
      return 'Date of birth cannot be in the future';
    }
    return null;
  }

  String? _address(String? value) {
    final required = _required(value, 'address');
    if (required != null) return required;
    if (value!.trim().length < 5) return 'Address is too short';
    return null;
  }

  Widget _requiredLabel(
    String label, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initialDate = DateTime.tryParse(_dobController.text) ??
        DateTime(now.year - 30, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _dobController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<String>? autofillHints,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
          decoration: _inputDecoration(label.toLowerCase()),
          validator: validator ?? (value) => _required(value, label),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel('Date of Birth'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          onTap: _pickDob,
          autofillHints: const [AutofillHints.birthday],
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
          decoration: _inputDecoration('select date of birth').copyWith(
            suffixIcon: Icon(Icons.calendar_today_outlined,
                color: Colors.grey[600], size: 20),
          ),
          validator: _dob,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: items.isEmpty ? null : onChanged,
          decoration: _inputDecoration(hint),
          validator: (selected) => selected == null || selected.isEmpty
              ? 'Please select $label'
              : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NIN',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _requiredLabel(
                    'Enter your NIN',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ninController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'enter your 11-digit NIN',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppTheme.primaryBlue, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            errorText: _ninController.text.isNotEmpty &&
                                    _ninController.text.length != 11
                                ? 'NIN must be exactly 11 digits'
                                : null,
                          ),
                          validator: (value) {
                            if (_didSkipNin && (value ?? '').trim().isEmpty) {
                              return null;
                            }
                            return _nin(value);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 52,
                        width: 90,
                        child: ElevatedButton(
                          onPressed:
                              _ninController.text.length == 11 && !_isVerifying
                                  ? _verifyNin
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _verificationSucceeded
                                ? Colors.green
                                : AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            disabledBackgroundColor:
                                AppTheme.disabledButtonColor(context),
                            disabledForegroundColor:
                                AppTheme.disabledButtonTextColor(context),
                            padding: EdgeInsets.zero,
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  _verificationSucceeded
                                      ? 'Verified'
                                      : 'Verify',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isVerifying ? null : _skipNinVerification,
                      child: Text(
                        "Skip, I'll do it later",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppTheme.primaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (_hasAttemptedVerification) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _verificationSucceeded
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _verificationSucceeded
                              ? Colors.green[200]!
                              : Colors.orange[200]!,
                        ),
                      ),
                      child: Text(
                        _verificationSucceeded
                            ? 'NIN verified. Your entered name was kept; please review the remaining details.'
                            : _didSkipNin
                                ? 'NIN skipped. Please complete your details manually.'
                                : 'Verification failed. Please complete your details manually.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _verificationSucceeded
                              ? Colors.green[700]
                              : Colors.orange[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _field(
                      'First Name',
                      _firstNameController,
                      autofillHints: const [AutofillHints.givenName],
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => _name(value, 'First name'),
                    ),
                    _field(
                      'Last Name',
                      _lastNameController,
                      autofillHints: const [AutofillHints.familyName],
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => _name(value, 'Last name'),
                    ),
                    _field(
                      'Email Address',
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: _email,
                    ),
                    _dateField(),
                    _dropdownField(
                      label: 'State',
                      hint: 'select state',
                      value: _selectedState,
                      items: _states,
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                          _selectedLga = null;
                        });
                      },
                    ),
                    _dropdownField(
                      label: 'LGA',
                      hint: _selectedState == null
                          ? 'select state first'
                          : 'select LGA',
                      value: _selectedLga,
                      items: _lgas,
                      onChanged: (value) {
                        setState(() => _selectedLga = value);
                      },
                    ),
                    _field(
                      'Address',
                      _addressController,
                      keyboardType: TextInputType.streetAddress,
                      autofillHints: const [AutofillHints.fullStreetAddress],
                      textCapitalization: TextCapitalization.words,
                      validator: _address,
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _hasAttemptedVerification ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasAttemptedVerification
                            ? AppTheme.primaryBlue
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
