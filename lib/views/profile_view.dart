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
                    const Text(
                      'Your family profile could not be loaded.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: _ink, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () =>
                          setState(() => future = Api.req('GET', '/family/me')),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!s.hasData) {
            return const Center(child: Text('Family profile is unavailable.'));
          }
          final f = s.data!['family'] as Map<String, dynamic>? ?? {};
          final members = s.data!['household_members'] as List? ?? [];
          return RefreshIndicator(
            onRefresh: () async =>
                setState(() => future = Api.req('GET', '/family/me')),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _PageIntro(
                  icon: Icons.groups_2_outlined,
                  eyebrow: 'Your household',
                  title: 'Family profile',
                  subtitle: 'Your household details and registered members.',
                ),
                // Avatar section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 20),
                    child: Center(
                      child: Column(children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xffdbeafe),
                          child: Text(
                            (f['head_name']?.toString() ?? 'F').isNotEmpty
                                ? f['head_name'].toString()[0].toUpperCase()
                                : 'F',
                            style: const TextStyle(
                                color: _blue,
                                fontSize: 28,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          f['head_name']?.toString() ?? 'Family',
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: _ink),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                              color: const Color(0xffeff6ff),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xffbfdbfe))),
                          child: Text(
                            f['family_id']?.toString() ?? '',
                            style: const TextStyle(
                                color: _blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.3),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Details card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _FamilyDetailRow(
                          'Head of Family', f['head_name']?.toString()),
                      _FamilyDetailRow('Family ID', f['family_id']?.toString()),
                      _FamilyDetailRow('Household Members',
                          '${f['household_member'] ?? '—'} member(s)'),
                      _FamilyDetailRow(
                          'Purok', f['purok']?['name']?.toString()),
                      _FamilyDetailRow('Barangay / Location',
                          f['location']?['name']?.toString()),
                      _FamilyDetailRow('Status', f['status']?.toString()),
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
                              style: TextStyle(color: _muted, fontSize: 13))
                        else
                          ...members.map<Widget>((m) {
                            final idx = m['number']?.toString() ?? '';
                            final name =
                                m['name']?.toString() ?? 'Member #$idx';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
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
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
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
