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
  bool _isPending = false;

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
    _isPending = false;
    if (_currentUserId == null) return;
    
    final members = data['members'] as List<dynamic>? ?? [];
    for (var m in members) {
      if (m['studentId'] == _currentUserId) {
        if (m['role'] == 'Pending') {
          _isPending = true;
        } else {
          _isMember = true;
          if (m['role'] == 'Leader') {
            _isLeader = true;
          }
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
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    const Color textColor = Color(0xFF1D2939);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create New Event',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryColor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Event Title',
                      prefixIcon: const Icon(Icons.title, color: _primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Icon(Icons.description, color: _primaryColor),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setModalState(() => selectedDate = date);
                            }
                          },
                          icon: const Icon(Icons.calendar_today, color: _primaryColor),
                          label: Text(
                            selectedDate == null ? 'Select Date' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                            style: const TextStyle(color: textColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setModalState(() => selectedTime = time);
                            }
                          },
                          icon: const Icon(Icons.access_time, color: _primaryColor),
                          label: Text(
                            selectedTime == null ? 'Select Time' : selectedTime!.format(context),
                            style: const TextStyle(color: textColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter event title')));
                          return;
                        }
                        
                        String? isoDate;
                        if (selectedDate != null) {
                          var finalDt = selectedDate!;
                          if (selectedTime != null) {
                            finalDt = DateTime(finalDt.year, finalDt.month, finalDt.day, selectedTime!.hour, selectedTime!.minute);
                          }
                          isoDate = finalDt.toIso8601String();
                        }

                        Navigator.pop(ctx);
                        final res = await ApiService().createClubEvent(
                          _clubId!,
                          titleController.text,
                          descController.text,
                          isoDate,
                        );
                        if (res['success']) {
                          _fetchData();
                        } else {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Create Event', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmAndManageMemberAction(int studentId, String studentName, String action) async {
    if (action == 'Kick') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Removal'),
          content: Text('Are you sure you want to remove $studentName from the club?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    _manageMemberAction(studentId, action);
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
                if (_isPending)
                  Chip(
                    label: const Text('Pending Approval'),
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  )
                else if (!_isMember)
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
                        subtitle: Text(m['role'] ?? 'Member', style: TextStyle(color: m['role'] == 'Leader' ? Colors.orange : (m['role'] == 'Pending' ? Colors.grey : Colors.green))),
                        trailing: _isLeader && !isMe
                            ? PopupMenuButton<String>(
                                onSelected: (val) => _confirmAndManageMemberAction(m['studentId'], m['studentName'] ?? 'Unknown', val),
                                itemBuilder: (context) => [
                                  if (m['role'] == 'Pending') const PopupMenuItem(value: 'Approve', child: Text('Approve Join Request')),
                                  if (m['role'] == 'Pending') const PopupMenuItem(value: 'Reject', child: Text('Reject Request')),
                                  if (m['role'] == 'Member') const PopupMenuItem(value: 'Promote', child: Text('Promote to Leader')),
                                  if (m['role'] == 'Leader') const PopupMenuItem(value: 'Demote', child: Text('Demote to Member')),
                                  if (m['role'] != 'Pending') const PopupMenuItem(value: 'Kick', child: Text('Remove from Club')),
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
