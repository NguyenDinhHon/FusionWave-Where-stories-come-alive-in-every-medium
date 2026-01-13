import 'package:flutter/material.dart';
import 'info_page.dart';

/// Press and Media page
class PressPage extends StatelessWidget {
  const PressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Báo chí',
      subtitle: 'Press & Media',
      content: '''
Thông tin báo chí - FusionWave

1. Thông tin công ty
FusionWave là nền tảng đọc sách kỹ thuật số hàng đầu, cung cấp hàng nghìn đầu sách cho độc giả trên toàn thế giới.

2. Tài nguyên báo chí
- Logo và hình ảnh thương hiệu
- Thông cáo báo chí
- Hình ảnh sản phẩm độ phân giải cao
- Video giới thiệu

3. Liên hệ báo chí
Để yêu cầu tài nguyên hoặc phỏng vấn, vui lòng liên hệ:
Email: press@fusionwave.com
Phone: +84 XXX XXX XXX

4. Thông cáo báo chí gần đây
- FusionWave đạt 1 triệu người dùng
- Ra mắt tính năng đọc offline
- Hợp tác với các nhà xuất bản lớn
- Giải thưởng Ứng dụng đọc sách tốt nhất 2024

5. Thông tin liên hệ
Văn phòng: [Địa chỉ]
Website: www.fusionwave.com
Email: info@fusionwave.com
''',
    );
  }
}
