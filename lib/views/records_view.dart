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
            _FamilyDetailRow('Family Head', family['head_name']?.toString()),
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
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final family = s.data!['family'] as Map<String, dynamic>? ?? {};
          final members = s.data!['household_members'] as List? ?? [];
          final rows = (s.data!['distributions'] as List? ?? []).where((d) {
            final status = d['status']?.toString().toLowerCase() ?? '';
            return status == 'completed' ||
                status == 'cancelled' ||
                status == 'canceled';
          }).toList();
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d['resource']?['name']?.toString() ??
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
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _statusColor(d['status'])
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                      ))
                  .toList(),
            ),
          );
        },
      );
}
