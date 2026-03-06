import 'package:flutter/material.dart';

import 'login.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _textColor = Color(0xFF1D2939);
const Color _backgroundColor = Color(0xFFF9FAFB);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ học sinh',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Avatar & Basic Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _primaryColor.withValues(alpha: 0.15),
                    child: const Icon(Icons.person, size: 50, color: _primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nguyễn Văn A',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _textColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Học sinh',
                      style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Section 1: Academic Info
            _buildSection(
              context,
              title: 'Thông tin học tập',
              icon: Icons.school,
              children: [
                _buildInfoRow('Mã học sinh', 'HS2023001'),
                _buildDivider(),
                _buildInfoRow('Lớp', '10A1'),
                _buildDivider(),
                _buildInfoRow('Niên khoá', '2023 - 2026'),
                _buildDivider(),
                _buildInfoRow('Giáo viên chủ nhiệm', 'Trần Thị B'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section 2: Personal Info
            _buildSection(
              context,
              title: 'Thông tin cá nhân',
              icon: Icons.person_outline,
              children: [
                _buildInfoRow('Ngày sinh', '15/08/2008'),
                _buildDivider(),
                _buildInfoRow('Giới tính', 'Nam'),
                _buildDivider(),
                _buildInfoRow('Nơi sinh', 'Hà Nội'),
                _buildDivider(),
                _buildInfoRow('Dân tộc', 'Kinh'),
              ],
            ),
            
            const SizedBox(height: 24),

            // Section 3: Contact Info
            _buildSection(
              context,
              title: 'Thông tin liên hệ',
              icon: Icons.family_restroom,
              children: [
                _buildInfoRow('Họ tên phụ huynh', 'Nguyễn Văn C (Bố)'),
                _buildDivider(),
                _buildInfoRow('Số điện thoại', '0901234567'),
                _buildDivider(),
                _buildInfoRow('Địa chỉ', '123 Đường ABC, Phường X, Quận Y, Hà Nội', maxLines: 2),
              ],
            ),

            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: _textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF2F4F7),
      indent: 16,
      endIndent: 16,
    );
  }
}