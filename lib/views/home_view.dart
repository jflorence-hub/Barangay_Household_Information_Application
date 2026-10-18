part of '../main.dart';

class FamilyHome extends StatefulWidget {
  const FamilyHome({super.key});

  @override
  State<FamilyHome> createState() => _FamilyHomeState();
}

class _FamilyHomeState extends State<FamilyHome> {
  int tab = 0;
  Timer? _announcementTimer;

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
              child: const Text('Log out',
                  style: TextStyle(color: Colors.red))),
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

  Future<void> _checkAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSeen = prefs.getInt('last_announcement_id') ?? 0;
      final data = await Api.req('GET', '/family/announcements');
      final list = (data['announcements'] as List? ?? []);
      if (list.isEmpty) return;
      // Find announcements newer than lastSeen
      final newOnes = list
          .where((a) => (a['id'] as int? ?? 0) > lastSeen)
          .toList();
      if (newOnes.isEmpty || !mounted) return;
      // Update last_announcement_id to max id seen
      final maxId = list
          .map<int>((a) => a['id'] as int? ?? 0)
          .reduce((a, b) => a > b ? a : b);
      await prefs.setInt('last_announcement_id', maxId);
      // Show a dialog for each new announcement
      for (final ann in newOnes) {
        if (!mounted) break;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(ann['title']?.toString() ?? 'Announcement'),
            content: Text(ann['body']?.toString() ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      // Silently ignore network/auth errors
    }
  }

  @override
  void initState() {
    super.initState();
    // Check immediately on load
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAnnouncements());
    // Then poll every 30 seconds
    _announcementTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAnnouncements(),
    );
  }

  @override
  void dispose() {
    _announcementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
      appBar: AppBar(
          titleSpacing: 16,
          title: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.house_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('My Home',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          actions: [
            IconButton(
              tooltip: 'Announcements',
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => _checkAnnouncements(),
            ),
          ]),
      body: IndexedStack(index: tab, children: [
        const RecordsPage(),
        const UpcomingDistributionPage(),
        ProfilePage(onLogout: _logout),
        const MessagesPage(),
      ]),
      bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (v) => setState(() => tab = v),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.history), label: 'My Records'),
            NavigationDestination(
                icon: Icon(Icons.event), label: 'Schedule'),
            NavigationDestination(
                icon: Icon(Icons.person_outline), label: 'Profile'),
            NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          ]));
}

