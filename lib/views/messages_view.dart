part of '../main.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final text = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _timer;
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _recipient;
  bool _sending = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _timer =
        Timer.periodic(const Duration(seconds: 10), (_) => _loadMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollCtrl.dispose();
    text.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final result = await Api.req('GET', '/family/messages');
      final list = result['messages'] as List? ?? [];
      if (mounted) {
        setState(() {
          _messages = list.map((e) => e as Map<String, dynamic>).toList();
          _recipient = result['recipient'] as Map<String, dynamic>?;
          error = null;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  Future<void> send() async {
    if (text.text.trim().isEmpty || _sending || _recipient == null) return;
    setState(() => _sending = true);
    try {
      await Api.req('POST', '/family/messages',
          body: {'message': text.text.trim()});
      text.clear();
      await _loadMessages();
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } catch (_) {
      return '';
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day == today) return 'Today';
      if (day == yesterday) return 'Yesterday';
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
      return '';
    }
  }

  List<Map<String, dynamic>> _groupByDate() {
    final groups = <Map<String, dynamic>>[];
    String lastLabel = '';
    for (final msg in _messages) {
      final label = _formatDate(msg['created_at']?.toString());
      if (label != lastLabel) {
        groups.add({'type': 'date', 'label': label});
        lastLabel = label;
      }
      groups.add({'type': 'msg', 'data': msg});
    }
    return groups;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final grouped = _groupByDate();
    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xffe8edf5))),
          ),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xffdbeafe),
                  borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.groups_outlined, color: _blue, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _recipient?['name']?.toString() ?? 'No staff assigned',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                    _recipient == null
                        ? 'Contact the barangay office for assistance'
                        : 'Staff assigned to your Purok',
                    style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ]),
        ),
        // Messages list
        Expanded(
          child: grouped.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 56, color: Color(0xffcbd5e1)),
                      const SizedBox(height: 12),
                      Text(
                          _recipient == null
                              ? 'No active staff member is assigned to your Purok.'
                              : 'No messages yet. Write to your assigned staff below.',
                          style: const TextStyle(color: _muted)),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final item = grouped[index];
                    if (item['type'] == 'date') {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          const Expanded(child: Divider()),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xfff1f5f9),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(item['label']?.toString() ?? '',
                                style: const TextStyle(
                                    fontSize: 11, color: _muted)),
                          ),
                          const Expanded(child: Divider()),
                        ]),
                      );
                    }
                    final m = item['data'] as Map<String, dynamic>? ?? {};
                    final isSelf = m['sender_type'] == 'family' ||
                        m['sender_type'] == 'user';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: isSelf
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: isSelf
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: screenWidth * 0.72),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelf ? _blue : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(18),
                                      topRight: const Radius.circular(18),
                                      bottomLeft:
                                          Radius.circular(isSelf ? 18 : 4),
                                      bottomRight:
                                          Radius.circular(isSelf ? 4 : 18),
                                    ),
                                    border: isSelf
                                        ? null
                                        : Border.all(
                                            color: const Color(0xffe2e8f0)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2)),
                                    ],
                                  ),
                                  child: Text(
                                    m['message']?.toString() ?? '',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: isSelf ? Colors.white : _ink),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2, left: 4, right: 4),
                            child: Text(
                              _formatTime(m['created_at']?.toString()),
                              style:
                                  const TextStyle(fontSize: 10, color: _muted),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(error!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        // Compose area
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xffe8edf5))),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: text,
                enabled: _recipient != null && !_sending,
                maxLines: null,
                decoration: InputDecoration(
                    hintText: _recipient == null
                        ? 'Messaging is unavailable'
                        : 'Write to your assigned staff…',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sending || _recipient == null ? null : send,
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _blue))
                  : const Icon(Icons.send_rounded, color: _blue),
              style: IconButton.styleFrom(
                  backgroundColor: const Color(0xffeff6ff),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ]),
        ),
      ],
    );
  }
}

// --- Family QR Code Page ------------------------------------------------------
