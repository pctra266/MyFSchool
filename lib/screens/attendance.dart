import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _backgroundColor = Color(0xFFF2F4F7);

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  
  int _presentCount = 0;
  int _absentCount = 0;
  int _lateCount = 0;
  
  DateTime _currentDate = DateTime.now();
  List<dynamic> _monthlyData = [];

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summaryRes = await _apiService.getAttendanceSummary();
      final monthlyRes = await _apiService.getMonthlyAttendance(_currentDate.year, _currentDate.month);

      if (summaryRes['success'] && monthlyRes['success']) {
        setState(() {
          _presentCount = summaryRes['data']['present'] ?? 0;
          _absentCount = summaryRes['data']['absent'] ?? 0;
          _lateCount = summaryRes['data']['late'] ?? 0;
          _monthlyData = monthlyRes['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = summaryRes['message'] ?? monthlyRes['message'] ?? 'Failed to load data';
          _isLoading = false;
        });
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

  void _changeMonth(int offset) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + offset, 1);
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildMonthHeader(),
                    const SizedBox(height: 12),
                    _buildCalendarGrid(),
                    const SizedBox(height: 20),
                    _buildLegend(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMonthHeader() {
    String monthName = _months[_currentDate.month - 1];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left)),
        Text(
          '$monthName ${_currentDate.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right)),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    int daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    int firstDayWeekday = DateTime(_currentDate.year, _currentDate.month, 1).weekday;
    int offset = firstDayWeekday == 7 ? 0 : firstDayWeekday;

    // Create a map to look up attendance records by day
    Map<int, List<dynamic>> dayRecordsMap = {};
    for (var record in _monthlyData) {
      if (record['date'] != null && record['status'] != null) {
        DateTime parsedDate = DateTime.parse(record['date']);
        if (!dayRecordsMap.containsKey(parsedDate.day)) {
          dayRecordsMap[parsedDate.day] = [];
        }
        dayRecordsMap[parsedDate.day]!.add(record);
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: daysInMonth + offset,
      itemBuilder: (context, index) {
        if (index < offset) return const SizedBox.shrink(); 
        
        int day = index - offset + 1;
        bool isWeekend = (index % 7 == 0) || (index % 7 == 6);
        BoxDecoration? decoration;
        Color textColor = Colors.black87;

        List<dynamic>? records = dayRecordsMap[day];
        String? status;

        if (records != null && records.isNotEmpty) {
          bool anyAbsent = records.any((r) => r['status'] == 'Absent');
          bool anyLate = records.any((r) => r['status'] == 'Late');
          if (anyAbsent) {
            status = 'Absent';
          } else if (anyLate) {
            status = 'Late';
          } else {
            status = 'Present';
          }
        }

        if (status == 'Present') {
          decoration = const BoxDecoration(color: const Color(0xFFE8F5E9), shape: BoxShape.circle);
          textColor = Colors.green;
        } else if (status == 'Late') {
          decoration = const BoxDecoration(color: Colors.orange, shape: BoxShape.circle);
          textColor = Colors.white;
        } else if (status == 'Absent') {
          decoration = const BoxDecoration(color: Colors.red, shape: BoxShape.circle);
          textColor = Colors.white;
        } else if (!isWeekend) {
          textColor = Colors.black87;
        } else {
          textColor = Colors.grey;
        }

        return InkWell(
          onTap: records == null || records.isEmpty
              ? null
              : () => _showDayDetails(context, day, records),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: decoration,
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Present', Colors.green),
        _buildLegendItem('Late', Colors.orange),
        _buildLegendItem('Absent', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _showDayDetails(BuildContext context, int day, List<dynamic> records) {
    String monthName = _months[_currentDate.month - 1];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$monthName $day, ${_currentDate.year}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final subject = record['subjectName'] ?? 'Unknown';
                    final startTime = record['startTime'] ?? '';
                    final endTime = record['endTime'] ?? '';
                    final status = record['status'] ?? '';
                    
                    Color statusColor = Colors.grey;
                    if (status == 'Present') statusColor = Colors.green;
                    else if (status == 'Late') statusColor = Colors.orange;
                    else if (status == 'Absent') statusColor = Colors.red;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$startTime - $endTime'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
