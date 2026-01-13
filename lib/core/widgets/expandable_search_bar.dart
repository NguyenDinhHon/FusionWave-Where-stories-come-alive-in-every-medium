import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/book_repository.dart';

/// Expandable search bar - mở rộng khi hover, thu về khi không tương tác
/// Có tùy chọn tìm kiếm và gợi ý tìm kiếm liên quan
class ExpandableSearchBar extends ConsumerStatefulWidget {
  const ExpandableSearchBar({super.key});

  @override
  ConsumerState<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends ConsumerState<ExpandableSearchBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  bool _isExpanded = false;
  bool _isHovered = false;
  bool _showSuggestions = false;
  bool _isDropdownOpen = false; // Track khi dropdown đang mở
  bool _isInteracting = false; // Track khi đang tương tác
  bool _isSearching = false; // Track khi đang tìm kiếm
  bool _showSearchResults = false; // Track khi hiển thị kết quả tìm kiếm
  String _searchType = 'All'; // All, Books, Authors, Categories
  List<String> _searchHistory = [];
  List<String> _suggestions = [];
  List<BookModel> _searchResults = []; // Kết quả tìm kiếm

  // Gợi ý tìm kiếm mẫu
  final List<String> _popularSearches = [
    'Fiction',
    'Romance',
    'Mystery',
    'Science Fiction',
    'Biography',
    'History',
    'Fantasy',
    'Thriller',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(
      begin: 40.0, // Width khi thu về (chỉ icon)
      end: 400.0, // Width khi mở rộng (tăng lên để có chỗ cho dropdown)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Lắng nghe focus để tự động mở rộng
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _expand();
        _loadSearchHistory();
        setState(() {
          _showSuggestions = true;
          _isInteracting = true;
        });
      } else {
        // Delay để cho phép click vào suggestions hoặc dropdown
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !_isInteracting && !_isDropdownOpen) {
            setState(() {
              _showSuggestions = false;
            });
          }
        });
      }
    });

    // Lắng nghe thay đổi text để tự động tìm kiếm
    _searchController.addListener(() {
      _updateSuggestions();
      // Tự động tìm kiếm khi có text (debounce)
      final query = _searchController.text.trim();
      if (query.isNotEmpty && query.length >= 2) {
        // Debounce: đợi 500ms sau khi người dùng ngừng gõ
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _searchController.text.trim() == query) {
            _handleSearch(query);
          }
        });
      } else {
        // Reset search results khi text rỗng hoặc quá ngắn
        if (_showSearchResults) {
          setState(() {
            _showSearchResults = false;
            _searchResults = [];
          });
        }
      }
    });

    _loadSearchHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefsAsync = ref.read(preferencesServiceProvider);
    prefsAsync.whenData((prefs) async {
      final history = await prefs.getSearchHistory();
      if (mounted) {
        setState(() {
          _searchHistory = history;
        });
      }
    });
  }

  void _updateSuggestions() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    // Tìm kiếm trong lịch sử và popular searches
    final allSuggestions = [
      ..._searchHistory.where((item) => item.toLowerCase().contains(query)),
      ..._popularSearches.where((item) => 
        item.toLowerCase().contains(query) && 
        !_searchHistory.contains(item)
      ),
    ].take(5).toList();

    setState(() {
      _suggestions = allSuggestions;
    });
  }

  void _expand() {
    if (!_isExpanded) {
      setState(() {
        _isExpanded = true;
      });
      _animationController.forward();
    }
  }

  void _collapse() {
    // Chỉ thu về nếu không có focus, không đang tương tác, và dropdown không mở
    if (_isExpanded && !_focusNode.hasFocus && !_isInteracting && !_isDropdownOpen) {
      setState(() {
        _isExpanded = false;
        _showSuggestions = false;
      });
      _animationController.reverse();
      _searchController.clear();
    }
  }

  Future<void> _handleSearch([String? query]) async {
    final searchQuery = query ?? _searchController.text.trim();
    if (searchQuery.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
      _showSuggestions = true;
    });

    try {
      // Lưu vào lịch sử
      final prefsAsync = ref.read(preferencesServiceProvider);
      prefsAsync.whenData((prefs) async {
        await prefs.addToSearchHistory(searchQuery);
      });

      // Tìm kiếm books
      final bookRepository = BookRepository();
      final results = await bookRepository.searchBooks(searchQuery, limit: 10);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
          _showSearchResults = false;
        });
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tìm kiếm: ${e.toString()}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _viewSearchDetails() {
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      final searchTypeParam = _searchType == 'All' ? '' : '&type=$_searchType';
      context.go('/search?q=$searchQuery$searchTypeParam');
      _focusNode.unfocus();
      _collapse();
    }
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    // Focus vào text field để hiển thị suggestions
    _focusNode.requestFocus();
    // Tự động tìm kiếm khi chọn suggestion
    _handleSearch(suggestion);
  }

  void _selectSearchResult(BookModel book) {
    context.push('/book/${book.id}');
    _focusNode.unfocus();
    _collapse();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
          _expand();
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
          // Chỉ thu về nếu không có focus, không đang tương tác, và dropdown không mở
          if (!_focusNode.hasFocus && !_isInteracting && !_isDropdownOpen) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!_isHovered && !_focusNode.hasFocus && !_isInteracting && !_isDropdownOpen && mounted) {
                _collapse();
              }
            });
          }
        },
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _widthAnimation,
              builder: (context, child) {
                return Container(
                  width: _widthAnimation.value,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: _isExpanded || _focusNode.hasFocus
                        ? LinearGradient(
                            colors: [
                              Colors.white,
                              AppColors.primary.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isExpanded || _focusNode.hasFocus
                        ? null
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isExpanded || _focusNode.hasFocus
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.grey[200]!,
                      width: _isExpanded || _focusNode.hasFocus ? 2 : 1,
                    ),
                    boxShadow: _isExpanded || _focusNode.hasFocus
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: _widthAnimation.value < 80
                      ? Center(
                          child: IconButton(
                            icon: const Icon(Icons.search, size: 20),
                            color: AppColors.iconLight,
                            onPressed: () {
                              _expand();
                              Future.delayed(const Duration(milliseconds: 150), () {
                                _focusNode.requestFocus();
                              });
                            },
                            tooltip: 'Search',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Search type dropdown
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: PopupMenuButton<String>(
                                offset: const Offset(0, 45),
                                onOpened: () {
                                  setState(() {
                                    _isDropdownOpen = true;
                                    _isInteracting = true;
                                  });
                                },
                                onCanceled: () {
                                  Future.delayed(const Duration(milliseconds: 100), () {
                                    if (mounted) {
                                      setState(() {
                                        _isDropdownOpen = false;
                                        // Giữ _isInteracting nếu vẫn có focus
                                        if (!_focusNode.hasFocus) {
                                          _isInteracting = false;
                                        }
                                      });
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _searchType,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                                onSelected: (value) {
                                  setState(() {
                                    _searchType = value;
                                    _isDropdownOpen = false;
                                    // Giữ _isInteracting nếu vẫn có focus
                                    if (!_focusNode.hasFocus) {
                                      _isInteracting = false;
                                    }
                                  });
                                },
                                itemBuilder: (context) => [
                                  _buildSearchTypeItem('All', Icons.search),
                                  _buildSearchTypeItem('Books', Icons.book),
                                  _buildSearchTypeItem('Authors', Icons.person),
                                  _buildSearchTypeItem('Categories', Icons.category),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Tìm kiếm...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  isDense: true,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                onSubmitted: (_) => _handleSearch(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                color: AppColors.textSecondaryLight,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _suggestions = [];
                                    _showSearchResults = false;
                                    _searchResults = [];
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
                            const SizedBox(width: 4),
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.search, size: 18),
                                color: Colors.white,
                                onPressed: () => _handleSearch(),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
            // Suggestions and search results overlay
            if (_showSuggestions && (
              _suggestions.isNotEmpty || 
              _searchHistory.isNotEmpty || 
              _showSearchResults || 
              _isSearching
            ))
              Positioned.fill(
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, 45),
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _isInteracting = true;
                      });
                    },
                    onExit: (_) {
                      // Delay để cho phép click vào suggestions
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (mounted && !_focusNode.hasFocus && !_isHovered) {
                          setState(() {
                            _isInteracting = false;
                          });
                          _collapse();
                        }
                      });
                    },
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 700),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: _isSearching
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _showSearchResults && _searchController.text.isNotEmpty
                                ? ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 700),
                                    child: _buildSearchResultsList(),
                                  )
                                : ListView(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    children: [
                                      // Recent searches
                                      if (_searchHistory.isNotEmpty && _searchController.text.isEmpty) ...[
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Text(
                                            'Tìm kiếm gần đây',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        ..._searchHistory.take(5).map((item) => _buildSuggestionItem(
                                          item,
                                          Icons.history,
                                          () => _selectSuggestion(item),
                                        )),
                                        const Divider(height: 1),
                                      ],
                                      // Suggestions
                                      if (_suggestions.isNotEmpty && !_showSearchResults) ...[
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Text(
                                            'Gợi ý tìm kiếm',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        ..._suggestions.map((item) => _buildSuggestionItem(
                                          item,
                                          Icons.search,
                                          () => _selectSuggestion(item),
                                        )),
                                      ],
                                      // Popular searches (khi không có text)
                                      if (_searchController.text.isEmpty && _searchHistory.isEmpty) ...[
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Text(
                                            'Tìm kiếm phổ biến',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        ..._popularSearches.take(5).map((item) => _buildSuggestionItem(
                                          item,
                                          Icons.trending_up,
                                          () => _selectSuggestion(item),
                                        )),
                                      ],
                                    ],
                                  ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildSearchTypeItem(String type, IconData icon) {
    return PopupMenuItem<String>(
      value: type,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            type,
            style: TextStyle(
              fontWeight: _searchType == type ? FontWeight.bold : FontWeight.normal,
              color: _searchType == type ? AppColors.primary : Colors.black87,
            ),
          ),
          if (_searchType == type)
            const Spacer(),
          if (_searchType == type)
            const Icon(Icons.check, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondaryLight),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: AppColors.textSecondaryLight),
              const SizedBox(height: 12),
              Text(
                'Không tìm thấy kết quả',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _searchResults.length + 1, // +1 for "Xem tất cả" button
      separatorBuilder: (context, index) => const SizedBox.shrink(), // Không có separator vì đã có border
      itemBuilder: (context, index) {
        if (index == _searchResults.length) {
          // "Xem tất cả" button ở cuối
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1),
              InkWell(
                onTap: _viewSearchDetails,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Xem tất cả kết quả (${_searchResults.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return _buildSearchResultItem(_searchResults[index]);
      },
    );
  }

  Widget _buildSearchResultItem(BookModel book) {
    return InkWell(
      onTap: () => _selectSearchResult(book),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover - lớn hơn
            Container(
              width: 70,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.coverImageUrl != null
                    ? Image.network(
                        book.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.book,
                          size: 35,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.book,
                        size: 35,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Book info - lớn hơn
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (book.authors.isNotEmpty)
                    Text(
                      book.authors.join(', '),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.iconLight,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if ((book.averageRating ?? 0) > 0) ...[
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          (book.averageRating ?? 0).toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.iconLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (book.categories.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            book.categories.first,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
    );
  }
}
