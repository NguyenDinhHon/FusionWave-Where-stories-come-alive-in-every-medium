import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../core/services/book_upload_service.dart';

/// Trang upload sách với file picker và preview
class UploadBookPage extends ConsumerStatefulWidget {
  const UploadBookPage({super.key});

  @override
  ConsumerState<UploadBookPage> createState() => _UploadBookPageState();
}

class _UploadBookPageState extends ConsumerState<UploadBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  double? _rating;
  File? _coverImage;
  File? _bookFile;
  bool _isUploading = false;
  String _uploadStatus = '';

  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Romance',
    'Mystery',
    'Fantasy',
    'Biography',
    'Thriller',
    'Horror',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _coverImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickBookFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'docx', 'md'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _bookFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadBook() async {
    if (!_formKey.currentState!.validate()) return;
    if (_bookFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn file sách')));
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Đang upload...';
    });

    try {
      final uploadService = BookUploadService();

      setState(() {
        _uploadStatus = 'Đang parse file...';
      });

      final authors = _authorController.text
          .split(',')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList();

      final categories = _selectedCategory != null
          ? [_selectedCategory!]
          : <String>[];

      final book = await uploadService.uploadBook(
        title: _titleController.text.trim(),
        authors: authors,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        coverImage: _coverImage,
        bookFile: _bookFile,
        categories: categories,
        rating: _rating,
        language: 'vi',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload thành công! Sách "${book.title}" đã được tạo.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavigationBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      InteractiveIconButton(
                        icon: Icons.arrow_back,
                        onPressed: () => context.pop(),
                        iconColor: AppColors.iconLight,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Upload Sách Mới',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Form
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover Image
                        Text(
                          'Ảnh Bìa',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickCoverImage,
                          child: Container(
                            width: 200,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: _coverImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _coverImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Chọn ảnh bìa',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Tiêu đề sách *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tiêu đề';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Author
                        TextFormField(
                          controller: _authorController,
                          decoration: const InputDecoration(
                            labelText: 'Tác giả *',
                            border: OutlineInputBorder(),
                            hintText:
                                'Nhập tên tác giả, cách nhau bởi dấu phẩy',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tác giả';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Mô tả',
                            border: OutlineInputBorder(),
                            hintText: 'Nhập mô tả về cuốn sách',
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),

                        // Category
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Thể loại',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Rating
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Đánh giá (0-5)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _rating = double.tryParse(value);
                            });
                          },
                        ),
                        const SizedBox(height: 32),

                        // Book File
                        Text(
                          'File Sách',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickBookFile,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _bookFile != null
                                    ? AppColors.primary
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  size: 32,
                                  color: _bookFile != null
                                      ? AppColors.primary
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _bookFile != null
                                            ? _bookFile!.path.split('/').last
                                            : 'Chọn file sách (TXT, PDF, DOCX, MD)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _bookFile != null
                                              ? AppColors.primary
                                              : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                      if (_bookFile != null)
                                        Text(
                                          '${(_bookFile!.lengthSync() / 1024).toStringAsFixed(2)} KB',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondaryLight,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (_bookFile != null)
                                  InteractiveButton(
                                    icon: Icons.close,
                                    onPressed: () {
                                      setState(() {
                                        _bookFile = null;
                                      });
                                    },
                                    isIconButton: true,
                                    iconColor: AppColors.iconLight,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Upload Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InteractiveButton(
                              label: 'Hủy',
                              onPressed: _isUploading
                                  ? null
                                  : () => context.pop(),
                              isOutlined: true,
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            InteractiveButton(
                              label: _isUploading
                                  ? 'Đang upload...'
                                  : 'Upload Sách',
                              icon: _isUploading ? null : Icons.upload,
                              onPressed: _isUploading ? null : _uploadBook,
                              isLoading: _isUploading,
                              gradient: AppColors.primaryGradient,
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ],
                        ),
                        if (_uploadStatus.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              _uploadStatus,
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
