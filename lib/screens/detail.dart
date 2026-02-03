import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _textColor = Color(0xFF1D2939);

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    const steps = <_StepData>[
      _StepData(
        title: 'Kickoff outline',
        duration: '10 min',
        note: 'Collect yesterdays highlights and shortlist the goal.',
        completed: true,
      ),
      _StepData(
        title: 'Sketch hero frames',
        duration: '20 min',
        note: 'Draft three quick variations with copper accents.',
        completed: false,
      ),
      _StepData(
        title: 'Sync with mentor',
        duration: '15 min',
        note: 'Capture feedback bullets in the shared doc.',
        completed: false,
      ),
      _StepData(
        title: 'Upload recap',
        duration: '5 min',
        note: 'Post a short summary for the team channel.',
        completed: false,
      ),
    ];

    const resources = <String>[
      'Moodboard link',
      'Preset pack',
      'Shot list',
      'Share doc',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Collection #${index + 1}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay on track with a short, clear checklist.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                ),
                child: Row(
                  children: const [
                    Expanded(child: _SummaryPill(title: 'Due', value: '2 days')),
                    SizedBox(width: 12),
                    Expanded(child: _SummaryPill(title: 'Focus', value: 'Visual design')),
                    SizedBox(width: 12),
                    Expanded(child: _SummaryPill(title: 'Energy', value: 'Low impact')),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Steps', style: _sectionTitle(context)),
              const SizedBox(height: 16),
              for (final step in steps) _StepTile(data: step),
              const SizedBox(height: 28),
              Text('Resources', style: _sectionTitle(context)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final item in resources)
                    Chip(
                      label: Text(item),
                      backgroundColor: const Color(0xFFF9FAFB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFE4E7EC)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Text('Notes', style: _sectionTitle(context)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                ),
                child: const Text(
                  'Keep copper tones subtle. Reserve 25 minutes to align typography with the new rhythm grid.',
                  style: TextStyle(color: _textColor),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryColor,
                        side: const BorderSide(color: _primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Start session',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _sectionTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w700,
        ) ??
        const TextStyle(
          color: _textColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.data});

  final _StepData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          Icon(
            data.completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: data.completed ? _primaryColor : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.note,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            data.duration,
            style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: _textColor, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _StepData {
  const _StepData({
    required this.title,
    required this.duration,
    required this.note,
    required this.completed,
  });

  final String title;
  final String duration;
  final String note;
  final bool completed;
}