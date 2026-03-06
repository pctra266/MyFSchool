import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'login.dart';
import '../services/api_service.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _textColor = Color(0xFF1D2939);
const Color _backgroundColor = Color(0xFFF9FAFB);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final apiService = ApiService();
    final result = await apiService.getProfile();

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _profileData = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Chưa cập nhật';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ người dùng',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _textColor),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: _textColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _fetchProfile();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_profileData == null) {
      return const Center(child: Text('Không có dữ liệu người dùng.'));
    }

    final fullName = _profileData?['fullName'] ?? 'Người dùng';
    final role = _profileData?['role'] ?? 'Học sinh';
    final focusArea = _profileData?['focusArea'] ?? 'Chưa cập nhật';
    final dateOfBirth = _formatDate(_profileData?['dateOfBirth']);
    final gender = _profileData?['gender'] ?? 'Chưa cập nhật';
    final address = _profileData?['address'] ?? 'Chưa cập nhật';
    final phoneNumber = _profileData?['phoneNumber'] ?? 'Chưa cập nhật';
    final parentName = _profileData?['parentName'] ?? 'Chưa cập nhật';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          // Avatar & Basic Info
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: _primaryColor.withAlpha(38),
                  child: const Icon(Icons.person, size: 50, color: _primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  fullName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _textColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.w600),
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
              _buildInfoRow('Trọng tâm', focusArea),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Section 2: Personal Info
          _buildSection(
            context,
            title: 'Thông tin cá nhân',
            icon: Icons.person_outline,
            children: [
              _buildInfoRow('Ngày sinh', dateOfBirth),
              _buildDivider(),
              _buildInfoRow('Giới tính', gender),
            ],
          ),
          
          const SizedBox(height: 24),

          // Section 3: Contact Info
          _buildSection(
            context,
            title: 'Thông tin liên hệ',
            icon: Icons.family_restroom,
            children: [
              _buildInfoRow('Họ tên phụ huynh', parentName),
              _buildDivider(),
              _buildInfoRow('Số điện thoại', phoneNumber),
              _buildDivider(),
              _buildInfoRow('Địa chỉ', address, maxLines: 2),
            ],
          ),

          const SizedBox(height: 32),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                ApiService().logout().then((_) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (_) => false,
                  );
                });
              },
              icon: const Icon(Icons.logout),
              label: const Text(
                'Đăng xuất',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withAlpha(25),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
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
                color: Colors.black.withAlpha(5),
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