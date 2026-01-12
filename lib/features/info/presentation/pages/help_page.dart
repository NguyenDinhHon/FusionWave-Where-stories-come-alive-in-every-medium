import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Help and Support page
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ giúp'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            'Câu hỏi thường gặp',
            [
              _buildFAQItem(
                context,
                'Làm thế nào để đọc sách?',
                'Tìm kiếm sách trong trang chủ hoặc thư viện, nhấn vào sách để xem chi tiết, sau đó nhấn "Đọc ngay" để bắt đầu đọc.',
              ),
              _buildFAQItem(
                context,
                'Làm thế nào để tải sách offline?',
                'Trong trang chi tiết sách, nhấn nút "Tải xuống" để tải sách về đọc offline. Sách đã tải sẽ xuất hiện trong mục "Offline".',
              ),
              _buildFAQItem(
                context,
                'Làm thế nào để đánh dấu trang?',
                'Trong khi đọc, nhấn vào màn hình để hiện menu, sau đó chọn "Bookmark" để đánh dấu trang hiện tại.',
              ),
              _buildFAQItem(
                context,
                'Làm thế nào để thay đổi font chữ?',
                'Vào Cài đặt > Font Size để điều chỉnh kích thước font chữ theo ý muốn.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Liên hệ hỗ trợ',
            [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email hỗ trợ'),
                subtitle: const Text('support@fusionwave.com'),
                onTap: () async {
                  final emailUri = Uri(
                    scheme: 'mailto',
                    path: 'support@fusionwave.com',
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể mở email client'),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Chat trực tuyến'),
                subtitle: const Text('Có sẵn 24/7'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat trực tuyến sẽ sớm có mặt!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
