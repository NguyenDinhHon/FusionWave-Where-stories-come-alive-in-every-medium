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
import 'manage_categories_page.dart'; // For categoriesProvider

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
  late TextEditingController _subtitleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  late TextEditingController _audioUrlController;
  late TextEditingController _videoUrlController;

  String? _selectedCategory;
  double? _rating;
  File? _newCoverImage;
  bool _isPublished = false;
  bool _isSaving = false;
  String? _currentCoverUrl;
  List<String> _tags = [];
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _authorController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();
    _audioUrlController = TextEditingController();
    _videoUrlController = TextEditingController();
    _loadBookData();
  }

  Future<void> _loadBookData() async {
    try {
      final book = await ref.read(bookByIdProvider(widget.bookId).future);
      
      if (book != null && mounted) {
        setState(() {
          _titleController.text = book.title;
          _subtitleController.text = book.subtitle ?? '';
          _authorController.text = book.authors.join(', ');
          _descriptionController.text = book.description ?? '';
          _tags = List<String>.from(book.tags);
          _tagsController.text = _tags.join(', ');
          _audioUrlController.text = book.audioUrl ?? '';
          _videoUrlController.text = book.videoUrl ?? '';
          _selectedCategory = book.categories.isNotEmpty
              ? book.categories.first
              : null;
          _rating = book.averageRating;
          _isPublished = book.isPublished;
          _currentCoverUrl = book.coverImageUrl;
        });
      }
    } catch (e) {
      // Handle error silently, will show in UI via AsyncValue
      debugPrint('Error loading book data: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _audioUrlController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  // Validate URL format
  String? _validateUrl(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https'))) {
      return 'Vui lòng nhập URL hợp lệ (bắt đầu với http:// hoặc https://)';
    }
    return null;
  }

  // Validate rating
  String? _validateRating(String? value) {
    if (value == null || value.isEmpty) return null;
    final rating = double.tryParse(value);
    if (rating == null) {
      return 'Vui lòng nhập số hợp lệ';
    }
    if (rating < 0 || rating > 5) {
      return 'Đánh giá phải từ 0 đến 5';
    }
    return null;
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

  Widget _buildCategoryDropdown() {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        // Ensure no duplicates and sort
        final allCategories = categories.toSet().toList()..sort();
        
        // Ensure selected category exists in items, otherwise set to null
        final validSelectedCategory = _selectedCategory != null && 
            allCategories.contains(_selectedCategory) 
            ? _selectedCategory 
            : null;
        
        return DropdownButtonFormField<String>(
          initialValue: validSelectedCategory,
          decoration: const InputDecoration(
            labelText: 'Thể loại',
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(color: Colors.black87),
          dropdownColor: Colors.white,
          items: allCategories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        );
      },
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox(
        height: 56,
        child: Center(child: Icon(Icons.error)),
      ),
    );
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
        error: (_, _) => Future.value(null),
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

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toSet() // Remove duplicates
          .toList();

      final updatedBook = BookModel(
        id: currentBook.id,
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim().isEmpty
            ? null
            : _subtitleController.text.trim(),
        authors: authors,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        coverImageUrl: coverImageUrl,
        categories: categories,
        tags: tags,
        totalPages: currentBook.totalPages,
        totalChapters: currentBook.totalChapters,
        audioUrl: _audioUrlController.text.trim().isEmpty
            ? null
            : _audioUrlController.text.trim(),
        videoUrl: _videoUrlController.text.trim().isEmpty
            ? null
            : _videoUrlController.text.trim(),
        averageRating: _rating ?? currentBook.averageRating,
        totalRatings: currentBook.totalRatings,
        totalReads: currentBook.totalReads,
        createdAt: currentBook.createdAt,
        updatedAt: DateTime.now(),
        isPublished: _isPublished,
        language: currentBook.language,
        editorId: currentBook.editorId,
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

          // Populate controllers when data is available (only once)
          if (!_dataLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _titleController.text = book.title;
                  _subtitleController.text = book.subtitle ?? '';
                  _authorController.text = book.authors.join(', ');
                  _descriptionController.text = book.description ?? '';
                  _tags = List<String>.from(book.tags);
                  _tagsController.text = _tags.join(', ');
                  _audioUrlController.text = book.audioUrl ?? '';
                  _videoUrlController.text = book.videoUrl ?? '';
                  _selectedCategory = book.categories.isNotEmpty
                      ? book.categories.first
                      : null;
                  _rating = book.averageRating;
                  _isPublished = book.isPublished;
                  _currentCoverUrl = book.coverImageUrl;
                  _dataLoaded = true;
                });
              }
            });
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
                                          errorBuilder: (_, _, _) =>
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

                            // Subtitle
                            TextFormField(
                              controller: _subtitleController,
                              decoration: const InputDecoration(
                                labelText: 'Phụ đề',
                                border: OutlineInputBorder(),
                                hintText: 'Nhập phụ đề của sách (tùy chọn)',
                              ),
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
                            _buildCategoryDropdown(),
                            const SizedBox(height: 16),

                            // Tags
                            TextFormField(
                              controller: _tagsController,
                              decoration: const InputDecoration(
                                labelText: 'Tags',
                                border: OutlineInputBorder(),
                                hintText: 'Nhập tags, cách nhau bởi dấu phẩy',
                                helperText: 'Ví dụ: fiction, adventure, romance',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _tags = value
                                      .split(',')
                                      .map((t) => t.trim())
                                      .where((t) => t.isNotEmpty)
                                      .toList();
                                });
                              },
                            ),
                            if (_tags.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _tags.map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    onDeleted: () {
                                      setState(() {
                                        _tags.remove(tag);
                                        _tagsController.text = _tags.join(', ');
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 16),

                            // Rating
                            TextFormField(
                              initialValue: _rating?.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Đánh giá (0-5)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateRating,
                              onChanged: (value) {
                                setState(() {
                                  _rating = double.tryParse(value);
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Audio URL
                            TextFormField(
                              controller: _audioUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Audio URL',
                                border: OutlineInputBorder(),
                                hintText: 'https://example.com/audio.mp3',
                                prefixIcon: Icon(Icons.audiotrack),
                              ),
                              keyboardType: TextInputType.url,
                              validator: (value) => _validateUrl(value, 'Audio URL'),
                            ),
                            const SizedBox(height: 16),

                            // Video URL
                            TextFormField(
                              controller: _videoUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Video URL',
                                border: OutlineInputBorder(),
                                hintText: 'https://example.com/video.mp4',
                                prefixIcon: Icon(Icons.video_library),
                              ),
                              keyboardType: TextInputType.url,
                              validator: (value) => _validateUrl(value, 'Video URL'),
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
