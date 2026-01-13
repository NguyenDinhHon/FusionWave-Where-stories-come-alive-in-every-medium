import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../data/models/book_model.dart';
import '../../../home/presentation/providers/book_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Trang chỉnh sửa sách
class EditBookPage extends ConsumerStatefulWidget {
  final String bookId;

  const EditBookPage({super.key, required this.bookId});

  @override
  ConsumerState<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends ConsumerState<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;

  String? _selectedCategory;
  double? _rating;
  File? _newCoverImage;
  bool _isPublished = false;
  bool _isSaving = false;
  String? _currentCoverUrl;

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
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadBookData();
  }

  Future<void> _loadBookData() async {
    final bookAsync = ref.read(bookByIdProvider(widget.bookId));
    final book = await bookAsync.when(
      data: (book) => Future.value(book),
      loading: () => Future.value(null),
      error: (_, __) => Future.value(null),
    );

    if (book != null && mounted) {
      setState(() {
        _titleController.text = book.title;
        _authorController.text = book.authors.join(', ');
        _descriptionController.text = book.description ?? '';
        _selectedCategory = book.categories.isNotEmpty
            ? book.categories.first
            : null;
        _rating = book.averageRating;
        _isPublished = book.isPublished;
        _currentCoverUrl = book.coverImageUrl;
      });
    }
  }

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
        _newCoverImage = File(result.files.single.path!);
      });
    }
  }

  Future<String?> _uploadCoverImage(String bookId, File imageFile) async {
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('book_covers/$bookId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(bookRepositoryProvider);
      final bookAsync = ref.read(bookByIdProvider(widget.bookId));
      final currentBook = await bookAsync.when(
        data: (book) => Future.value(book),
        loading: () => Future.value(null),
        error: (_, __) => Future.value(null),
      );

      if (currentBook == null) {
        throw Exception('Book not found');
      }

      // Upload new cover if selected
      String? coverImageUrl = _currentCoverUrl;
      if (_newCoverImage != null) {
        coverImageUrl = await _uploadCoverImage(widget.bookId, _newCoverImage!);
      }

      final authors = _authorController.text
          .split(',')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList();

      final categories = _selectedCategory != null
          ? [_selectedCategory!]
          : <String>[];

      final updatedBook = BookModel(
        id: currentBook.id,
        title: _titleController.text.trim(),
        authors: authors,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        coverImageUrl: coverImageUrl,
        categories: categories,
        totalPages: currentBook.totalPages,
        totalChapters: currentBook.totalChapters,
        averageRating: _rating ?? currentBook.averageRating,
        totalRatings: currentBook.totalRatings,
        totalReads: currentBook.totalReads,
        createdAt: currentBook.createdAt,
        updatedAt: DateTime.now(),
        isPublished: _isPublished,
        language: currentBook.language,
        estimatedReadingTimeMinutes: currentBook.estimatedReadingTimeMinutes,
      );

      await repository.updateBook(updatedBook);
      ref.invalidate(bookByIdProvider(widget.bookId));
      ref.invalidate(allBooksProvider(null));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật sách thành công!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookByIdProvider(widget.bookId));

    return Scaffold(
      appBar: const TopNavigationBar(),
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return const Center(child: Text('Book not found'));
          }

          return SingleChildScrollView(
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
                          InteractiveButton(
                            icon: Icons.arrow_back,
                            onPressed: () => context.pop(),
                            isIconButton: true,
                            iconColor: AppColors.iconLight,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Chỉnh Sửa Sách',
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
                                child: _newCoverImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _newCoverImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : _currentCoverUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          _currentCoverUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.book),
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                              initialValue: _selectedCategory,
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
                              initialValue: _rating?.toString(),
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
                            const SizedBox(height: 16),

                            // Published status
                            Row(
                              children: [
                                Checkbox(
                                  value: _isPublished,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPublished = value ?? false;
                                    });
                                  },
                                ),
                                const Text('Published'),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Save Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InteractiveButton(
                                  label: 'Hủy',
                                  onPressed: _isSaving
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
                                  label: _isSaving
                                      ? 'Đang lưu...'
                                      : 'Lưu Thay Đổi',
                                  icon: _isSaving ? null : Icons.save,
                                  onPressed: _isSaving ? null : _saveBook,
                                  isLoading: _isSaving,
                                  gradient: AppColors.primaryGradient,
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              InteractiveButton(
                label: 'Quay lại',
                icon: Icons.arrow_back,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Provider for all books (admin)
final allBooksProvider = FutureProvider.family<List<BookModel>, String?>((
  ref,
  searchQuery,
) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getAllBooks(limit: 100, searchQuery: searchQuery);
});
