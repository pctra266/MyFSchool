import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _backgroundColor = Color(0xFFF2F4F7);
const Color _textColor = Color(0xFF1D2939);

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _mealPlans = [];

  @override
  void initState() {
    super.initState();
    _fetchMealPlans();
  }

  Future<void> _fetchMealPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _apiService.getMealPlans();

    if (mounted) {
      if (result['success']) {
        setState(() {
          _mealPlans = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Weekly Meal Plan'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Failed to load meal plans',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchMealPlans,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_mealPlans.isEmpty) {
      return const Center(
        child: Text('No meal plans available yet.', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mealPlans.length,
      itemBuilder: (context, index) {
        final plan = _mealPlans[index];
        final day = plan['dayOfWeek'] ?? '';
        
        return _DayMenu(
          day: day,
          mainDish: plan['mainDish'] ?? 'N/A',
          sideDish: plan['sideDish'] ?? 'N/A',
          soup: plan['soup'] ?? 'N/A',
          isExpanded: day.toLowerCase() == 'monday',
        );
      },
    );
  }
}

class _DayMenu extends StatelessWidget {
  final String day;
  final String mainDish;
  final String sideDish;
  final String soup;
  final bool isExpanded;

  const _DayMenu({
    required this.day,
    required this.mainDish,
    required this.sideDish,
    required this.soup,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
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
          initiallyExpanded: isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            day,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _primaryColor),
          ),
          leading: const Icon(Icons.restaurant, color: _primaryColor),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  _buildMenuItem('Main Course', mainDish),
                  const Divider(),
                  _buildMenuItem('Side Dish', sideDish),
                  const Divider(),
                  _buildMenuItem('Soup', soup),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String type, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: _textColor)),
        ],
      ),
    );
  }
}
