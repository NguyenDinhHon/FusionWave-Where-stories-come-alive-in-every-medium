import 'package:flutter/material.dart';
import 'info_page.dart';

/// Terms of Service page
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Điều khoản sử dụng',
      subtitle: 'Terms of Service',
      content: '''
Điều khoản sử dụng FusionWave

1. Chấp nhận điều khoản
Bằng việc sử dụng ứng dụng FusionWave, bạn đồng ý với các điều khoản và điều kiện được nêu trong tài liệu này.

2. Sử dụng dịch vụ
- Bạn phải trên 13 tuổi để sử dụng dịch vụ
- Bạn chịu trách nhiệm về tất cả hoạt động diễn ra dưới tài khoản của bạn
- Bạn không được sử dụng dịch vụ cho mục đích bất hợp pháp

3. Nội dung người dùng
- Bạn giữ quyền sở hữu nội dung bạn tạo
- Bạn cấp quyền cho FusionWave sử dụng nội dung của bạn trong phạm vi cung cấp dịch vụ
- Bạn không được đăng tải nội dung vi phạm bản quyền

4. Quyền sở hữu trí tuệ
- Tất cả nội dung trên FusionWave được bảo vệ bởi luật bản quyền
- Bạn không được sao chép, phân phối hoặc sử dụng nội dung mà không có sự cho phép

5. Chấm dứt dịch vụ
FusionWave có quyền chấm dứt hoặc tạm ngưng tài khoản của bạn nếu vi phạm các điều khoản này.

6. Thay đổi điều khoản
FusionWave có quyền thay đổi các điều khoản này bất cứ lúc nào. Việc tiếp tục sử dụng dịch vụ sau khi thay đổi có nghĩa là bạn chấp nhận các điều khoản mới.

7. Liên hệ
Nếu bạn có câu hỏi về các điều khoản này, vui lòng liên hệ với chúng tôi qua email: support@fusionwave.com
''',
    );
  }
}
