part of '../main.dart';

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
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24)),
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

// â”€â”€â”€ Field label helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

// â”€â”€â”€ Login Page â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
      setState(() => _error = 'Enter your email or phone number and PIN.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await AuthController().login(
        identifier: _phone.text.trim(),
        pin: _pw.text,
      );
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('family_remember', _phone.text.trim());
      } else {
        await prefs.remove('family_remember');
      }
      if (mounted) {
        // If the account was bulk-imported, prompt a PIN change before entering the app
        if (session.mustChangePin) {
          _showChangePinDialog(currentPin: _pw.text);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FamilyHome()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showChangePinDialog({required String currentPin}) {
    final newPinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;
    bool busy = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Change Your PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You logged in with a temporary PIN. Please set a new PIN to secure your account.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPinCtrl,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'New PIN (4–6 digits)',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Confirm new PIN',
                    counterText: '',
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!,
                      style: const TextStyle(fontSize: 12, color: Colors.red)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: busy
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const FamilyHome()),
                        );
                      },
                child: const Text('Skip'),
              ),
              FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        final newPin = newPinCtrl.text.trim();
                        final confirm = confirmCtrl.text.trim();
                        if (newPin.length < 4 ||
                            newPin.length > 6 ||
                            !RegExp(r'^[0-9]+$').hasMatch(newPin)) {
                          setDialogState(
                              () => error = 'PIN must be 4–6 digits.');
                          return;
                        }
                        if (newPin != confirm) {
                          setDialogState(() => error = 'PINs do not match.');
                          return;
                        }
                        if (newPin == currentPin) {
                          setDialogState(() => error =
                              'New PIN must be different from the temporary PIN.');
                          return;
                        }
                        setDialogState(() {
                          busy = true;
                          error = null;
                        });
                        try {
                          await AuthController().changePin(
                            currentPin: currentPin,
                            newPin: newPin,
                          );
                          if (context.mounted) {
                            Navigator.of(dialogContext).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const FamilyHome()),
                            );
                          }
                        } catch (e) {
                          setDialogState(() {
                            error =
                                e.toString().replaceFirst('Exception: ', '');
                            busy = false;
                          });
                        }
                      },
                child: busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Change PIN'),
              ),
            ],
          );
        });
      },
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                      'Enter your email or phone number and PIN',
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
                            const _FieldLabel('Email or phone number'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _phone,
                              keyboardType: TextInputType.text,
                              onSubmitted: (_) => _busy ? null : _login(),
                              decoration: const InputDecoration(
                                hintText: 'your@email.com or 09XXXXXXXXX',
                              ),
                            ),
                            const SizedBox(height: 14),
                            const _FieldLabel('Family PIN / Member Password'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _pw,
                              obscureText: _hidePIN,
                              keyboardType: TextInputType.visiblePassword,
                              onSubmitted: (_) => _busy ? null : _login(),
                              decoration: InputDecoration(
                                hintText:
                                    'Enter your family PIN or member password',
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _hidePIN = !_hidePIN),
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
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  activeColor: _blue,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 6),
                                const Text('Remember me',
                                    style:
                                        TextStyle(fontSize: 13, color: _ink)),
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
                                          strokeWidth: 2, color: Colors.white))
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
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text("Don't have an account?",
                                    style:
                                        TextStyle(color: _muted, fontSize: 13)),
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
  final memberFormKey = GlobalKey<FormState>();
  final head = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  // Dynamic list of member name controllers
  final List<TextEditingController> _memberControllers = [
    TextEditingController()
  ];
  final pw = TextEditingController();
  final confirm = TextEditingController();
  final memberName = TextEditingController();
  final memberHead = TextEditingController();
  final memberEmail = TextEditingController();
  final memberPhone = TextEditingController();
  final memberPassword = TextEditingController();
  bool registerAsMember = false;
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
    head.dispose();
    email.dispose();
    phone.dispose();
    for (final c in _memberControllers) {
      c.dispose();
    }
    pw.dispose();
    confirm.dispose();
    memberName.dispose();
    memberHead.dispose();
    memberEmail.dispose();
    memberPhone.dispose();
    memberPassword.dispose();
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
      await Api.req(
        'POST',
        '/family/register',
        auth: false,
        body: {
          'head_name': head.text.trim(),
          'email': email.text.trim(),
          'phone': phone.text.trim(),
          'household_member': memberNames.length,
          'member_names': memberNames,
          'purok_id': purok,
          'location_id': location,
          'pin': pw.text,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful! Sign in with your email or phone number and PIN.',
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

  Future<void> submitMember() async {
    if (!memberFormKey.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await Api.req(
        'POST',
        '/family/register-member',
        auth: false,
        body: {
          'name': memberName.text.trim(),
          'head_name': memberHead.text.trim(),
          'email': memberEmail.text.trim(),
          'phone': memberPhone.text.trim(),
          'password': memberPassword.text,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Member account created. Sign in with your email or phone and password.'),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Widget buildMemberRegistrationForm() => Form(
        key: memberFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create an account for a person already listed in the family records.',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            field(memberName, 'Name'),
            field(memberHead, 'Head of the Family'),
            field(
              memberEmail,
              'Email',
              keyboard: TextInputType.emailAddress,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            field(
              memberPhone,
              'Phone (09XXXXXXXXX)',
              keyboard: TextInputType.phone,
              maxLength: 11,
              validator: (value) =>
                  value == null || !RegExp(r'^09\d{9}$').hasMatch(value.trim())
                      ? 'Phone must be 11 digits starting with 09'
                      : null,
            ),
            field(
              memberPassword,
              'Password (at least 8 characters)',
              secret: true,
              validator: (value) => value == null || value.length < 8
                  ? 'Password must be at least 8 characters'
                  : null,
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: busy ? null : submitMember,
              child: Text(busy ? 'Registering…' : 'Register as Member'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to login'),
            ),
          ],
        ),
      );

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
                  ? (_,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: _FamilyLogo()),
                    const SizedBox(height: 28),
                    Text(
                      registerAsMember
                          ? 'Register as Member'
                          : 'Register Family',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _ink),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      registerAsMember
                          ? 'Create an account for a registered household member'
                          : 'Create your household account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Family Registration'),
                          icon: Icon(Icons.family_restroom),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Register as Member'),
                          icon: Icon(Icons.person_add_alt_1),
                        ),
                      ],
                      selected: {registerAsMember},
                      onSelectionChanged: (selection) {
                        setState(() {
                          registerAsMember = selection.first;
                          error = null;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: registerAsMember
                            ? buildMemberRegistrationForm()
                            : Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const _FieldLabel('Head of Family'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: head,
                                      validator: requiredText,
                                      decoration: const InputDecoration(
                                          hintText:
                                              'Enter head of family name'),
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
                                    const _FieldLabel(
                                        'Email (for PIN recovery)'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: email,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!RegExp(
                                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                            .hasMatch(v.trim())) {
                                          return 'Enter a valid email address';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: 'your@email.com'),
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
                                                controller:
                                                    _memberControllers[i],
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
                                      onChanged: (v) => setState(() {
                                        location = v;
                                        purok = null;
                                      }),
                                    ),
                                    const SizedBox(height: 14),
                                    const _FieldLabel('Assigned Purok'),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<int>(
                                      key: ValueKey('purok-$location'),
                                      initialValue: purok,
                                      decoration: InputDecoration(
                                        hintText: location == null
                                            ? 'Select barangay first'
                                            : 'Select purok',
                                      ),
                                      validator: (v) => v == null
                                          ? 'Please select a purok'
                                          : null,
                                      items: puroks
                                          .where((x) =>
                                              int.tryParse(x['location_id']
                                                  .toString()) ==
                                              location)
                                          .map((x) => DropdownMenuItem<int>(
                                                value: int.tryParse(
                                                    x['id'].toString()),
                                                child:
                                                    Text(x['name'].toString()),
                                              ))
                                          .toList(),
                                      onChanged: location == null
                                          ? null
                                          : (v) => setState(() => purok = v),
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
                                        child: Text(busy
                                            ? 'Registering…'
                                            : 'Register')),
                                    const SizedBox(height: 8),
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
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
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _sent = false;
  bool _busy = false;
  bool _hidePin = true;
  bool _hideConfirm = true;
  String? _error;

  Future<void> _sendCode() async {
    final emailVal = _email.text.trim();
    if (emailVal.isEmpty) {
      setState(() => _error = 'Please enter your registered email address.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
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
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await Api.req('POST', '/family/reset-password', auth: false, body: {
        'email': _email.text.trim(),
        'otp': _otp.text.trim(),
        'password': _pin.text,
        'password_confirmation': _confirm.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'PIN changed successfully. Please log in with your new PIN.')));
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
                            fillColor:
                                _sent ? const Color(0xfff8fafc) : Colors.white,
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
                            buildCounter: (_,
                                    {required currentLength,
                                    required isFocused,
                                    maxLength}) =>
                                null,
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
                            buildCounter: (_,
                                    {required currentLength,
                                    required isFocused,
                                    maxLength}) =>
                                null,
                            decoration: InputDecoration(
                              hintText: '6-digit PIN',
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _hideConfirm = !_hideConfirm),
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
                          onPressed:
                              _busy ? null : (_sent ? _resetPin : _sendCode),
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
                                    color: _blue, fontWeight: FontWeight.w600)),
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
