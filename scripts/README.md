# 📊 Database Seeding Scripts

## 🎯 Mục Đích

Script này sẽ tự động thêm sample data vào Firestore database để bạn có thể test app ngay.

## 📦 Dữ Liệu Sẽ Được Thêm

- ✅ **5 Users** (bao gồm 1 editor)
- ✅ **8 Books** với đầy đủ thông tin
- ✅ **~50 Chapters** (5-10 chapters mỗi book)
- ✅ **6 Library Items** (users đã add books vào library)
- ✅ **6 Comments** trên các books
- ✅ **7 Ratings** (1-5 stars)
- ✅ **3 Reading Stats** records
- ✅ **4 Follows** relationships

## 🚀 Cách Chạy

### Cách 1: Chạy từ Flutter App (Khuyến nghị)

1. **Mở app trong Flutter:**
   ```bash
   flutter run -d chrome
   ```

2. **Đăng nhập với tài khoản của bạn** (hoặc đăng ký mới)

3. **Truy cập URL đặc biệt để chạy seed:**
   - Mở browser console (F12)
   - Chạy lệnh:
   ```javascript
   // Tạo một button để trigger seed
   // Hoặc truy cập route đặc biệt
   ```

### Cách 2: Chạy Script Trực Tiếp (Cần Firebase Admin SDK)

Script này cần Firebase credentials. Cách đơn giản nhất là tạo một page trong app để chạy seed.

### Cách 3: Sử dụng Flutter Command (Dễ nhất)

Tôi sẽ tạo một command đơn giản để bạn chạy từ terminal.

## ⚠️ Lưu Ý

- Script sẽ **THÊM** data vào database, không xóa data cũ
- Nếu chạy nhiều lần, sẽ có duplicate data
- Đảm bảo Firestore đã được setup và có quyền write

## 🔧 Troubleshooting

Nếu gặp lỗi permission:
- Kiểm tra Firestore Security Rules
- Đảm bảo đang ở test mode hoặc có quyền write

---

**Sau khi chạy script, bạn sẽ có đầy đủ data để test app! 🎉**

