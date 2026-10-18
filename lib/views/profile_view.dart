part of '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onLogout});
  final VoidCallback onLogout;

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
          final members = s.data!['household_members'] as List? ?? [];
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
                        (f['head_name']?.toString() ?? 'F').isNotEmpty
                            ? f['head_name']
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
                      f['head_name']?.toString() ?? 'Family',
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
                          'Head of Family', f['head_name']?.toString()),
                      _FamilyDetailRow(
                          'Family ID', f['family_id']?.toString()),
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
                const SizedBox(height: 16),
                // Household Members card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Household Members',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _ink)),
                        const SizedBox(height: 12),
                        if (members.isEmpty)
                          const Text('No household members recorded.',
                              style:
                                  TextStyle(color: _muted, fontSize: 13))
                        else
                          ...members.map<Widget>((m) {
                            final idx =
                                m['number']?.toString() ?? '';
                            final name = m['name']?.toString() ??
                                'Member #$idx';
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    child: Text('$idx.',
                                        style: const TextStyle(
                                            fontSize: 13, color: _muted)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(name,
                                      style: const TextStyle(
                                          fontSize: 13, color: _ink)),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Log Out button
                OutlinedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout,
                      color: Colors.red, size: 18),
                  label: const Text('Log Out',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
}

