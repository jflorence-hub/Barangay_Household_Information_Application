part of '../main.dart';

class _FamilyAnnouncementsSheet extends StatefulWidget {
  const _FamilyAnnouncementsSheet();

  @override
  State<_FamilyAnnouncementsSheet> createState() =>
      _FamilyAnnouncementsSheetState();
}

class _FamilyAnnouncementsSheetState extends State<_FamilyAnnouncementsSheet> {
  late Future<List<Map<String, dynamic>>> _future = _loadAnnouncements();

  Future<List<Map<String, dynamic>>> _loadAnnouncements() async {
    final result = await Api.req('GET', '/family/announcements');
    final announcements = result['announcements'] as List? ?? [];
    return announcements
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return '';
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
      'Dec',
    ];
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final meridiem = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $meridiem';
  }

  Future<void> _refresh() async {
    final next = _loadAnnouncements();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.82,
          child: Container(
            decoration: const BoxDecoration(
              color: _canvas,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xffdbeafe),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.campaign_rounded,
                            color: _blue, size: 23),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Announcements',
                                style: TextStyle(
                                    color: _ink,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800)),
                            SizedBox(height: 2),
                            Text('Updates from your barangay',
                                style: TextStyle(color: _muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close announcements',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud_off_outlined,
                                    color: _muted, size: 42),
                                const SizedBox(height: 12),
                                const Text('Announcements could not be loaded',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _ink,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(snapshot.error.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: _muted, fontSize: 12)),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: () => setState(
                                      () => _future = _loadAnnouncements()),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final items = snapshot.data ?? [];
                      if (items.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            children: const [
                              SizedBox(height: 48),
                              Icon(Icons.campaign_outlined,
                                  color: Color(0xff94a3b8), size: 46),
                              SizedBox(height: 12),
                              Text('No announcements yet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: _ink,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(height: 5),
                              Text(
                                  'Barangay updates will appear here when they are shared.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                      height: 1.4)),
                            ],
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffeff6ff),
                                            borderRadius:
                                                BorderRadius.circular(11),
                                          ),
                                          child: const Icon(
                                              Icons.campaign_outlined,
                                              color: _blue,
                                              size: 19),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            item['title']?.toString() ??
                                                'Announcement',
                                            style: const TextStyle(
                                                color: _ink,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item['body']?.toString() ?? '',
                                      style: const TextStyle(
                                          color: _ink,
                                          fontSize: 13,
                                          height: 1.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule_rounded,
                                            color: _muted, size: 14),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            _formatDate(item['created_at']),
                                            style: const TextStyle(
                                                color: _muted, fontSize: 11),
                                          ),
                                        ),
                                        Text(
                                          item['sender']?['name']?.toString() ??
                                              'Barangay office',
                                          style: const TextStyle(
                                              color: _blue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
