import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

String reliefQuantitySummary(Map<String, dynamic> d) {
  final mainQuantity = d['quantity'] ?? '—';
  final additional = (d['additional_resource'] ??
      d['additionalResource'] ??
      d['additional_resource_item']) as Map?;
  final lines = <String>['Quantity: $mainQuantity'];
  final additionalName = additional?['name']?.toString();
  final additionalQuantity = d['additional_quantity'];
  if (additionalName != null &&
      additionalName.isNotEmpty &&
      additionalQuantity != null) {
    lines.add(
        'Additional relief: $additionalName • Quantity: $additionalQuantity');
  }
  return lines.join('\n');
}

void main() => runApp(const FamilyApp());

class FamilyApp extends StatelessWidget {
  const FamilyApp({super.key});

  @override
  Widget build(BuildContext c) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barangay Household Portal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2563eb)),
        scaffoldBackgroundColor: const Color(0xfff6f8fc),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xffffffff),
            foregroundColor: Color(0xff0f172a),
            elevation: 0),
        cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xffe8edf5)))),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffdbe3ef))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffdbe3ef))),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13)),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                minimumSize: const Size(44, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)))),
      ),
      home: const LoginPage());
}

// ─── Constants shared with login ─────────────────────────────────────────────

const _blue = Color(0xff2563eb);
const _ink = Color(0xff0f172a);
const _muted = Color(0xff64748b);
const _canvas = Color(0xfff6f8fc);

// ─── Family App logo ─────────────────────────────────────────────────────────

class _FamilyLogo extends StatelessWidget {
  const _FamilyLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff1d4ed8), Color(0xff2563eb), Color(0xff1e40af)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff2563eb).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wave background
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                ),
              ),
              // House icon
              Positioned(
                top: 8,
                child: Icon(
                  Icons.house_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 38,
                ),
              ),
              // Family icon below house
              const Positioned(
                bottom: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, color: Colors.white, size: 18),
                    Icon(Icons.person, color: Colors.white, size: 22),
                    Icon(Icons.person, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Barangay Household',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _ink,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const Text(
          'Information',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _ink,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 1, width: 24, color: const Color(0xff2563eb)),
            const SizedBox(width: 8),
            const Text(
              'APPLICATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xff2563eb),
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(height: 1, width: 24, color: const Color(0xff2563eb)),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Together for a safer and stronger community.',
          style: TextStyle(color: _muted, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Field label helper ───────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: _ink),
      );
}

