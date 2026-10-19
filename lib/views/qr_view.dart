part of '../main.dart';

class FamilyQrPage extends StatefulWidget {
  const FamilyQrPage({super.key});
  @override
  State<FamilyQrPage> createState() => _FamilyQrPageState();
}

class _FamilyQrPageState extends State<FamilyQrPage> {
  Map<String, dynamic>? _family;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await Api.req('GET', '/family/me');
      if (mounted) {
        setState(() {
          _family = result['family'] as Map<String, dynamic>?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrCode = _family?['qr_code']?.toString() ?? '';
    final familyName = _family?['head_name']?.toString() ?? 'My Family';
    final familyId = _family?['family_id']?.toString() ?? '';

    return ColoredBox(
      color: const Color(0xfff8fafc),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: const Text('Retry')),
                ]))
              : qrCode.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.qr_code_2_rounded,
                                color: Color(0xff94a3b8), size: 54),
                            const SizedBox(height: 12),
                            const Text(
                              'Family QR code unavailable',
                              style: TextStyle(
                                  color: _ink,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Contact your barangay administrator for help.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: _muted, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                        child: Column(
                          children: [
                            const _PageIntro(
                              icon: Icons.qr_code_2_rounded,
                              eyebrow: 'Quick check-in',
                              title: 'Your family QR',
                              subtitle:
                                  'Present this code to staff when collecting relief goods.',
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border:
                                    Border.all(color: const Color(0xffe8edf5)),
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0xff0f172a)
                                          .withValues(alpha: 0.05),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6))
                                ],
                              ),
                              child: QrImageView(
                                data: qrCode,
                                version: QrVersions.auto,
                                size: 230,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xffe2e8f0)),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Family QR code',
                                    style: TextStyle(
                                        fontSize: 12, color: Color(0xff64748b)),
                                  ),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    qrCode,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff0f172a),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(familyName,
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: _ink,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(familyId,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xff64748b))),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xffeff6ff),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(children: [
                                Icon(Icons.info_outline,
                                    color: Color(0xff2563eb), size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                  'Show this QR code to the distribution staff when collecting your relief goods.',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xff1e40af)),
                                )),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
