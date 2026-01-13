import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_strings.dart';

/// Footer widget giống Wattpad
class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A), // Dark gray background
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative wave shape ở trên bên phải
          Positioned(
            top: -50,
            right: -50,
            child: CustomPaint(
              size: const Size(400, 200),
              painter: WavePainter(),
            ),
          ),

          // Footer content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // First row - Main navigation links
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      _buildFooterLink(context, 'FusionWave độc quyền', () {
                        context.push('/premium');
                      }),
                      _buildFooterLink(context, 'Thử dùng gói Cao cấp', () {
                        context.push('/premium');
                      }),
                      _buildFooterLink(context, 'Tải Ứng Dụng', () {
                        _showDownloadDialog(context);
                      }),
                      _buildFooterLink(context, 'Ngôn ngữ', () {
                        _showLanguageDialog(context);
                      }),
                      _buildFooterLink(context, 'Các tác giả', () {
                        context.go('/leaderboard');
                      }),
                      _buildFooterLink(context, 'Hợp tác thương hiệu', () {
                        context.push('/brand-partnerships');
                      }),
                      _buildFooterLink(context, 'Công việc', () {
                        context.push('/jobs');
                      }),
                      _buildFooterLink(context, 'Báo chí', () {
                        context.push('/press');
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Second row - Legal and help links
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      _buildFooterLink(context, 'Điều khoản', () {
                        context.push('/terms');
                      }),
                      _buildFooterLink(context, 'Riêng tư', () {
                        context.push('/privacy');
                      }),
                      _buildFooterLink(context, 'Chính sách thanh toán', () {
                        context.push('/payment-policy');
                      }),
                      _buildFooterLink(context, 'Thiết lập', () {
                        context.go('/settings');
                      }),
                      _buildFooterLink(context, 'Trợ giúp', () {
                        context.push('/help');
                      }),
                      Text(
                        '© ${DateTime.now().year} ${AppStrings.appName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white70,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Tiếng Việt'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ngôn ngữ đã được đặt thành Tiếng Việt'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language has been set to English'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tải Ứng Dụng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.android),
              title: const Text('Android'),
              subtitle: const Text('Tải từ Google Play Store'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ứng dụng Android sẽ sớm có mặt trên Google Play Store'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_iphone),
              title: const Text('iOS'),
              subtitle: const Text('Tải từ App Store'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ứng dụng iOS sẽ sớm có mặt trên App Store'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for wave decoration
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B9BD2)
          .withValues(alpha: 0.3) // Light blue/lavender with opacity
      ..style = PaintingStyle.fill;

    final path = Path();
    // Start from top right
    path.moveTo(size.width, 0);
    // Create a smooth wave curve
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.6,
      size.width * 0.2,
      size.height * 0.8,
    );
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.9, 0, size.height);
    // Close the path
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