// ─── Login Page ───────────────────────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  bool _busy = false;
  bool _hidePIN = true;
  bool _rememberMe = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getString('family_remember');
    if (remembered != null && mounted) {
      setState(() {
        _phone.text = remembered;
        _rememberMe = true;
      });
    }
  }

  Future<void> _login() async {
    if (_phone.text.trim().isEmpty || _pw.text.isEmpty) {
      setState(() => _error = 'Enter your Family ID or phone and PIN.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await Api.req('POST', '/family/login', auth: false, body: {
        'phone': _phone.text.trim(),
        'pin': _pw.text,
      });
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('family_remember', _phone.text.trim());
      } else {
        await prefs.remove('family_remember');
      }
      await Api.saveToken(r['token']);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FamilyHome()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _canvas,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: _FamilyLogo()),
                    const SizedBox(height: 28),
                    const Text(
                      'Sign in to your family account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _ink),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your Family ID or phone number and PIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _FieldLabel('Family ID or phone number'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _phone,
                              keyboardType: TextInputType.text,
                              onSubmitted: (_) => _busy ? null : _login(),
                              decoration: const InputDecoration(
                                hintText: 'FAM-0001 or 09XXXXXXXXX',
                              ),
                            ),
                            const SizedBox(height: 14),
                            const _FieldLabel('Family PIN'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _pw,
                              obscureText: _hidePIN,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                              onSubmitted: (_) => _busy ? null : _login(),
                              decoration: InputDecoration(
                                hintText: 'Enter your 6-digit PIN',
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                      () => _hidePIN = !_hidePIN),
                                  icon: Icon(_hidePIN
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(
                                      () => _rememberMe = v ?? false),
                                  activeColor: _blue,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 6),
                                const Text('Remember me',
                                    style: TextStyle(
                                        fontSize: 13, color: _ink)),
                              ],
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 10),
                              Text(_error!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13)),
                            ],
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: _busy ? null : _login,
                              child: _busy
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Text('Sign in'),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ForgotPage())),
                                child: const Text('Forgot PIN?',
                                    style: TextStyle(
                                        color: _blue,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account? ",
                                    style: TextStyle(
                                        color: _muted, fontSize: 13)),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterPage())),
                                  child: const Text('Register family',
                                      style: TextStyle(
                                          color: _blue,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class AuthScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const AuthScaffold({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext c) => Scaffold(
      body: Center(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.volunteer_activism,
                            size: 64, color: Color(0xff2563eb)),
                        Text(title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        ...children
                      ])))));
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final family = TextEditingController();
  final head = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  // Dynamic list of member name controllers
  final List<TextEditingController> _memberControllers = [TextEditingController()];
  final pw = TextEditingController();
  final confirm = TextEditingController();
  List<dynamic> puroks = [], locations = [];
  int? purok, location;
  String? error;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    Api.req('GET', '/puroks', auth: false).then((r) {
      if (mounted) {
        setState(() {
          puroks = r['puroks'] ?? [];
          locations = r['locations'] ?? [];
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          error = e.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    family.dispose();
    head.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    for (final c in _memberControllers) {
      c.dispose();
    }
    pw.dispose();
    confirm.dispose();
    super.dispose();
  }

  void _addMember() {
    setState(() => _memberControllers.add(TextEditingController()));
  }

  void _removeMember(int index) {
    if (_memberControllers.length <= 1) return;
    setState(() {
      _memberControllers[index].dispose();
      _memberControllers.removeAt(index);
    });
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (purok == null || location == null) {
      setState(() =>
          error = 'Please select your assigned purok and barangay/location.');
      return;
    }
    // Validate member names are not empty
    for (int i = 0; i < _memberControllers.length; i++) {
      if (_memberControllers[i].text.trim().isEmpty) {
        setState(() => error = 'Member ${i + 1} name is required.');
        return;
      }
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (pw.text != confirm.text) throw Exception('PINs do not match.');
      final memberNames = _memberControllers.map((c) => c.text.trim()).toList();
      final r = await Api.req(
        'POST',
        '/family/register',
        auth: false,
        body: {
          'family_name': family.text.trim(),
          'head_name': head.text.trim(),
          'email': email.text.trim(),
          'phone': phone.text.trim(),
          'address': address.text.trim(),
          'household_member': memberNames.length,
          'member_names': memberNames,
          'purok_id': purok,
          'location_id': location,
          'pin': pw.text,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful! Family ID: ${r['family']?['family_id'] ?? 'Please keep your phone number and PIN'}',
            ),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Widget field(TextEditingController c, String label,
          {bool secret = false,
          TextInputType? keyboard,
          int? maxLength,
          String? Function(String?)? validator}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
              controller: c,
              obscureText: secret,
              keyboardType: keyboard,
              maxLength: maxLength,
              buildCounter: maxLength != null
                  ? (_, {required currentLength, required isFocused, maxLength}) => null
                  : null,
              validator: validator ??
                  (v) => (v == null || v.trim().isEmpty)
                      ? 'This field is required'
                      : null,
              decoration: InputDecoration(
                  labelText: label, border: const OutlineInputBorder())));

  String? requiredText(String? v) =>
      v == null || v.trim().isEmpty ? 'This field is required' : null;

  @override
  Widget build(BuildContext c) => Scaffold(
        backgroundColor: _canvas,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: _FamilyLogo()),
                    const SizedBox(height: 28),
                    const Text(
                      'Register Family',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _ink),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Create your household account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _FieldLabel(
                                  'Family Name (e.g. Dela Cruz Family)'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: family,
                                validator: requiredText,
                                decoration: const InputDecoration(
                                    hintText: 'Enter family name'),
                              ),
                              const SizedBox(height: 14),
                              const _FieldLabel('Head of Family'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: head,
                                validator: requiredText,
                                decoration: const InputDecoration(
                                    hintText: 'Enter head of family name'),
                              ),
                              const SizedBox(height: 14),
                              const _FieldLabel(
                                  'Phone Number (09XXXXXXXXX)'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: phone,
                                keyboardType: TextInputType.phone,
                                maxLength: 11,
                                buildCounter: (_,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  if (!RegExp(r'^09\d{9}$')
                                      .hasMatch(v.trim())) {
                                    return 'Phone must be 11 digits starting with 09';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    hintText: '09XXXXXXXXX'),
                              ),
                              const SizedBox(height: 14),
                              const _FieldLabel('Email (for PIN recovery)'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                      .hasMatch(v.trim())) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    hintText: 'your@email.com'),
                              ),
                              const SizedBox(height: 14),
                              const _FieldLabel('Address'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: address,
                                validator: requiredText,
                                decoration: const InputDecoration(
                                    hintText: 'Enter your address'),
                              ),
                              const SizedBox(height: 14),
                              // Info box above members
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xffeff6ff),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xffbfdbfe)),
                                ),
                                child: const Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: _blue, size: 16),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'List all family members to prevent duplicate registrations. '
                                        'If a name is already registered, the system will reject the submission.',
                                        style: TextStyle(
                                            fontSize: 12, color: _blue),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Dynamic Household Members section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Household Members (${_memberControllers.length})',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  TextButton.icon(
                                    onPressed: _addMember,
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add member'),
                                    style: TextButton.styleFrom(
                                        visualDensity:
                                            VisualDensity.compact),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ...List.generate(_memberControllers.length,
                                  (i) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 28,
                                        child: Text(
                                          '${i + 1}.',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _memberControllers[i],
                                          decoration: InputDecoration(
                                            hintText:
                                                'Member ${i + 1} full name',
                                          ),
                                        ),
                                      ),
                                      if (_memberControllers.length >
                                          1) ...[
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              size: 18,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _removeMember(i),
                                          tooltip: 'Remove member',
                                          visualDensity:
                                              VisualDensity.compact,
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                              const _FieldLabel('Assigned Purok'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                initialValue: purok,
                                decoration: const InputDecoration(
                                    hintText: 'Select purok'),
                                validator: (v) => v == null
                                    ? 'Please select a purok'
                                    : null,
                                items: puroks
                                    .map((x) => DropdownMenuItem<int>(
                                          value: int.tryParse(
                                              x['id'].toString()),
                                          child:
                                              Text(x['name'].toString()),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => purok = v),
                              ),
                              const SizedBox(height: 14),
                              const _FieldLabel('Barangay / Location'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                initialValue: location,
                                decoration: const InputDecoration(
                                    hintText: 'Select barangay/location'),
                                validator: (v) => v == null
                                    ? 'Please select a barangay/location'
                                    : null,
                                items: locations
                                    .map((x) => DropdownMenuItem<int>(
                                          value: int.tryParse(
                                              x['id'].toString()),
                                          child:
                                              Text(x['name'].toString()),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => location = v),
                              ),
                              const SizedBox(height: 14),
                              const _FieldLabel('Family PIN (6 digits)'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: pw,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                buildCounter: (_,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'PIN is required';
                                  }
                                  if (!RegExp(r'^\d{6}$')
                                      .hasMatch(v.trim())) {
                                    return 'PIN must be exactly 6 digits';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Enter 6-digit PIN'),
                              ),
                              const SizedBox(height: 14),
                              const _FieldLabel(
                                  'Confirm Family PIN (6-digit PIN)'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: confirm,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                buildCounter: (_,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please confirm your PIN';
                                  }
                                  if (v != pw.text) {
                                    return 'PINs do not match';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Confirm 6-digit PIN'),
                              ),
                              if (error != null) ...[
                                const SizedBox(height: 10),
                                Text(error!,
                                    style: const TextStyle(
                                        color: Colors.red)),
                              ],
                              const SizedBox(height: 14),
                              FilledButton(
                                  onPressed: busy ? null : submit,
                                  child: Text(
                                      busy ? 'Registering…' : 'Register')),
                              const SizedBox(height: 8),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Back to login')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _email   = TextEditingController();
  final _otp     = TextEditingController();
  final _pin     = TextEditingController();
  final _confirm = TextEditingController();
  bool _sent = false;
  bool _busy = false;
  bool _hidePin    = true;
  bool _hideConfirm = true;
  String? _error;

  Future<void> _sendCode() async {
    final emailVal = _email.text.trim();
    if (emailVal.isEmpty) {
      setState(() => _error = 'Please enter your registered email address.');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      await Api.req('POST', '/family/forgot-password',
          auth: false, body: {'email': emailVal});
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPin() async {
    // Validate OTP
    if (_otp.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit code sent to your email.');
      return;
    }
    // Validate new PIN
    if (!RegExp(r'^\d{6}$').hasMatch(_pin.text)) {
      setState(() => _error = 'New PIN must be exactly 6 digits.');
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(() => _error = 'PINs do not match.');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      await Api.req('POST', '/family/reset-password', auth: false, body: {
        'email':                 _email.text.trim(),
        'otp':                   _otp.text.trim(),
        'password':              _pin.text,
        'password_confirmation': _confirm.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN changed successfully. Please log in with your new PIN.')));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _canvas,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _sent ? 'Reset your PIN' : 'Forgot PIN?',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _ink),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _sent
                              ? 'Enter the 6-digit code sent to your email, then set a new 6-digit PIN.'
                              : 'Enter the email address you registered with and we\'ll send you a reset code.',
                          style: const TextStyle(color: _muted, fontSize: 13),
                        ),
                        const SizedBox(height: 20),

                        // Email field (always shown)
                        const _FieldLabel('Email address'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: _sent,
                          decoration: InputDecoration(
                            hintText: 'your@email.com',
                            filled: true,
                            fillColor: _sent ? const Color(0xfff8fafc) : Colors.white,
                          ),
                        ),

                        // Fields shown after OTP sent
                        if (_sent) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xffecfdf5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'A 6-digit code was sent to your email. It expires in 10 minutes.',
                              style: TextStyle(
                                  color: Color(0xff059669), fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _FieldLabel('6-digit code'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _otp,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              hintText: 'Enter code',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _FieldLabel('New PIN (6 digits)'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _pin,
                            keyboardType: TextInputType.number,
                            obscureText: _hidePin,
                            maxLength: 6,
                            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                            decoration: InputDecoration(
                              hintText: '6-digit PIN',
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _hidePin = !_hidePin),
                                icon: Icon(_hidePin
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _FieldLabel('Confirm new PIN'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _confirm,
                            keyboardType: TextInputType.number,
                            obscureText: _hideConfirm,
                            maxLength: 6,
                            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                            decoration: InputDecoration(
                              hintText: '6-digit PIN',
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _hideConfirm = !_hideConfirm),
                                icon: Icon(_hideConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                              ),
                            ),
                          ),
                        ],

                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13)),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _busy ? null : (_sent ? _resetPin : _sendCode),
                          child: _busy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text(_sent ? 'Set new PIN' : 'Send reset code'),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back to login',
                                style: TextStyle(
                                    color: _blue,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class FamilyHome extends StatefulWidget {
  const FamilyHome({super.key});

  @override
  State<FamilyHome> createState() => _FamilyHomeState();
}

class _FamilyHomeState extends State<FamilyHome> {
  int tab = 0;
  Timer? _announcementTimer;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await Api.req('POST', '/family/logout');
    } catch (_) {}
    await Api.clearToken();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
    }
  }

  Future<void> _checkAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSeen = prefs.getInt('last_announcement_id') ?? 0;
      final data = await Api.req('GET', '/family/announcements');
      final list = (data['announcements'] as List? ?? []);
      if (list.isEmpty) return;
      // Find announcements newer than lastSeen
      final newOnes = list
          .where((a) => (a['id'] as int? ?? 0) > lastSeen)
          .toList();
      if (newOnes.isEmpty || !mounted) return;
      // Update last_announcement_id to max id seen
      final maxId = list
          .map<int>((a) => a['id'] as int? ?? 0)
          .reduce((a, b) => a > b ? a : b);
      await prefs.setInt('last_announcement_id', maxId);
      // Show a dialog for each new announcement
      for (final ann in newOnes) {
        if (!mounted) break;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(ann['title']?.toString() ?? 'Announcement'),
            content: Text(ann['body']?.toString() ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      // Silently ignore network/auth errors
    }
  }

  @override
  void initState() {
    super.initState();
    // Check immediately on load
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAnnouncements());
    // Then poll every 30 seconds
    _announcementTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAnnouncements(),
    );
  }

  @override
  void dispose() {
    _announcementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
      appBar: AppBar(
          titleSpacing: 16,
          title: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(11)),
              child: const Center(
                child: Text('BH',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Barangay Household',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('Information System',
                      style: TextStyle(color: _muted, fontSize: 11)),
                ],
              ),
            ),
          ]),
          actions: [
            IconButton(
                onPressed: _logout, icon: const Icon(Icons.logout))
          ]),
      body: IndexedStack(index: tab, children: const [
        RecordsPage(),
        UpcomingDistributionPage(),
        ProfilePage(),
        MessagesPage()
      ]),
      bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (v) => setState(() => tab = v),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.history), label: 'My Records'),
            NavigationDestination(icon: Icon(Icons.event), label: 'Schedule'),
            NavigationDestination(icon: Icon(Icons.home), label: 'Family Info'),
            NavigationDestination(icon: Icon(Icons.chat), label: 'Messages')
          ]));
}

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  late Future<Map<String, dynamic>> future =
      Api.req('GET', '/family/distributions');

  Color _statusColor(dynamic s) {
    final v = s?.toString().toLowerCase() ?? '';
    if (v == 'completed') return const Color(0xff059669);
    if (v == 'cancelled' || v == 'canceled') return const Color(0xffdc2626);
    return const Color(0xfff59e0b);
  }

  String _fmtDate(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return 'Date not set';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext c) => FutureBuilder(
        future: future,
        builder: (c, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = s.data!['distributions'] as List? ?? [];
          if (rows.isEmpty) {
            return const Center(child: Text('No distribution records yet.'));
          }
          return RefreshIndicator(
            onRefresh: () async => setState(
                () => future = Api.req('GET', '/family/distributions')),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: rows
                  .map<Widget>((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                    color: const Color(0xfff0fdfa),
                                    borderRadius:
                                        BorderRadius.circular(13)),
                                child: const Icon(
                                    Icons.inventory_2_outlined,
                                    color: Color(0xff0d9488)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d['resource']?['name']
                                              ?.toString() ??
                                          'Relief not assigned',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      reliefQuantitySummary(
                                          Map<String, dynamic>.from(d)),
                                      style: const TextStyle(
                                          fontSize: 12, color: _muted),
                                    ),
                                    Text(
                                      _fmtDate(d['distribution_date']),
                                      style: const TextStyle(
                                          fontSize: 11, color: _muted),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 4),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(d['status'])
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        d['status']?.toString() ??
                                            'pending',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: _statusColor(
                                                d['status']),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Color(0xff94a3b8)),
                            ]),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
        },
      );
}


