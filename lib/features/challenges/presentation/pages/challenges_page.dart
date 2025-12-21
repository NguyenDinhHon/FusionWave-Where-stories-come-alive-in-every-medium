import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/challenge_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/challenge_model.dart';
import 'widgets/create_challenge_dialog.dart';

/// Reading Challenges page
class ChallengesPage extends ConsumerWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(userChallengesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Challenges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateChallengeDialog(context, ref),
          ),
        ],
      ),
      body: challengesAsync.when(
        data: (challenges) {
          if (challenges.isEmpty) {
            return EmptyState(
              title: 'No challenges yet',
              message: 'Create a reading challenge to track your progress',
              icon: Icons.emoji_events,
              action: ElevatedButton.icon(
                onPressed: () => _showCreateChallengeDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Create Challenge'),
              ),
            );
          }
          
          // Separate active and completed challenges
          final activeChallenges = challenges.where((c) => c.isActive).toList();
          final completedChallenges = challenges.where((c) => c.isCompleted).toList();
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (activeChallenges.isNotEmpty) ...[
                const Text(
                  'Active Challenges',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...activeChallenges.asMap().entries.map((entry) {
                  return AnimationConfiguration.staggeredList(
                    position: entry.key,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildChallengeCard(context, ref, entry.value),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
              
              if (completedChallenges.isNotEmpty) ...[
                const Text(
                  'Completed Challenges',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...completedChallenges.asMap().entries.map((entry) {
                  return AnimationConfiguration.staggeredList(
                    position: entry.key + activeChallenges.length,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildChallengeCard(context, ref, entry.value),
                      ),
                    ),
                  );
                }),
              ],
            ],
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerListItem(),
        ),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(userChallengesProvider),
        ),
      ),
    );
  }
  
  Widget _buildChallengeCard(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
  ) {
    final progressPercent = (challenge.progress * 100).toInt();
    final isCompleted = challenge.isCompleted;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.1),
                    AppColors.success.withOpacity(0.05),
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getChallengeIcon(challenge.type),
                              color: isCompleted ? AppColors.success : AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                challenge.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          challenge.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: challenge.progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Progress info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${challenge.currentValue} / ${challenge.targetValue} ${_getChallengeUnit(challenge.type)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? AppColors.success : Colors.grey[700],
                    ),
                  ),
                  Text(
                    '$progressPercent%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Date info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(challenge.startDate)} - ${_formatDate(challenge.endDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (!isCompleted && challenge.daysRemaining > 0) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.daysRemaining} days left',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.pages:
        return Icons.book;
      case ChallengeType.chapters:
        return Icons.menu_book;
      case ChallengeType.books:
        return Icons.library_books;
      case ChallengeType.minutes:
        return Icons.access_time;
    }
  }
  
  String _getChallengeUnit(ChallengeType type) {
    switch (type) {
      case ChallengeType.pages:
        return 'pages';
      case ChallengeType.chapters:
        return 'chapters';
      case ChallengeType.books:
        return 'books';
      case ChallengeType.minutes:
        return 'minutes';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  void _showCreateChallengeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreateChallengeDialog(
        onCreated: () {
          // Challenge will be refreshed automatically via stream
        },
      ),
    );
  }
}

