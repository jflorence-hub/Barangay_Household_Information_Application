part of '../main.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  late Future<Map<String, dynamic>> future =
      Api.req('GET', '/family/distributions');
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        setState(() => future = Api.req('GET', '/family/distributions'));
      }
    });
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

  void _showDetail(BuildContext context, Map<String, dynamic> d,
      Map<String, dynamic> family, List members) {
    final statusStr = d['status']?.toString() ?? 'pending';
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
            const Text('Distribution Details',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 16),
            _FamilyDetailRow('Head of Family', family['head_name']?.toString()),
            _FamilyDetailRow(
                'Claimed By',
                d['claimed_by']?.toString().isNotEmpty == true
                    ? d['claimed_by'].toString()
                    : (d['receiver']?.toString().isNotEmpty == true
                        ? d['receiver'].toString()
                        : family['head_name']?.toString() ?? '—')),
            _FamilyDetailRow('Purok', family['purok']?.toString()),
            _FamilyDetailRow('Household Members',
                '${family['household_member'] ?? members.length} member(s)'),
            if (d['schedule'] is Map && d['schedule']['disaster_event'] is Map)
              _FamilyDetailRow('Disaster Event',
                  d['schedule']['disaster_event']['name']?.toString()),
            _FamilyDetailRow('Relief', d['resource']?['name']?.toString()),
            _FamilyDetailRow('Quantity', d['quantity']?.toString()),
            _FamilyDetailRow('Scan Status', statusStr),
            _FamilyDetailRow('Scanned By', d['scanned_by']?.toString()),
            _FamilyDetailRow('Location', d['location']?['name']?.toString()),
            _FamilyDetailRow('Date', _fmtDate(d['distribution_date'])),
            _FamilyDetailRow('Time', _fmtTime(d['distribution_date'])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext c) => FutureBuilder(
        future: future,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined,
                        color: _muted, size: 42),
                    const SizedBox(height: 12),
                    const Text('Your relief history could not be loaded.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _ink, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(s.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _muted, fontSize: 12)),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => setState(() =>
                          future = Api.req('GET', '/family/distributions')),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }
          final family = s.data!['family'] as Map<String, dynamic>? ?? {};
          final members = s.data!['household_members'] as List? ?? [];
          final rows = (s.data!['distributions'] as List? ?? []).where((d) {
            final status = d['status']?.toString().toLowerCase() ?? '';
            return status == 'completed' ||
                status == 'cancelled' ||
                status == 'canceled';
          }).toList();
          final completedCount =
              rows.where((d) => d['status']?.toString() == 'completed').length;
          final cancelledCount = rows.length - completedCount;
          return RefreshIndicator(
            onRefresh: () async => setState(
                () => future = Api.req('GET', '/family/distributions')),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                const _PageIntro(
                  icon: Icons.inventory_2_outlined,
                  eyebrow: 'Your household',
                  title: 'Relief history',
                  subtitle: 'Review past distributions and receipt details.',
                ),
                Row(
                  children: [
                    Expanded(
                      child: _RecordSummary(
                        label: 'Received',
                        count: completedCount,
                        icon: Icons.check_circle_outline,
                        color: const Color(0xff059669),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _RecordSummary(
                        label: 'Cancelled',
                        count: cancelledCount,
                        icon: Icons.cancel_outlined,
                        color: const Color(0xffdc2626),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (rows.isEmpty)
                  const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 38, color: Color(0xff94a3b8)),
                          SizedBox(height: 10),
                          Text('No distribution records yet',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: _ink)),
                          SizedBox(height: 4),
                          Text(
                            'Completed or cancelled relief distributions will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _muted, fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ...rows.map<Widget>((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => _showDetail(
                            c, Map<String, dynamic>.from(d), family, members),
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
                                child: const Icon(Icons.inventory_2_outlined,
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
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(d['status'])
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        d['status']?.toString() ?? 'pending',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: _statusColor(d['status']),
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
                      ),
                    )),
              ],
            ),
          );
        },
      );
}

class _RecordSummary extends StatelessWidget {
  const _RecordSummary({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xffe8edf5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count',
                    style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                Text(label,
                    style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ],
        ),
      );
}
