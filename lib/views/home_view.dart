part of '../main.dart';

class FamilyHome extends StatefulWidget {
  const FamilyHome({super.key});

  @override
  State<FamilyHome> createState() => _FamilyHomeState();
}

class _FamilyHomeState extends State<FamilyHome> {
  int tab = 0;

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
              child:
                  const Text('Log out', style: TextStyle(color: Colors.red))),
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

  void _openAnnouncements() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FamilyAnnouncementsSheet(),
    );
  }

  @override
  Widget build(BuildContext c) {
    const titles = [
      'Relief history',
      'Upcoming relief',
      'Family profile',
      'Messages',
      'Family QR',
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: _blue, borderRadius: BorderRadius.circular(12)),
            child:
                const Icon(Icons.house_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Family Portal',
                  style: TextStyle(
                      fontSize: 11,
                      color: _muted,
                      fontWeight: FontWeight.w600)),
              Text(titles[tab],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
        ]),
        actions: [
          IconButton(
            tooltip: 'Announcements',
            icon: const Icon(Icons.campaign_outlined),
            onPressed: _openAnnouncements,
          ),
        ],
      ),
      body: IndexedStack(index: tab, children: [
        const RecordsPage(),
        const UpcomingDistributionPage(),
        ProfilePage(onLogout: _logout),
        const MessagesPage(),
        const FamilyQrPage(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2_rounded),
              label: 'Records'),
          NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event_available_rounded),
              label: 'Schedule'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages'),
          NavigationDestination(
              icon: Icon(Icons.qr_code_2_outlined),
              selectedIcon: Icon(Icons.qr_code_2_rounded),
              label: 'My QR'),
        ],
      ),
    );
  }
}
