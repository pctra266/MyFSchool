import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _backgroundColor = Color(0xFFF2F4F7);
const Color _textColor = Color(0xFF1D2939);
const Color _accentColor = Color(0xFFD9D1CA);

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _selectedDayIndex = 0;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  bool _isLoading = true;
  String _errorMessage = '';
  List<dynamic> _allTimetables = [];
  List<Map<String, String>> _classes = [];

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    try {
      final response = await ApiService().getTimetable();
      if (mounted) {
        if (response['success']) {
          setState(() {
            _allTimetables = response['data'] ?? [];
            _filterClassesForDay();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Failed to load timetable';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterClassesForDay() {
    final selectedDayName = _days[_selectedDayIndex];
    String fullDayName = '';
    switch (selectedDayName) {
      case 'Mon': fullDayName = 'Monday'; break;
      case 'Tue': fullDayName = 'Tuesday'; break;
      case 'Wed': fullDayName = 'Wednesday'; break;
      case 'Thu': fullDayName = 'Thursday'; break;
      case 'Fri': fullDayName = 'Friday'; break;
      case 'Sat': fullDayName = 'Saturday'; break;
    }

    final filtered = _allTimetables.where((t) => t['dayOfWeek'] == fullDayName).toList();

    _classes = filtered.map<Map<String, String>>((t) {
      String formatTime(String timeStr) {
        if (timeStr.length >= 5) {
          return timeStr.substring(0, 5);
        }
        return timeStr;
      }
      return {
        'startTime': formatTime(t['startTime']?.toString() ?? ''),
        'endTime': formatTime(t['endTime']?.toString() ?? ''),
        'subject': t['subjectName']?.toString() ?? 'N/A',
        'room': t['room']?.toString() ?? 'N/A',
        'teacher': t['teacherName']?.toString() ?? 'TBD',
      };
    }).toList();

    _classes.sort((a, b) => a['startTime']!.compareTo(b['startTime']!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _primaryColor))
                : _errorMessage.isNotEmpty
                    ? Center(child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                      ))
                    : _classes.isEmpty
                        ? const Center(child: Text('No classes for this day', style: TextStyle(fontSize: 16, color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                            itemCount: _classes.length,
                            itemBuilder: (context, index) {
                              final cls = _classes[index];
                              final isLast = index == _classes.length - 1;
                              return _TimelineItem(
                                data: cls,
                                isLast: isLast,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      color: _primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_days.length, (index) {
          final isSelected = index == _selectedDayIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
                _filterClassesForDay();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Text(
                _days[index],
                style: TextStyle(
                  color: isSelected ? _primaryColor : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Map<String, String> data;
  final bool isLast;

  const _TimelineItem({required this.data, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data['startTime']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['endTime']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: _accentColor, width: 0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['subject']!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 6),
                            Text(
                              data['room']!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.person_outline, size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 6),
                            Text(
                              data['teacher']!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}