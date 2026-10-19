part of '../main.dart';

class UpcomingDistributionPage extends StatefulWidget {
  const UpcomingDistributionPage({super.key});

  @override
  State<UpcomingDistributionPage> createState() =>
      _UpcomingDistributionPageState();
}

class _UpcomingDistributionPageState extends State<UpcomingDistributionPage> {
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

  String _fmtDate(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return 'Date not set';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  String _fmtTime(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } catch (_) {
      return '';
    }
  }

  Future<void> _confirmReceipt(
      Map<String, dynamic> distribution, String memberName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm receipt?'),
        content: Text(
          'Confirm that $memberName received this relief. This will record the receipt and update inventory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm received'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await Api.req(
        'POST',
        '/family/distributions/${distribution['id']}/confirm',
      );
      if (!mounted) return;
      setState(() {
        future = Api.req('GET', '/family/distributions');
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt recorded for $memberName.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not confirm receipt: ${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  void _showDetail(
    BuildContext context,
    Map<String, dynamic> d,
    Map<String, dynamic> family,
    List members,
    Map<String, dynamic>? authenticatedMember,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xffcbd5e1),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Upcoming Distribution',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 16),
            _FamilyDetailRow('Family Head', family['head_name']?.toString()),
            _FamilyDetailRow('Purok', family['purok']?.toString()),
            _FamilyDetailRow('Household Members',
                '${family['household_member'] ?? members.length} member(s)'),
            if (d['schedule'] is Map && d['schedule']['disaster_event'] is Map)
              _FamilyDetailRow('Disaster Event',
                  d['schedule']['disaster_event']['name']?.toString()),
            _FamilyDetailRow('Relief', distributionReliefName(d)),
            _FamilyDetailRow('Quantity', d['quantity']?.toString()),
            const _FamilyDetailRow('Scan Status', 'Pending'),
            _FamilyDetailRow(
                'Received By',
                d['claimed_by']?.toString() ??
                    authenticatedMember?['name']?.toString()),
            _FamilyDetailRow('Scanned By', d['scanned_by']?.toString()),
            _FamilyDetailRow('Location', d['location']?['name']?.toString()),
            _FamilyDetailRow('Date', _fmtDate(d['distribution_date'])),
            _FamilyDetailRow('Time', _fmtTime(d['distribution_date'])),
            if (authenticatedMember != null &&
                d['status']?.toString() == 'pending' &&
                d['excluded'] != true &&
                d['excluded']?.toString() != '1' &&
                d['claim_window_open'] == true) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _confirmReceipt(
                  d,
                  authenticatedMember['name']?.toString() ?? 'Member',
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm receipt'),
              ),
            ] else if (authenticatedMember != null &&
                d['status']?.toString() == 'pending' &&
                d['excluded'] != true &&
                d['excluded']?.toString() != '1') ...[
              const SizedBox(height: 12),
              Text(
                d['claim_window_message']?.toString() ??
                    'Receipt confirmation is not currently available.',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, color: _muted, size: 42),
                  const SizedBox(height: 12),
                  const Text(
                    'Upcoming relief could not be loaded.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted, fontSize: 12)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => setState(
                        () => future = Api.req('GET', '/family/distributions')),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        final family = snapshot.data?['family'] as Map<String, dynamic>? ?? {};
        final members = snapshot.data?['household_members'] as List? ?? [];
        final authenticatedMember =
            snapshot.data?['authenticated_member'] as Map<String, dynamic>?;

        final rows =
            (snapshot.data?['distributions'] as List? ?? []).where((d) {
          final status = d['status']?.toString().toLowerCase() ?? '';
          final isExcluded =
              d['excluded'] == true || d['excluded']?.toString() == '1';
          return status == 'pending' || isExcluded;
        }).toList();

        if (rows.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: const [
              SizedBox(height: 12),
              _PageIntro(
                icon: Icons.event_available_outlined,
                eyebrow: 'Stay informed',
                title: 'Upcoming relief',
                subtitle:
                    'See the latest distribution schedule for your family.',
              ),
              SizedBox(height: 36),
              Icon(Icons.event_busy_outlined, size: 52, color: _muted),
              SizedBox(height: 14),
              Text(
                'Nothing scheduled just yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _ink, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                'Pull down to refresh. New relief schedules will show here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              future = Api.req('GET', '/family/distributions');
            });
            await future;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              const _PageIntro(
                icon: Icons.event_available_outlined,
                eyebrow: 'Stay informed',
                title: 'Upcoming relief',
                subtitle:
                    'Tap a schedule to see details and claim information.',
              ),
              ...rows.map<Widget>((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _showDetail(
                          context,
                          Map<String, dynamic>.from(d),
                          family,
                          members,
                          authenticatedMember),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                  color: const Color(0xfff0fdfa),
                                  borderRadius: BorderRadius.circular(13)),
                              child: const Icon(Icons.volunteer_activism,
                                  color: Color(0xff0d9488)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    distributionReliefName(
                                        Map<String, dynamic>.from(d)),
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
                                  Builder(builder: (context) {
                                    final isExcluded = d['excluded'] == true ||
                                        d['excluded']?.toString() == '1';
                                    final reason =
                                        d['exclusion_reason']?.toString() ?? '';
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: (isExcluded
                                                    ? const Color(0xffdc2626)
                                                    : const Color(0xfff59e0b))
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isExcluded ? 'Excluded' : 'Pending',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isExcluded
                                                  ? const Color(0xffdc2626)
                                                  : const Color(0xfff59e0b),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (isExcluded && reason.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 3),
                                            child: Text(reason,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xff94a3b8))),
                                          ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Color(0xff94a3b8)),
                          ]),
                        ),
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

// â”€â”€â”€ Family Detail Row helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                    fontSize: 13, fontWeight: FontWeight.w600, color: _ink))),
      ]),
    );
  }
}
