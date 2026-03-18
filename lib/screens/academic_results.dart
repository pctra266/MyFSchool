import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _allResults = [];
  
  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _apiService.getAcademicResults();
    if (mounted) {
      if (response['success']) {
        setState(() {
          _allResults = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Academic Transcript'),
        backgroundColor: _primaryColor,
        foregroundColor: _textColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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

  List<Map<String, dynamic>> _getFilteredSubjects() {
    final semesterResults = _allResults.where((r) => r['semester']?.toString() == _selectedSemester.toString()).toList();
    
    final Map<String, Map<String, dynamic>> subjectMap = {};
    for (var r in semesterResults) {
      final subjectName = r['subjectName']?.toString() ?? 'Unknown';
      var teacherName = r['teacherName']?.toString() ?? 'Unknown';
      
      final assessmentName = r['assessmentName']?.toString() ?? 'Test';
      final scoreVal = r['score'];
      final score = (scoreVal is int) ? scoreVal.toDouble() : (scoreVal as double? ?? 0.0);
      
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

  Widget _buildSubjectList() {
    final subjects = _getFilteredSubjects();

    if (subjects.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No academic results found for this semester.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: subjects.map((sub) => _SubjectCard(data: sub)).toList(),
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
