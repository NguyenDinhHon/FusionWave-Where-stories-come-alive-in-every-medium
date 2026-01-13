import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/stats_provider.dart';
import '../../../../data/models/reading_stats_model.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(readingStatsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.readingStats),
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats == null) {
            return const Center(
              child: Text('No reading statistics available'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                _buildSummaryCards(context, stats),
                  const SizedBox(height: 24),

                  // Reading Progress
                  _buildReadingProgress(context),
                  const SizedBox(height: 24),

                  // Reading Habits
                  _buildReadingHabits(context, stats),
                  const SizedBox(height: 24),
                const SizedBox(height: 24),
                
                // Streak card
                _buildStreakCard(context, stats),
                const SizedBox(height: 24),
                
                // Charts
                _buildWeeklyChart(context, stats),
                const SizedBox(height: 24),
                
                _buildMonthlyChart(context, stats),
              ],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingProgress(BuildContext context) {
    // Simple in-memory mock data for MVP UI. Replace with real book data later.
    final books = <Map<String, Object>>[
      {
        'id': 'b1',
        'title': 'The Silent Patient',
        'author': 'Alex Michaelides',
        'progress': 68,
        'currentChapter': 'Chapter 12',
        'status': 'reading', // reading, completed, paused
      },
      {
        'id': 'b2',
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'progress': 100,
        'currentChapter': 'Finished',
        'status': 'completed',
      },
      {
        'id': 'b3',
        'title': 'The Midnight Library',
        'author': 'Matt Haig',
        'progress': 34,
        'currentChapter': 'Chapter 5',
        'status': 'paused',
      },
    ];

    String selectedFilter = 'all';

    Widget bookTile(Map<String, Object> b) {
      final title = b['title']!.toString();
      final author = b['author']!.toString();
      final progress = (b['progress'] as int).toDouble();
      final chapter = b['currentChapter']!.toString();
      final status = b['status']!.toString();

      return Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text('$author • $chapter'),
          trailing: SizedBox(
            width: 110,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${progress.toInt()}%'),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: progress / 100),
                const SizedBox(height: 6),
                Text(status, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text('Reading Progress', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        // Filters
        Row(
          children: [
            ChoiceChip(label: const Text('All'), selected: selectedFilter == 'all', onSelected: (_) {}),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Reading'), selected: selectedFilter == 'reading', onSelected: (_) {}),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Completed'), selected: selectedFilter == 'completed', onSelected: (_) {}),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Paused'), selected: selectedFilter == 'paused', onSelected: (_) {}),
          ],
        ),
        const SizedBox(height: 12),
        // List
        Column(
          children: books.map((b) => bookTile(b)).toList(),
        ),
      ],
    );
  }

  Widget _buildReadingHabits(BuildContext context, ReadingStatsModel stats) {
    // Use dailyStats map (date->minutes) to build a simple bar chart for the last 14 days
    final daily = stats.dailyStats;
    final entries = daily.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final last14 = entries.length > 14 ? entries.sublist(entries.length - 14) : entries;

    final maxMinutes = last14.isNotEmpty ? last14.map((e) => e.value).reduce((a, b) => a > b ? a : b) : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text('Reading Habits', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Days read (last 14 days)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: last14.map((e) {
                      final h = (e.value / maxMinutes) * 80; // relative height
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: h,
                                decoration: BoxDecoration(color: Colors.blue.shade300, borderRadius: BorderRadius.circular(4)),
                              ),
                              const SizedBox(height: 6),
                              Text(e.key.split('-').last, style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Most active time of day', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: const [
                    Chip(label: Text('Morning')),
                    Chip(label: Text('Afternoon')),
                    Chip(label: Text('Evening'), backgroundColor: Colors.blueAccent, labelStyle: TextStyle(color: Colors.white)),
                    Chip(label: Text('Night')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, ReadingStatsModel stats) {
    String _formatTime(int minutes) {
      if (minutes <= 0) return '0m';
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (h > 0) return '${h}h ${m}m';
      return '${m}m';
    }

    // Placeholder for favorites/tracked books; integrate with real data later
    final favoritesCount = 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Books Read',
                stats.totalBooksCompleted.toString(),
                Icons.library_books,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Chapters',
                stats.totalChaptersRead.toString(),
                Icons.menu_book,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Pages',
                stats.totalPagesRead.toString(),
                Icons.book,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Time Read',
                _formatTime(stats.totalReadingTimeMinutes),
                Icons.access_time,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Streak',
                stats.currentStreak.toString(),
                Icons.local_fire_department,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Favorites',
                favoritesCount.toString(),
                Icons.favorite,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, ReadingStatsModel stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats.currentStreak}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'Day Reading Streak',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, ReadingStatsModel stats) {
    if (stats.weeklyStats.isEmpty) {
      return const SizedBox();
    }
    
    final entries = stats.weeklyStats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: entries.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < entries.length) {
                            return Text(
                              entries[value.toInt()].key.split('-').last,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: entries.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: Theme.of(context).primaryColor,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, ReadingStatsModel stats) {
    if (stats.monthlyStats.isEmpty) {
      return const SizedBox();
    }
    
    final entries = stats.monthlyStats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < entries.length) {
                            return Text(
                              entries[value.toInt()].key.split('-').last,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: entries.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

