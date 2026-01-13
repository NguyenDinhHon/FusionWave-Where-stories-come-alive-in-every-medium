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
                      _buildFooterLink(context, 'FusionWave độc quyền', () {}),
                      _buildFooterLink(context, 'Thử dùng gói Cao cấp', () {
                        // TODO: Navigate to page
                      }),
                      _buildFooterLink(context, 'Tải Ứng Dụng', () {
                        // TODO: Show download options
                      }),
                      _buildFooterLink(context, 'Ngôn ngữ', () {
                        _showLanguageDialog(context);
                      }),
                      _buildFooterLink(context, 'Các tác giả', () {
                        context.go('/leaderboard');
                      }),
                      _buildFooterLink(context, 'Hợp tác thương hiệu', () {
                        // TODO: Navigate to brand partnerships
                      }),
                      _buildFooterLink(context, 'Công việc', () {
                        // TODO: Navigate to jobs page
                      }),
                      _buildFooterLink(context, 'Báo chí', () {
                        // TODO: Navigate to press page
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
                        // TODO: Navigate to terms page
                      }),
                      _buildFooterLink(context, 'Riêng tư', () {
                        // TODO: Navigate to privacy page
                      }),
                      _buildFooterLink(context, 'Chính sách thanh toán', () {
                        // TODO: Navigate to payment policy
                      }),
                      _buildFooterLink(context, 'Thiết lập', () {
                        context.go('/settings');
                      }),
                      _buildFooterLink(context, 'Trợ giúp', () {
                        // TODO: Navigate to help page
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
                // TODO: Change language to Vietnamese
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Change language to English
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
          .withOpacity(0.3) // Light blue/lavender with opacity
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