class UpcomingDistributionPage extends StatefulWidget {
  const UpcomingDistributionPage({super.key});

  @override
  State<UpcomingDistributionPage> createState() =>
      _UpcomingDistributionPageState();
}

class _UpcomingDistributionPageState
    extends State<UpcomingDistributionPage> {
  late Future<Map<String, dynamic>> future =
      Api.req('GET', '/family/distributions');

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // Automatically refresh schedules every 30 seconds.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) {
          setState(() {
            future = Api.req('GET', '/family/distributions');
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Color _statusColor(dynamic s) {
    final v = s?.toString().toLowerCase() ?? '';
    if (v == 'completed') return const Color(0xff059669);
    if (v == 'cancelled' || v == 'canceled') return const Color(0xffdc2626);
    return const Color(0xfff59e0b);
  }

  String _fmtDate(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return 'Date not set';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Could not load upcoming distribution: '
                '${snapshot.error}',
              ),
            ),
          );
        }

        final rows =
            (snapshot.data?['distributions'] as List? ?? [])
                .where((d) {
          final raw = d['distribution_date'];

          if (raw == null) return false;

          try {
            return !DateTime.parse(raw.toString())
                .isBefore(DateTime.now());
          } catch (_) {
            return false;
          }
        }).toList();

        if (rows.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: const [
              SizedBox(height: 40),
              Icon(Icons.event_busy, size: 56),
              SizedBox(height: 12),
              Text(
                'No upcoming relief distribution has been scheduled yet.',
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              future = Api.req(
                'GET',
                '/family/distributions',
              );
            });

            await future;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Your family has a distribution record for '
                    'the following upcoming schedule(s). '
                    'Check the status below.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),

              ...rows.map<Widget>((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: const Color(0xfff0fdfa),
                                borderRadius:
                                    BorderRadius.circular(13)),
                            child: const Icon(
                                Icons.volunteer_activism,
                                color: Color(0xff0d9488)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d['resource']?['name']
                                          ?.toString() ??
                                      'Relief not assigned',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  reliefQuantitySummary(
                                      Map<String, dynamic>.from(d)),
                                  style: const TextStyle(
                                      fontSize: 12, color: _muted),
                                ),
                                Text(
                                  _fmtDate(d['distribution_date']),
                                  style: const TextStyle(
                                      fontSize: 11, color: _muted),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 4),
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _statusColor(d['status'])
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    d['status']?.toString() ??
                                        'pending',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            _statusColor(d['status']),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Color(0xff94a3b8)),
                        ]),
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}


