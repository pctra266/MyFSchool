import 'package:flutter/material.dart';

const Color kSurfaceColor = Color(0xFFF4ECE6);

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = List.generate(
      3,
      (index) => {
        'title': 'Featured notification #${index + 1}',
        'time': '20:${index}5 today',
        'description': 'A concise reminder that keeps your daily milestones on track.',
      },
    );

    return Scaffold(
      backgroundColor: kSurfaceColor,
      appBar: AppBar(
        title: const Text('Notification center'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  item['description']!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(item['time']!, style: TextStyle(color: Colors.grey[600])),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Mark as read'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemCount: notifications.length,
      ),
    );
  }
}
