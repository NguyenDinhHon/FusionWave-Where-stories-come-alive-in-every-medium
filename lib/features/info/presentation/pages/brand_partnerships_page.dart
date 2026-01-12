import 'package:flutter/material.dart';
import 'info_page.dart';

/// Brand Partnerships page
class BrandPartnershipsPage extends StatelessWidget {
  const BrandPartnershipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Hợp tác thương hiệu',
      subtitle: 'Brand Partnerships',
      content: '''
Hợp tác thương hiệu với FusionWave

FusionWave mở ra cơ hội hợp tác cho các thương hiệu muốn tiếp cận cộng đồng đọc sách đông đảo của chúng tôi.

1. Đối tác xuất bản
- Quảng bá sách và tác phẩm mới
- Tích hợp nội dung độc quyền
- Chương trình khuyến mãi đặc biệt

2. Đối tác công nghệ
- Tích hợp công nghệ đọc sách mới
- Phát triển tính năng độc quyền
- Hợp tác nghiên cứu và phát triển

3. Đối tác nội dung
- Sản xuất nội dung gốc
- Chuyển thể phim ảnh
- Hợp tác với tác giả nổi tiếng

4. Lợi ích hợp tác
- Tiếp cận hàng triệu độc giả
- Quảng bá thương hiệu hiệu quả
- Tăng nhận diện thương hiệu
- Tạo giá trị cho cộng đồng

5. Liên hệ
Để tìm hiểu thêm về cơ hội hợp tác, vui lòng liên hệ:
Email: partnerships@fusionwave.com
Phone: +84 XXX XXX XXX
''',
    );
  }
}
