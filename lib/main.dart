import 'dart:async';
import 'package:flutter/material.dart';
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
        scaffoldBackgroundColor: const Color(0xfff1f5f9),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xffffffff),
            foregroundColor: Color(0xff0f172a),
            elevation: 0),
        cardTheme: const CardThemeData(
            color: Color(0xffffffff),
            elevation: 1,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
        inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xffffffff),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)))),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14))),
      ),
      home: const LoginPage());
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phone = TextEditingController(), pw = TextEditingController();
  String? error;
  bool busy = false;

  Future<void> login() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final r = await Api.req('POST', '/family/login',
          auth: false, body: {'phone': phone.text.trim(), 'pin': pw.text});
      await Api.saveToken(r['token']);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FamilyHome()),
        );
      }
    } catch (e) {
      if (mounted)
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) => AuthScaffold(
        title: 'Family Login',
        children: [
          TextField(
            controller: phone,
            decoration: const InputDecoration(
              labelText: 'Family ID or phone number',
              hintText: 'FAM-XXXXXXXX or registered phone',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pw,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Family PIN',
              hintText: 'Enter your 4–6 digit PIN',
              border: OutlineInputBorder(),
            ),
          ),
          if (error != null)
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
            ),
          FilledButton(
            onPressed: busy ? null : login,
            child: Text(busy ? 'Logging in…' : 'Login'),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            ),
            child: const Text('Register family'),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPage()),
            ),
            child: const Text('Forgot password?'),
          ),
        ],
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
  final members = TextEditingController(text: '1');
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

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (purok == null || location == null) {
      setState(() =>
          error = 'Please select your assigned purok and barangay/location.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (pw.text != confirm.text) throw Exception('PINs do not match.');
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
          'household_member': int.parse(members.text),
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
          String? Function(String?)? validator}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
              controller: c,
              obscureText: secret,
              keyboardType: keyboard,
              validator: validator ??
                  (v) => (v == null || v.trim().isEmpty)
                      ? 'This field is required'
                      : null,
              decoration: InputDecoration(
                  labelText: label, border: const OutlineInputBorder())));

  String? requiredText(String? v) =>
      v == null || v.trim().isEmpty ? 'This field is required' : null;

  @override
  Widget build(BuildContext c) =>
      AuthScaffold(title: 'Register Family', children: [
        Form(
            key: formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  field(family, 'Family Name (e.g. Dela Cruz Family)'),
                  field(head, 'Head of Family'),
                  field(phone, 'Phone Number', keyboard: TextInputType.phone,
                      validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Phone number is required';
                    if (v.trim().length < 7)
                      return 'Enter a valid phone number';
                    return null;
                  }),
                  field(email, 'Email (for password recovery)',
                      keyboard: TextInputType.emailAddress, validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email is required';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(v.trim()))
                      return 'Enter a valid email address';
                    return null;
                  }),
                  field(address, 'Address'),
                  field(members, 'Household Members',
                      keyboard: TextInputType.number, validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1)
                      return 'Enter at least 1 household member';
                    return null;
                  }),
                  DropdownButtonFormField<int>(
                    initialValue: purok,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Purok',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null ? 'Please select a purok' : null,
                    items: puroks
                        .map((x) => DropdownMenuItem<int>(
                              value: int.tryParse(x['id'].toString()),
                              child: Text(x['name'].toString()),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => purok = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: location,
                    decoration: const InputDecoration(
                      labelText: 'Barangay / Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null ? 'Please select a barangay/location' : null,
                    items: locations
                        .map((x) => DropdownMenuItem<int>(
                              value: int.tryParse(x['id'].toString()),
                              child: Text(x['name'].toString()),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => location = v),
                  ),
                  const SizedBox(height: 12),
                  field(pw, 'Family PIN (4–6 digits)',
                      secret: true,
                      keyboard: TextInputType.number, validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'PIN is required';
                    if (!RegExp(r'^\d{4,6}$').hasMatch(v.trim()))
                      return 'PIN must be 4–6 digits';
                    return null;
                  }),
                  field(confirm, 'Confirm Family PIN',
                      secret: true,
                      keyboard: TextInputType.number, validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Please confirm your PIN';
                    if (v != pw.text) return 'PINs do not match';
                    return null;
                  }),
                  if (error != null)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(error!,
                            style: const TextStyle(color: Colors.red))),
                  FilledButton(
                      onPressed: busy ? null : submit,
                      child: Text(busy ? 'Registering…' : 'Register')),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to login'))
                ]))
      ]);
}

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final email = TextEditingController(),
      otp = TextEditingController(),
      pw = TextEditingController(),
      confirm = TextEditingController();
  bool sent = false, busy = false;
  String? error;

  Future<void> send() async {
    try {
      setState(() {
        busy = true;
        error = null;
      });
      await Api.req('POST', '/family/forgot-password',
          auth: false, body: {'email': email.text.trim()});
      if (mounted) setState(() => sent = true);
    } catch (e) {
      if (mounted)
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> reset() async {
    try {
      setState(() {
        busy = true;
        error = null;
      });
      await Api.req('POST', '/family/reset-password', auth: false, body: {
        'email': email.text.trim(),
        'otp': otp.text.trim(),
        'password': pw.text,
        'password_confirmation': confirm.text
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed. Please log in.')));
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
      }
    } catch (e) {
      if (mounted)
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) =>
      AuthScaffold(title: 'Reset Password', children: [
        TextField(
            controller: email,
            decoration: const InputDecoration(
                labelText: 'Registered email', border: OutlineInputBorder())),
        if (sent) ...[
          const SizedBox(height: 10),
          TextField(
              controller: otp,
              decoration: const InputDecoration(
                  labelText: '6-digit email code',
                  border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(
              controller: pw,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'New Family PIN (4–6 digits)',
                  border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(
              controller: confirm,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Confirm new Family PIN',
                  border: OutlineInputBorder()))
        ],
        if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red)),
        FilledButton(
            onPressed: busy ? null : (sent ? reset : send),
            child: Text(busy
                ? 'Please wait…'
                : sent
                    ? 'Save new password'
                    : 'Send reset code')),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to login'))
      ]);
}

class FamilyHome extends StatefulWidget {
  const FamilyHome({super.key});

  @override
  State<FamilyHome> createState() => _FamilyHomeState();
}

class _FamilyHomeState extends State<FamilyHome> {
  int tab = 0;

  @override
  Widget build(BuildContext c) => Scaffold(
      appBar: AppBar(title: const Text('Barangay Household Portal'), actions: [
        IconButton(
            onPressed: () async {
              await Api.req('POST', '/family/logout');
              await Api.clearToken();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout))
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
              children: rows
                  .map<Widget>((d) => Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: Text(d['resource']?['name']?.toString() ??
                              'Relief not assigned'),
                          subtitle: Text(
                              '${reliefQuantitySummary(Map<String, dynamic>.from(d))}\nDate: ${d['distribution_date'] ?? 'Not scheduled'}'),
                          trailing: Text(d['status']?.toString() ?? 'Pending'),
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

  String fmt(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'Date not set';
    }

    try {
      final dt = DateTime.parse(value.toString()).toLocal();

      return '${dt.year}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
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
            padding: const EdgeInsets.all(12),
            children: [
              Card(
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

              ...rows.map<Widget>((d) {
                final status =
                    (d['status'] ?? 'pending').toString();

                final details = reliefQuantitySummary(
                  Map<String, dynamic>.from(d),
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.volunteer_activism,
                            color: Color(0xff2563eb),
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Flexible details area.
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['resource']?['name']
                                        ?.toString() ??
                                    'Relief not assigned',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium,
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Date & time: '
                                '${fmt(d['distribution_date'])}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),

                              const SizedBox(height: 4),

                              // Quantity and additional relief.
                              Text(
                                details,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Compact status section.
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xff2563eb),
                              size: 20,
                            ),

                            const SizedBox(height: 3),

                            Text(
                              'Included',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall,
                            ),

                            const SizedBox(height: 3),

                            Text(
                              status,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                f['family_name']?.toString() ?? 'Family',
                style: Theme.of(c).textTheme.headlineMedium,
              ),
              ListTile(
                title: const Text('Family ID'),
                subtitle: Text(f['family_id']?.toString() ?? '—'),
              ),
              ListTile(
                title: const Text('Family head'),
                subtitle: Text(f['head_name']?.toString() ?? '—'),
              ),
              ListTile(
                title: const Text('Household members'),
                subtitle: Text('${f['household_member'] ?? '—'}'),
              ),
              ListTile(
                title: const Text('Purok'),
                subtitle: Text(f['purok']?['name']?.toString() ?? '—'),
              ),
              ListTile(
                title: const Text('Barangay / Location'),
                subtitle: Text(f['location']?['name']?.toString() ?? '—'),
              ),
            ],
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
  late Future<Map<String, dynamic>> future = Api.req('GET', '/family/messages');
  String? error;

  Future<void> send() async {
    if (text.text.trim().isEmpty) return;
    try {
      await Api.req(
        'POST',
        '/family/messages',
        body: {'message': text.text.trim()},
      );
      text.clear();
      setState(() {
        error = null;
        future = Api.req('GET', '/family/messages');
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext c) => Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: future,
              builder: (c, s) {
                if (!s.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final rows = s.data!['messages'] as List? ?? [];
                return ListView(
                  children: rows
                      .map<Widget>((m) => ListTile(
                            leading: Icon(
                              m['sender_type'] == 'family'
                                  ? Icons.person
                                  : Icons.admin_panel_settings,
                            ),
                            title: Text(m['message'].toString()),
                            subtitle: Text(
                              '${m['sender_type']} • ${m['created_at']}',
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ),
          if (error != null)
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: text,
                    decoration: const InputDecoration(
                      hintText: 'Message administrator…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(onPressed: send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      );
}
