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
                    _buildSummaryCard(),
                    const SizedBox(height: 20),
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Present', '$_presentCount', Colors.green),
          _buildStat('Absent', '$_absentCount', Colors.red),
          _buildStat('Late', '$_lateCount', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

    // Create a map to quickly look up attendance status by day
    Map<int, String> dayStatusMap = {};
    for (var record in _monthlyData) {
      if (record['date'] != null && record['status'] != null) {
        DateTime parsedDate = DateTime.parse(record['date']);
        dayStatusMap[parsedDate.day] = record['status'];
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

        String? status = dayStatusMap[day];

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

        return Container(
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
}
