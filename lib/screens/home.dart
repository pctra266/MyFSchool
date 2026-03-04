import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _textColor = Color(0xFF1D2939);
const Color _backgroundColor = Color(0xFFF2F4F7);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    const notices = <_NoticeData>[
      _NoticeData(
        title: 'Beginning-of-year parent meeting',
        description: 'Parents are invited to attend the meeting at 14:00 this Sunday.',
        time: '1 hour ago',
      ),
      _NoticeData(
        title: 'Homework reminder',
        description: 'Complete the Math homework on page 45 before tomorrow.',
        time: '08:30 This morning',
      )
    ];

    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.assignment_turned_in, 'label': 'Academic results', 'route': '/academic_results'},
      {'icon': Icons.calendar_month, 'label': 'Timetable', 'route': '/timetable'},
      {'icon': Icons.verified_user, 'label': 'Attendance', 'route': '/attendance'},
      {'icon': Icons.edit_document, 'label': 'Leave request', 'route': '/leave_request'},
      {'icon': Icons.message, 'label': 'Notes', 'route': '/notes'},
      {'icon': Icons.restaurant_menu, 'label': 'Meal plan', 'route': '/meal_plan'},
      {'icon': Icons.payments, 'label': 'Tuition', 'route': '/tuition'},
      {'icon': Icons.image, 'label': 'Photo album', 'route': '/photo_album'},
    ];

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            decoration: const BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alice CrawlingOne',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Class 10A1 • Academic Year 2023-2024',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                )
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 4 columns similar to vnEdu
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        return _MenuIcon(
                          icon: menuItems[index]['icon'],
                          label: menuItems[index]['label'],
                          onTap: () {
                            if (menuItems[index]['route'] != null) {
                              Navigator.pushNamed(context, menuItems[index]['route']);
                            }
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('News & Announcements', style: _sectionTitle(context)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View all', style: TextStyle(color: _primaryColor)),
                      )
                    ],
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: notices.length,
                    itemBuilder: (context, index) => _NoticeTile(data: notices[index]),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _sectionTitle(BuildContext context) {
    return const TextStyle(
      color: _textColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1), // Subtle icon background
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _primaryColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: _textColor,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({required this.data});

  final _NoticeData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/news_detail',
          arguments: {
            'title': data.title,
            'description': data.description,
            'time': data.time,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        data.time,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeData {
  const _NoticeData({required this.title, required this.description, required this.time});
  final String title;
  final String description;
  final String time;
}