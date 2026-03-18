import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color _primaryColor = Color(0xFFBFA18E);

class ClubDetailScreen extends StatefulWidget {
  const ClubDetailScreen({super.key});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> with SingleTickerProviderStateMixin {
  int? _clubId;
  Map<String, dynamic>? _club;
  bool _isLoading = true;
  String? _error;
  
  int? _currentUserId;
  bool _isLeader = false;
  bool _isMember = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_clubId == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['id'] != null) {
        _clubId = args['id'];
        _fetchData();
      } else {
        setState(() {
          _error = 'Invalid club ID';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final userResponse = await ApiService().getUserData();
    if (userResponse != null) {
      _currentUserId = userResponse['id'];
    }

    final response = await ApiService().getClubDetail(_clubId!);
    if (!mounted) return;

    if (response['success']) {
      final data = response['data'];
      _checkRoles(data);
      setState(() {
        _club = data;
        _isLoading = false;
        _error = null;
      });
    } else {
      setState(() {
        _error = response['message'];
        _isLoading = false;
      });
    }
  }

  void _checkRoles(Map<String, dynamic> data) {
    _isMember = false;
    _isLeader = false;
    if (_currentUserId == null) return;
    
    final members = data['members'] as List<dynamic>? ?? [];
    for (var m in members) {
      if (m['studentId'] == _currentUserId) {
        _isMember = true;
        if (m['role'] == 'Leader') {
          _isLeader = true;
        }
        break;
      }
    }
  }

  Future<void> _joinClub() async {
    final res = await ApiService().joinClub(_clubId!);
    if (!mounted) return;
    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined club successfully!')));
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  Future<void> _createEvent() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final dateController = TextEditingController(); // Simple YYYY-MM-DD for demo

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await ApiService().createClubEvent(
                _clubId!,
                titleController.text,
                descController.text,
                dateController.text.isNotEmpty ? dateController.text : null,
              );
              if (res['success']) {
                _fetchData();
              } else {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _manageMemberAction(int studentId, String action) async {
    final res = await ApiService().manageClubMember(_clubId!, studentId, action);
    if (!mounted) return;
    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Member $action successful')));
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: _primaryColor),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _club == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: _primaryColor),
        body: Center(child: Text(_error ?? 'Error loading club')),
      );
    }

    final members = _club!['members'] as List<dynamic>? ?? [];
    final events = _club!['events'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_club!['name'] ?? 'Club Details'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _club!['avatarUrl'] != null ? NetworkImage(_club!['avatarUrl']) : null,
                  backgroundColor: _primaryColor.withValues(alpha: 0.2),
                  child: _club!['avatarUrl'] == null ? const Icon(Icons.group, size: 40, color: _primaryColor) : null,
                ),
                const SizedBox(height: 12),
                Text(_club!['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_club!['description'] ?? '', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 16),
                if (!_isMember)
                  ElevatedButton(
                    onPressed: _joinClub,
                    style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                    child: const Text('Join Club'),
                  )
                else
                  Chip(
                    label: Text('You are a ${_isLeader ? "Leader" : "Member"}'),
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          
          TabBar(
            controller: _tabController,
            labelColor: _primaryColor,
            indicatorColor: _primaryColor,
            tabs: const [
              Tab(text: 'Events'),
              Tab(text: 'Members'),
            ],
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Events Tab
                Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final ev = events[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(ev['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(ev['description'] ?? ''),
                            trailing: ev['eventDate'] != null ? Text(ev['eventDate'].toString().split('T').first) : null,
                          ),
                        );
                      },
                    ),
                    if (_isLeader)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          backgroundColor: _primaryColor,
                          onPressed: _createEvent,
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      )
                  ],
                ),
                
                // Members Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final m = members[index];
                    final isMe = m['studentId'] == _currentUserId;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _primaryColor.withValues(alpha: 0.2),
                          child: const Icon(Icons.person, color: _primaryColor),
                        ),
                        title: Text(m['studentName'] ?? 'Unknown'),
                        subtitle: Text(m['role'] ?? 'Member', style: TextStyle(color: m['role'] == 'Leader' ? Colors.orange : Colors.grey)),
                        trailing: _isLeader && !isMe
                            ? PopupMenuButton<String>(
                                onSelected: (val) => _manageMemberAction(m['studentId'], val),
                                itemBuilder: (context) => [
                                  if (m['role'] == 'Member') const PopupMenuItem(value: 'Promote', child: Text('Promote to Leader')),
                                  if (m['role'] == 'Leader') const PopupMenuItem(value: 'Demote', child: Text('Demote to Member')),
                                  const PopupMenuItem(value: 'Kick', child: Text('Remove from Club')),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
