import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color _primaryColor = Color(0xFFBFA18E);

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  bool _isLoading = true;
  List<dynamic> _clubs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchClubs();
  }

  Future<void> _fetchClubs() async {
    final response = await ApiService().getClubs();
    if (!mounted) return;
    if (response['success']) {
      setState(() {
        _clubs = response['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response['message'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clubs'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _clubs.isEmpty
                  ? const Center(child: Text('No clubs available.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _clubs.length,
                      itemBuilder: (context, index) {
                        final club = _clubs[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: club['avatarUrl'] != null
                                  ? NetworkImage(club['avatarUrl'])
                                  : null,
                              backgroundColor: _primaryColor.withValues(alpha: 0.2),
                              child: club['avatarUrl'] == null
                                  ? const Icon(Icons.group, color: _primaryColor)
                                  : null,
                            ),
                            title: Text(
                              club['name'] ?? 'Unknown Club',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              club['description'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/club_detail',
                                arguments: {'id': club['id']},
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
