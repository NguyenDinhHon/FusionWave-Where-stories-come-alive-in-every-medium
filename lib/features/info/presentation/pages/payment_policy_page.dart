import 'package:flutter/material.dart';
import 'info_page.dart';

/// Payment Policy page
class PaymentPolicyPage extends StatelessWidget {
  const PaymentPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoPage(
      title: 'Chính sách thanh toán',
      subtitle: 'Payment Policy',
      content: '''
Chính sách thanh toán FusionWave

1. Phương thức thanh toán
- Thẻ tín dụng/ghi nợ (Visa, Mastercard, American Express)
- Ví điện tử (PayPal, Apple Pay, Google Pay)
- Thanh toán qua cổng thanh toán an toàn

2. Gói đăng ký
- Gói hàng tháng: Thanh toán định kỳ mỗi tháng
- Gói hàng năm: Thanh toán một lần, tiết kiệm hơn
- Gói dùng thử: Miễn phí trong thời gian giới hạn

3. Gia hạn tự động
- Đăng ký sẽ được gia hạn tự động khi hết hạn
- Bạn có thể hủy gia hạn tự động bất cứ lúc nào trong cài đặt tài khoản
- Phí sẽ được tính vào thẻ đã đăng ký

4. Hoàn tiền
- Bạn có thể yêu cầu hoàn tiền trong vòng 7 ngày kể từ ngày đăng ký
- Hoàn tiền sẽ được xử lý trong vòng 5-10 ngày làm việc
- Sau 7 ngày, hoàn tiền sẽ được xem xét trên cơ sở từng trường hợp

5. Thay đổi giá
- FusionWave có quyền thay đổi giá gói đăng ký
- Thay đổi giá sẽ được thông báo trước 30 ngày
- Giá hiện tại của bạn sẽ được giữ nguyên cho đến khi hết hạn

6. Hủy đăng ký
- Bạn có thể hủy đăng ký bất cứ lúc nào
- Quyền truy cập Premium sẽ kéo dài đến cuối chu kỳ thanh toán hiện tại
- Không có phí hủy

7. Vấn đề thanh toán
- Nếu thanh toán thất bại, chúng tôi sẽ thông báo và thử lại
- Tài khoản Premium sẽ bị tạm ngưng nếu thanh toán không thành công
- Vui lòng cập nhật thông tin thanh toán trong cài đặt tài khoản

8. Liên hệ
Câu hỏi về thanh toán: payment@fusionwave.com
''',
    );
  }
}
