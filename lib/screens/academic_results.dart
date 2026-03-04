import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _backgroundColor = Color(0xFFF2F4F7);
const Color _textColor = Color(0xFF1D2939);

class AcademicResultsScreen extends StatefulWidget {
  const AcademicResultsScreen({super.key});

  @override
  State<AcademicResultsScreen> createState() => _AcademicResultsScreenState();
}

class _AcademicResultsScreenState extends State<AcademicResultsScreen> {
  int _selectedSemester = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Academic Results'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GPA Growth',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _textColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildGpaChart(),
                  const SizedBox(height: 32),
                  _buildSemesterSelector(),
                  const SizedBox(height: 16),
                  _buildSubjectList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            _primaryColor.withValues(alpha: 0.8),
            _primaryColor.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 32),
      child: Column(
        children: [
          const Text(
            'Overall GPA',
            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const _AnimatedCounter(
            value: 8.9,
            style: TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Excellent Student',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpaChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'Term 1';
                      break;
                    case 1:
                      text = 'Term 2';
                      break;
                    case 2:
                      text = 'Term 3';
                      break;
                    case 3:
                      text = 'Term 4';
                      break;
                    default:
                      return Container();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(text, style: style),
                  );
                },
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 3,
          minY: 0,
          maxY: 10,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 8.2),
                FlSpot(1, 8.5),
                FlSpot(2, 8.7),
                FlSpot(3, 8.9),
              ],
              isCurved: true,
              gradient: const LinearGradient(
                colors: [_primaryColor, Color(0xFFFFCCBC)],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: _primaryColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    _primaryColor.withValues(alpha: 0.3),
                    _primaryColor.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSemesterButton('Semester 1', 1),
          _buildSemesterButton('Semester 2', 2),
        ],
      ),
    );
  }

  Widget _buildSemesterButton(String title, int index) {
    final isSelected = _selectedSemester == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSemester = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectList() {
    final subjects = [
      {
        'name': 'Mathematics',
        'teacher': 'Mr. Anderson',
        'avg': 9.5,
        'components': [
          {'name': '15-min Test', 'score': 9.0},
          {'name': 'Mid-term', 'score': 9.5},
          {'name': 'Final', 'score': 10.0},
        ],
      },
      {
        'name': 'Physics',
        'teacher': 'Ms. Curie',
        'avg': 8.8,
        'components': [
          {'name': '15-min Test', 'score': 8.5},
          {'name': 'Mid-term', 'score': 9.0},
          {'name': 'Final', 'score': 8.5},
        ],
      },
      {
        'name': 'Literature',
        'teacher': 'Mr. Shakespeare',
        'avg': 8.5,
        'components': [
          {'name': '15-min Test', 'score': 8.0},
          {'name': 'Mid-term', 'score': 8.5},
          {'name': 'Final', 'score': 9.0},
        ],
      },
       {
        'name': 'English',
        'teacher': 'Ms. Rowling',
        'avg': 9.0,
        'components': [
          {'name': '15-min Test', 'score': 9.5},
          {'name': 'Mid-term', 'score': 9.0},
          {'name': 'Final', 'score': 8.5},
        ],
      },
    ];

    return Column(
      children: subjects.map((sub) => _SubjectCard(data: sub)).toList(),
    );
  }
}

class _AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle style;

  const _AnimatedCounter({required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutExpo,
      builder: (context, val, child) {
        return Text(
          val.toStringAsFixed(1),
          style: style,
        );
      },
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _SubjectCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final String name = data['name'];
    final String teacher = data['teacher'];
    final double avg = data['avg'];
    final List<Map<String, dynamic>> components = data['components'];

    Color scoreColor = avg >= 9.0
        ? const Color(0xFF4CAF50) // Green
        : (avg >= 8.0 ? const Color(0xFF2196F3) : const Color(0xFFFF9800)); // Blue / Orange

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _textColor,
            ),
          ),
          subtitle: Text(
            teacher,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          trailing: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scoreColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                avg.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: components.map<Widget>((comp) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            comp['name'],
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (comp['score'] as double) / 10.0,
                              backgroundColor: Colors.grey[100],
                              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          comp['score'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
