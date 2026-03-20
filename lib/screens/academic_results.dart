import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _backgroundColor = Color(0xFFF2F4F7);
const Color _textColor = Color(0xFF1D2939);

class AcademicResultsScreen extends StatefulWidget {
  const AcademicResultsScreen({super.key});

  @override
  State<AcademicResultsScreen> createState() => _AcademicResultsScreenState();
}

class _AcademicResultsScreenState extends State<AcademicResultsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedGrade = 10;
  int _selectedSemester = 1;

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _allResults = [];
  String _selectedChartSubject = 'Tất cả';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fetchResults();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _fadeController.reset();

    final response = await _apiService.getAcademicResults();
    if (mounted) {
      if (response['success']) {
        setState(() {
          _allResults = response['data'] ?? [];
          _isLoading = false;
        });
        _fadeController.forward();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load data';
          _isLoading = false;
        });
      }
    }
  }

  void _selectGrade(int grade) {
    setState(() {
      _selectedGrade = grade;
      _selectedSemester = 1;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  void _selectSemester(int semester) {
    setState(() => _selectedSemester = semester);
    _fadeController.reset();
    _fadeController.forward();
  }

  List<Map<String, dynamic>> _getFilteredSubjects() {
    final filtered = _allResults.where((r) {
      final grade = (r['gradeLevel'] as num?)?.toInt() ?? 10;
      final semester = (r['semester'] as num?)?.toInt() ?? 1;
      return grade == _selectedGrade && semester == _selectedSemester;
    }).toList();

    final Map<String, Map<String, dynamic>> subjectMap = {};
    for (var r in filtered) {
      final subjectName = r['subjectName']?.toString() ?? 'Unknown';
      final teacherName = r['teacherName']?.toString() ?? 'Unknown';
      final assessmentName = r['assessmentName']?.toString() ?? 'Test';
      final scoreVal = r['score'];
      final score = (scoreVal is int)
          ? scoreVal.toDouble()
          : (scoreVal as double? ?? 0.0);

      if (!subjectMap.containsKey(subjectName)) {
        subjectMap[subjectName] = {
          'name': subjectName,
          'teacher': teacherName,
          'components': <Map<String, dynamic>>[],
        };
      }
      (subjectMap[subjectName]!['components'] as List).add({
        'name': assessmentName,
        'score': score,
      });
    }

    final List<Map<String, dynamic>> finalSubjects = [];
    for (var subject in subjectMap.values) {
      final components = subject['components'] as List;
      double total = 0;
      for (var comp in components) {
        total += comp['score'] as double;
      }
      double avg = components.isNotEmpty ? total / components.length : 0;
      subject['avg'] = double.parse(avg.toStringAsFixed(1));
      finalSubjects.add(subject);
    }

    return finalSubjects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Bảng điểm học sinh'),
        backgroundColor: _primaryColor,
        foregroundColor: _textColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.landscape) {
                      return _buildLandscapeChart();
                    }
                    return SafeArea(
                      child: Column(
                        children: [
                          _buildHeaderBanner(),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildGradeSelector(),
                                  const SizedBox(height: 12),
                                  _buildSemesterSelector(),
                                  const SizedBox(height: 20),
                                  _buildSubjectList(),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildHeaderBanner() {
    final yearMap = {
      10: '2023 – 2024',
      11: '2024 – 2025',
      12: '2025 – 2026',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withOpacity(0.75)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Lớp $_selectedGrade',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Năm học ${yearMap[_selectedGrade]}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            'HK $_selectedSemester',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Chọn khối lớp',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [10, 11, 12]
                  .map((g) => Expanded(child: _buildGradeChip(g)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeChip(int grade) {
    final isSelected = _selectedGrade == grade;
    return GestureDetector(
      onTap: () => _selectGrade(grade),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'Lớp $grade',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _gradeYearLabel(grade),
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? Colors.white.withOpacity(0.85)
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _gradeYearLabel(int grade) {
    const labels = {10: '2023-2024', 11: '2024-2025', 12: '2025-2026'};
    return labels[grade] ?? '';
  }

  Widget _buildSemesterSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSemesterButton('Học kỳ 1', 1),
          _buildSemesterButton('Học kỳ 2', 2),
        ],
      ),
    );
  }

  Widget _buildSemesterButton(String title, int index) {
    final isSelected = _selectedSemester == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectSemester(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? _primaryColor.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: _primaryColor, width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? _primaryColor : Colors.grey[500],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectList() {
    final subjects = _getFilteredSubjects();

    if (subjects.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.school_outlined, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'Chưa có kết quả học tập\ncho lớp $_selectedGrade - Học kỳ $_selectedSemester',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: subjects.map((sub) => _SubjectCard(data: sub)).toList(),
      ),
    );
  }

  Widget _buildLandscapeChart() {
    if (_allResults.isEmpty) {
      return const Center(child: Text('Không có dữ liệu để hiển thị biểu đồ'));
    }

    final subjects = _allResults
        .map((e) => e['subjectName']?.toString() ?? 'Unknown')
        .toSet()
        .toList();
    subjects.insert(0, 'Tất cả');

    final chartDataObj = _selectedChartSubject == 'Tất cả'
        ? _allResults
        : _allResults.where((r) => r['subjectName'] == _selectedChartSubject).toList();

    final Map<String, List<double>> semesterScores = {};
    for (var r in chartDataObj) {
      final grade = (r['gradeLevel'] as num?)?.toInt() ?? 10;
      final semester = (r['semester'] as num?)?.toInt() ?? 1;
      
      final String key = '${grade.toString().padLeft(2, '0')}-$semester';
      final scoreVal = r['score'];
      final score = (scoreVal is int) ? scoreVal.toDouble() : (scoreVal as double? ?? 0.0);
      
      if (!semesterScores.containsKey(key)) {
        semesterScores[key] = [];
      }
      semesterScores[key]!.add(score);
    }

    final List<String> sortedKeys = semesterScores.keys.toList()..sort();
    
    final List<FlSpot> spots = [];
    final List<String> xAxisLabels = [];

    for (int i = 0; i < sortedKeys.length; i++) {
        final key = sortedKeys[i];
        final parts = key.split('-');
        final grade = int.parse(parts[0]);
        final semester = int.parse(parts[1]);
        xAxisLabels.add('Lớp $grade\nHK$semester');

        final scores = semesterScores[key]!;
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        spots.add(FlSpot(i.toDouble(), double.parse(avg.toStringAsFixed(2))));
    }

    if (spots.isEmpty) {
      return const Center(child: Text('Không có đủ dữ liệu quá trình học tập'));
    }

    String rangeText = 'Tiến độ học tập';
    if (sortedKeys.length > 1) {
      final firstGrade = int.parse(sortedKeys.first.split('-')[0]);
      final lastGrade = int.parse(sortedKeys.last.split('-')[0]);
      if (firstGrade != lastGrade) {
        rangeText = 'Tổng quan Lớp $firstGrade - Lớp $lastGrade';
      } else {
        rangeText = 'Tổng quan Lớp $firstGrade';
      }
    }

    return SafeArea(
      child: Container(
        color: _backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bảng Điểm Toàn Khóa',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rangeText,
                          style: const TextStyle(
                            fontSize: 13, 
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: subjects.contains(_selectedChartSubject) ? _selectedChartSubject : 'Tất cả',
                        icon: const Icon(Icons.arrow_drop_down, color: _primaryColor),
                        items: subjects.map((sub) {
                          return DropdownMenuItem(
                            value: sub,
                            child: Text(sub, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedChartSubject = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: _primaryColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: _primaryColor,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _primaryColor.withOpacity(0.15),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < xAxisLabels.length) {
                            String label = xAxisLabels[value.toInt()];
                            final parts = label.split('\n');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(parts[0], style: TextStyle(fontSize: 11, color: Colors.grey[800], fontWeight: FontWeight.bold)),
                                  Text(parts[1], style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.normal)),
                                ]
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 38,
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true, 
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      left: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      right: const BorderSide(color: Colors.transparent),
                      top: const BorderSide(color: Colors.transparent),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.blueGrey.shade800,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final textStyle = const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          );
                          return LineTooltipItem(
                            '${touchedSpot.y}',
                            textStyle,
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
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

    Color scoreColor;
    if (avg >= 9.0) {
      scoreColor = const Color(0xFF4CAF50);
    } else if (avg >= 8.0) {
      scoreColor = const Color(0xFF2196F3);
    } else if (avg >= 6.5) {
      scoreColor = const Color(0xFFFF9800);
    } else {
      scoreColor = const Color(0xFFF44336);
    }

    String grade;
    if (avg >= 9.0) {
      grade = 'Xuất sắc';
    } else if (avg >= 8.0) {
      grade = 'Giỏi';
    } else if (avg >= 6.5) {
      grade = 'Khá';
    } else {
      grade = 'TB';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.12),
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: _textColor,
            ),
          ),
          subtitle: Text(
            teacher,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  avg.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                grade,
                style: TextStyle(
                  fontSize: 10,
                  color: scoreColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
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
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (comp['score'] as double) / 10.0,
                              backgroundColor: Colors.grey[200],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(scoreColor),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 36,
                          child: Text(
                            comp['score'].toString(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                              fontSize: 13,
                            ),
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
