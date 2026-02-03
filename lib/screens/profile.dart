import 'package:flutter/material.dart';

import 'login.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _textColor = Color(0xFF1D2939);
const Color _hintColor = Color(0xFFD0D5DD);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: '4nim0sity');
  final TextEditingController _emailController = TextEditingController(text: 'dangcap@email.com');
  final TextEditingController _roleController = TextEditingController(text: 'Product design lead');

  bool _pushEnabled = true;
  bool _emailEnabled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: _primaryColor.withOpacity(0.15),
                      child: const Icon(Icons.person_outline, size: 40, color: _primaryColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Personal profile',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _textColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep your information simple and up to date.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildLabel('Full name'),
              TextField(
                controller: _nameController,
                cursorColor: _primaryColor,
                decoration: _inputDecoration('Your display name'),
              ),
              const SizedBox(height: 24),
              _buildLabel('Email'),
              TextField(
                controller: _emailController,
                cursorColor: _primaryColor,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('name@email.com'),
              ),
              const SizedBox(height: 24),
              _buildLabel('Focus area'),
              TextField(
                controller: _roleController,
                cursorColor: _primaryColor,
                decoration: _inputDecoration('Primary role or track'),
              ),
             
              const SizedBox(height: 32),
              Text('Notifications', style: _sectionTitle(context)),
              const SizedBox(height: 16),
              Container(
                decoration: _cardDecoration(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _ToggleRow(
                      title: 'Push reminders',
                      subtitle: 'Daily summary at 19:00',
                      value: _pushEnabled,
                      onChanged: (value) => setState(() => _pushEnabled = value),
                    ),
                    const Divider(height: 1),
                    _ToggleRow(
                      title: 'Email digest',
                      subtitle: 'Monday insights and checklists',
                      value: _emailEnabled,
                      onChanged: (value) => setState(() => _emailEnabled = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Workspace links', style: _sectionTitle(context)),
              const SizedBox(height: 12),
              Container(
                decoration: _cardDecoration(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    _LinkRow(title: 'Portfolio', value: 'behance.net/maiannie'),
                    Divider(height: 24),
                    _LinkRow(title: 'Shared board', value: 'moodboard.app/session-04'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Save changes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                      (_) => false,
                    );
                  },
                  child: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hintColor),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE4E7EC)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 14,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE4E7EC)),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: _primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.title, required this.value});

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
          style: const TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: _textColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: _primaryColor),
              ),
            ],
          ),
        ),
        const Icon(Icons.launch, size: 18, color: _primaryColor),
      ],
    );
  }
}