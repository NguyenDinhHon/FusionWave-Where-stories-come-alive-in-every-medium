import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/social_provider.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topReadersAsync = ref.watch(topReadersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.leaderboard),
      ),
      body: topReadersAsync.when(
        data: (readers) {
          if (readers.isEmpty) {
            return const Center(
              child: Text('No readers found'),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: readers.length,
            itemBuilder: (context, index) {
              final reader = readers[index];
              return _buildLeaderboardCard(context, reader, index + 1);
            },
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
              ElevatedButton(
                onPressed: () => ref.invalidate(topReadersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLeaderboardCard(BuildContext context, Map<String, dynamic> reader, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: reader['photoUrl'] != null
                  ? NetworkImage(reader['photoUrl'])
                  : null,
              child: reader['photoUrl'] == null
                  ? Text(reader['displayName'][0].toUpperCase())
                  : null,
            ),
            if (rank <= 3)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: rank == 1
                        ? Colors.amber
                        : rank == 2
                            ? Colors.grey[400]!
                            : Colors.brown[400]!,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(reader['displayName'] ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${reader['totalPagesRead']} pages read'),
            Text('${reader['currentStreak']} day streak'),
          ],
        ),
        trailing: rank > 3 ? Text('#$rank') : null,
      ),
    );
  }
}

