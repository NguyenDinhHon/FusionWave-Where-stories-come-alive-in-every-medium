import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/interactive_button.dart';
import '../../../../data/repositories/chapter_repository.dart';
import '../../../../data/models/chapter_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider cho chapter by ID
final chapterByIdProvider = FutureProvider.family<ChapterModel?, String>((ref, chapterId) async {
  final repository = ChapterRepository();
  return repository.getChapterById(chapterId);
});

/// Trang chỉnh sửa/thêm chapter
class EditChapterPage extends ConsumerStatefulWidget {
  final String bookId;
  final String? chapterId; // null nếu là add mới

  const EditChapterPage({
    super.key,
    required this.bookId,
    this.chapterId,
  });

  @override
  ConsumerState<EditChapterPage> createState() => _EditChapterPageState();
}

class _EditChapterPageState extends ConsumerState<EditChapterPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _chapterNumberController;
  bool _isPublished = false;
  bool _isSaving = false;
  bool _isNewChapter = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _chapterNumberController = TextEditingController();
    _isNewChapter = widget.chapterId == null;
    
    if (!_isNewChapter) {
      _loadChapterData();
    } else {
      // Set default chapter number for new chapter
      _loadNextChapterNumber();
    }
  }

  Future<void> _loadNextChapterNumber() async {
    try {
      final repository = ChapterRepository();
      final chapters = await repository.getAllChaptersByBookId(widget.bookId);
      final nextNumber = chapters.isEmpty ? 1 : (chapters.map((c) => c.chapterNumber).reduce((a, b) => a > b ? a : b) + 1);
      _chapterNumberController.text = nextNumber.toString();
    } catch (e) {
      _chapterNumberController.text = '1';
    }
  }

  Future<void> _loadChapterData() async {
    if (widget.chapterId == null) return;
    
    final chapterAsync = ref.read(chapterByIdProvider(widget.chapterId!));
    final chapter = await chapterAsync.when(
      data: (chapter) => Future.value(chapter),
      loading: () => Future.value(null),
      error: (_, __) => Future.value(null),
    );
    
    if (chapter != null && mounted) {
      setState(() {
        _titleController.text = chapter.title;
        _contentController.text = chapter.content;
        _chapterNumberController.text = chapter.chapterNumber.toString();
        _isPublished = chapter.isPublished;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _chapterNumberController.dispose();
    super.dispose();
  }

  int _estimateReadingTime(String content) {
    final wordCount = content.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil();
  }

  Future<void> _saveChapter() async {
    if (!_formKey.currentState!.validate()) return;

    final chapterNumber = int.tryParse(_chapterNumberController.text);
    if (chapterNumber == null || chapterNumber < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter number phải là số dương')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ChapterRepository();
      final now = DateTime.now();
      final chapterId = widget.chapterId ?? 
          FirebaseFirestore.instance.collection(AppConstants.chaptersCollection).doc().id;

      final chapter = ChapterModel(
        id: chapterId,
        bookId: widget.bookId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        chapterNumber: chapterNumber,
        createdAt: _isNewChapter ? now : DateTime.now(), // Keep original if editing
        updatedAt: now,
        isPublished: _isPublished,
        estimatedReadingTimeMinutes: _estimateReadingTime(_contentController.text),
      );

      if (_isNewChapter) {
        await repository.createChapter(chapter);
      } else {
        await repository.updateChapter(chapter);
      }

      // Invalidate providers
      ref.invalidate(chapterByIdProvider(chapterId));
      // Invalidate book chapters provider (defined in manage_chapters_page)
      final bookChaptersProvider = FutureProvider.family<List<ChapterModel>, String>((ref, bookId) async {
        final repository = ChapterRepository();
        return repository.getAllChaptersByBookId(bookId);
      });
      ref.invalidate(bookChaptersProvider(widget.bookId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isNewChapter ? 'Đã tạo chapter thành công!' : 'Đã cập nhật chapter thành công!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
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
    return Scaffold(
      appBar: const TopNavigationBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
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
                        _isNewChapter ? 'Thêm Chapter Mới' : 'Chỉnh Sửa Chapter',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Form
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chapter Number
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _chapterNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'Chapter Number *',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập chapter number';
                                  }
                                  final num = int.tryParse(value);
                                  if (num == null || num < 1) {
                                    return 'Chapter number phải là số dương';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
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
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Tiêu đề Chapter *',
                            border: OutlineInputBorder(),
                            hintText: 'Nhập tiêu đề chapter',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tiêu đề';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Content
                        Text(
                          'Nội dung Chapter *',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Nội dung',
                            border: OutlineInputBorder(),
                            hintText: 'Nhập nội dung chapter...',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 30,
                          minLines: 20,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập nội dung';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_contentController.text.length} characters • ~${_estimateReadingTime(_contentController.text)} min reading',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Save Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InteractiveButton(
                              label: 'Hủy',
                              onPressed: _isSaving ? null : () => context.pop(),
                              isOutlined: true,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            const SizedBox(width: 12),
                            InteractiveButton(
                              label: _isSaving 
                                  ? (_isNewChapter ? 'Đang tạo...' : 'Đang lưu...')
                                  : (_isNewChapter ? 'Tạo Chapter' : 'Lưu Thay Đổi'),
                              icon: _isSaving ? null : Icons.save,
                              onPressed: _isSaving ? null : _saveChapter,
                              isLoading: _isSaving,
                              gradient: AppColors.primaryGradient,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      ),
    );
  }
}

