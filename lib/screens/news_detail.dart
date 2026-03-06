import 'package:flutter/material.dart';
import '../services/api_service.dart';

const Color _primaryColor = Color(0xFFBFA18E);
const Color _backgroundColor = Color(0xFFF2F4F7);
const Color _textColor = Color(0xFF1D2939);

class NewsDetailScreen extends StatefulWidget {
  final Map<String, dynamic> newsItem;

  const NewsDetailScreen({super.key, required this.newsItem});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  Map<String, dynamic>? _newsDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNewsDetail();
  }

  Future<void> _fetchNewsDetail() async {
    final int? id = widget.newsItem['id'];
    if (id == null) {
      if (!mounted) return;
      setState(() {
        _error = 'Invalid news ID';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService().getNewsDetail(id);
      if (!mounted) return;
      if (response['success']) {
        setState(() {
          _newsDetail = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load details.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error connecting to server.';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTitle = widget.newsItem['title'] ?? 'News Detail';
    final defaultTime = widget.newsItem['time'] ?? '';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('News Detail'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildContent(defaultTitle, defaultTime),
    );
  }

  Widget _buildContent(String defaultTitle, String defaultTime) {
    if (_newsDetail == null) {
      return const Center(child: Text('News content not available.'));
    }

    final title = _newsDetail!['title'] ?? defaultTitle;
    final description = _newsDetail!['description'] ?? 'No detail content.';
    final category = _newsDetail!['category'] ?? 'Announcement';
    final timeStr = _newsDetail!['createdAt'] != null
        ? _formatDate(_newsDetail!['createdAt'])
        : defaultTime;
    final imageUrl = _newsDetail!['imageUrl'] as String?;
    final List<dynamic> attachments = _newsDetail!['attachments'] ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              image: DecorationImage(
                image: (imageUrl != null && imageUrl.isNotEmpty)
                    ? NetworkImage(imageUrl)
                    : const NetworkImage('https://picsum.photos/600/300?school') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _primaryColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(category, style: const TextStyle(color: _primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(timeStr, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                ),
                if (attachments.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text('Related Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
                  const SizedBox(height: 12),
                  ...attachments.map((attachment) {
                    final fileName = attachment['fileName'] ?? 'Document file';
                    final fileSize = attachment['fileSize'] ?? 'Unknown size';
                    return _buildAttachment(fileName, fileSize);
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment(String name, String size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.description, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(size, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          const Icon(Icons.download, color: Colors.grey),
        ],
      ),
    );
  }
}