// ─── Family Detail Row helper ─────────────────────────────────────────────────

class _FamilyDetailRow extends StatelessWidget {
  const _FamilyDetailRow(this.label, this.value);
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: _muted))),
        Expanded(
            child: Text(value!,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink))),
      ]),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> future = Api.req('GET', '/family/me');

  @override
  Widget build(BuildContext c) => FutureBuilder(
        future: future,
        builder: (c, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final f = s.data!['family'] as Map<String, dynamic>? ?? {};
          return RefreshIndicator(
            onRefresh: () async =>
                setState(() => future = Api.req('GET', '/family/me')),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Avatar section
                Center(
                  child: Column(children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: _blue,
                      child: Text(
                        (f['family_name']?.toString() ?? 'F').isNotEmpty
                            ? f['family_name']
                                .toString()[0]
                                .toUpperCase()
                            : 'F',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      f['family_name']?.toString() ?? 'Family',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _ink),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xffeff6ff),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _blue)),
                      child: Text(
                        f['family_id']?.toString() ?? '',
                        style: const TextStyle(
                            color: _blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                // Details card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _FamilyDetailRow(
                          'Family Name', f['family_name']?.toString()),
                      _FamilyDetailRow(
                          'Family ID', f['family_id']?.toString()),
                      _FamilyDetailRow(
                          'Head of Family', f['head_name']?.toString()),
                      _FamilyDetailRow('Household Members',
                          '${f['household_member'] ?? '—'} member(s)'),
                      _FamilyDetailRow(
                          'Purok', f['purok']?['name']?.toString()),
                      _FamilyDetailRow('Barangay / Location',
                          f['location']?['name']?.toString()),
                      _FamilyDetailRow(
                          'Status', f['status']?.toString()),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final text = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _timer;
  List<Map<String, dynamic>> _messages = [];
  bool _sending = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _timer = Timer.periodic(
        const Duration(seconds: 10), (_) => _loadMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollCtrl.dispose();
    text.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final result = await Api.req('GET', '/family/messages');
      final list = result['messages'] as List? ?? [];
      if (mounted) {
        setState(() =>
            _messages = list.map((e) => e as Map<String, dynamic>).toList());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> send() async {
    if (text.text.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await Api.req('POST', '/family/messages',
          body: {'message': text.text.trim()});
      text.clear();
      await _loadMessages();
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h =
          dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } catch (_) {
      return '';
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day == today) return 'Today';
      if (day == yesterday) return 'Yesterday';
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  List<Map<String, dynamic>> _groupByDate() {
    final groups = <Map<String, dynamic>>[];
    String lastLabel = '';
    for (final msg in _messages) {
      final label = _formatDate(msg['created_at']?.toString());
      if (label != lastLabel) {
        groups.add({'type': 'date', 'label': label});
        lastLabel = label;
      }
      groups.add({'type': 'msg', 'data': msg});
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color(0xffe8edf5))),
          ),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xffdbeafe),
                  borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.groups_outlined,
                  color: _blue, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Administrator',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text('Barangay Household Support',
                    style: TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ]),
        ),
        // Messages list
        Expanded(
          child: _messages.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 56, color: Color(0xffcbd5e1)),
                      SizedBox(height: 12),
                      Text('No messages yet',
                          style: TextStyle(color: _muted)),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: _groupByDate().length,
                  itemBuilder: (context, index) {
                    final items = _groupByDate();
                    final item = items[index];
                    if (item['type'] == 'date') {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          const Expanded(child: Divider()),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xfff1f5f9),
                                borderRadius:
                                    BorderRadius.circular(12)),
                            child: Text(item['label']?.toString() ?? '',
                                style: const TextStyle(
                                    fontSize: 11, color: _muted)),
                          ),
                          const Expanded(child: Divider()),
                        ]),
                      );
                    }
                    final m =
                        item['data'] as Map<String, dynamic>? ?? {};
                    final isSelf = m['sender_type'] == 'family' ||
                        m['sender_type'] == 'user';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: isSelf
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: isSelf
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: screenWidth * 0.72),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelf
                                        ? _blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          const Radius.circular(18),
                                      topRight:
                                          const Radius.circular(18),
                                      bottomLeft: Radius.circular(
                                          isSelf ? 18 : 4),
                                      bottomRight: Radius.circular(
                                          isSelf ? 4 : 18),
                                    ),
                                    border: isSelf
                                        ? null
                                        : Border.all(
                                            color: const Color(
                                                0xffe2e8f0)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2)),
                                    ],
                                  ),
                                  child: Text(
                                    m['message']?.toString() ?? '',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: isSelf
                                            ? Colors.white
                                            : _ink),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2, left: 4, right: 4),
                            child: Text(
                              _formatTime(
                                  m['created_at']?.toString()),
                              style: const TextStyle(
                                  fontSize: 10, color: _muted),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(error!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        // Compose area
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: const BoxDecoration(
            border:
                Border(top: BorderSide(color: Color(0xffe8edf5))),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: text,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: 'Message administrator…',
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sending ? null : send,
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _blue))
                  : const Icon(Icons.send_rounded, color: _blue),
              style: IconButton.styleFrom(
                  backgroundColor: const Color(0xffeff6ff),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ]),
        ),
      ],
    );
  }
}
