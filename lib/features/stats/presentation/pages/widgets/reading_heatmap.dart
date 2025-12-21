import 'package:flutter/material.dart';
import '../../../../../data/models/reading_stats_model.dart';
import '../../../../../core/constants/app_colors.dart';

/// Reading heatmap widget (GitHub-style contribution graph)
class ReadingHeatmap extends StatelessWidget {
  final ReadingStatsModel stats;
  
  const ReadingHeatmap({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    // Generate last 365 days of data
    final now = DateTime.now();
    final days = List.generate(365, (index) {
      final date = now.subtract(Duration(days: 364 - index));
      final dateKey = _formatDate(date);
      final value = stats.dailyStats[dateKey] ?? 0;
      return _DayData(date, value);
    });
    
    // Group by weeks (52 weeks)
    final weeks = <List<_DayData>>[];
    for (int i = 0; i < days.length; i += 7) {
      final week = days.sublist(i, i + 7 > days.length ? days.length : i + 7);
      weeks.add(week);
    }
    
    // Find max value for color intensity
    final maxValue = days.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reading Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Less',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 4),
                    ...List.generate(4, (index) {
                      return Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(left: 2),
                        decoration: BoxDecoration(
                          color: _getColorForValue(index, 3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      'More',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day labels
                Column(
                  children: ['Mon', 'Wed', 'Fri'].map((day) {
                    return Container(
                      height: 12,
                      margin: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 8),
                // Heatmap grid
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: weeks.map((week) {
                        return Column(
                          children: week.map((day) {
                            return Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: _getColorForValue(day.value, maxValue),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Tooltip(
                                message: '${_formatDate(day.date)}\n${day.value} min',
                                child: Container(),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last 365 days',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getColorForValue(int value, int maxValue) {
    if (value == 0) return Colors.grey[200]!;
    
    final intensity = value / (maxValue > 0 ? maxValue : 1);
    
    if (intensity < 0.25) {
      return AppColors.accent.withOpacity(0.3);
    } else if (intensity < 0.5) {
      return AppColors.accent.withOpacity(0.5);
    } else if (intensity < 0.75) {
      return AppColors.accent.withOpacity(0.7);
    } else {
      return AppColors.accent;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _DayData {
  final DateTime date;
  final int value;
  
  _DayData(this.date, this.value);
}

