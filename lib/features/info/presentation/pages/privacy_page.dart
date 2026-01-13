import 'package:flutter/material.dart';
import 'info_page.dart';

/// Privacy Policy page
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Chính sách bảo mật',
      subtitle: 'Privacy Policy',
      content: '''
Chính sách bảo mật FusionWave

1. Thông tin chúng tôi thu thập
- Thông tin tài khoản: tên, email, ảnh đại diện
- Thông tin sử dụng: sách đã đọc, tiến độ đọc, đánh giá
- Thông tin thiết bị: loại thiết bị, hệ điều hành, ID thiết bị

2. Cách chúng tôi sử dụng thông tin
- Cung cấp và cải thiện dịch vụ
- Gửi thông báo về sách mới và cập nhật
- Phân tích hành vi người dùng để cải thiện trải nghiệm
- Bảo vệ quyền lợi và an toàn của người dùng

3. Chia sẻ thông tin
- Chúng tôi không bán thông tin cá nhân của bạn
- Chúng tôi có thể chia sẻ thông tin với nhà cung cấp dịch vụ đáng tin cậy
- Chúng tôi có thể tiết lộ thông tin nếu được yêu cầu bởi pháp luật

4. Bảo mật thông tin
- Chúng tôi sử dụng các biện pháp bảo mật tiên tiến để bảo vệ thông tin của bạn
- Dữ liệu được mã hóa trong quá trình truyền và lưu trữ
- Chúng tôi thường xuyên kiểm tra và cập nhật các biện pháp bảo mật

5. Quyền của người dùng
- Bạn có quyền truy cập, chỉnh sửa hoặc xóa thông tin cá nhân
- Bạn có quyền từ chối nhận thông báo marketing
- Bạn có quyền yêu cầu xuất dữ liệu của mình

6. Cookie và công nghệ theo dõi
- Chúng tôi sử dụng cookie để cải thiện trải nghiệm người dùng
- Bạn có thể quản lý cookie trong cài đặt trình duyệt

7. Thay đổi chính sách
Chúng tôi có thể cập nhật chính sách này theo thời gian. Các thay đổi sẽ được thông báo trên ứng dụng.

8. Liên hệ
Nếu bạn có câu hỏi về chính sách bảo mật, vui lòng liên hệ: privacy@fusionwave.com
''',
    );
  }
}
