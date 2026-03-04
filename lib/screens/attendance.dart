import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _backgroundColor = Color(0xFFF2F4F7);

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

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
      body: SingleChildScrollView(
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
          _buildStat('Present', '18', Colors.green),
          _buildStat('Absent', '1', Colors.red),
          _buildStat('Late', '2', Colors.orange),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
        const Text(
          'August 2023',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    // Mockup calendar grid
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 31 + 2, // Offset for starting day
      itemBuilder: (context, index) {
        if (index < 2) return const SizedBox.shrink(); // Empty slots
        int day = index - 1;
        bool isWeekend = (index % 7 == 0) || (index % 7 == 6);
        BoxDecoration? decoration;
        Color textColor = Colors.black87;

        if (!isWeekend) {
           if (day == 12) {
             decoration = const BoxDecoration(color: Colors.red, shape: BoxShape.circle);
             textColor = Colors.white;
           } else if (day == 15 || day == 22) {
             decoration = const BoxDecoration(color: Colors.orange, shape: BoxShape.circle);
             textColor = Colors.white;
           } else if (day > 0 && day <= 25) {
             decoration = const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle);
             textColor = Colors.green;
           }
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
