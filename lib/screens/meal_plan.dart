import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _backgroundColor = Color(0xFFF2F4F7);
const Color _textColor = Color(0xFF1D2939);

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _DayMenu(day: 'Monday', mainDish: 'Grilled Chicken & Rice', sideDish: 'Steamed Vegetables', soup: 'Pumpkin Soup'),
          _DayMenu(day: 'Tuesday', mainDish: 'Spaghetti Bolognese', sideDish: 'Garlic Bread', soup: 'Minestrone'),
          _DayMenu(day: 'Wednesday', mainDish: 'Fish & Chips', sideDish: 'Coleslaw', soup: 'Corn Soup'),
          _DayMenu(day: 'Thursday', mainDish: 'Beef Stew', sideDish: 'Mashed Potatoes', soup: 'Mushroom Soup'),
          _DayMenu(day: 'Friday', mainDish: 'Pizza Margherita', sideDish: 'Caesar Salad', soup: 'Tomato Soup'),
        ],
      ),
    );
  }
}

class _DayMenu extends StatelessWidget {
  final String day;
  final String mainDish;
  final String sideDish;
  final String soup;

  const _DayMenu({
    required this.day,
    required this.mainDish,
    required this.sideDish,
    required this.soup,
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
          initiallyExpanded: day == 'Monday',
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
