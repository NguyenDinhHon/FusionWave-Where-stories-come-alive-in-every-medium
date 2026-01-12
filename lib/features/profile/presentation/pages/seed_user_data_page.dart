import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../../../core/constants/app_constants.dart';

/// Seed data page for current user
class SeedUserDataPage extends StatefulWidget {
  const SeedUserDataPage({super.key});

  @override
  State<SeedUserDataPage> createState() => _SeedUserDataPageState();
}

class _SeedUserDataPageState extends State<SeedUserDataPage> {
  bool _isSeeding = false;
  String _status = 'Ready to seed';
  int _progress = 0;
  final Random _random = Random();

  Future<void> _seedUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _status = '❌ Error: User not logged in';
      });
      return;
    }

    setState(() {
      _isSeeding = true;
      _status = 'Initializing...';
      _progress = 0;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final userId = user.uid;

      // Get all books
      setState(() {
        _status = 'Loading books...';
        _progress = 5;
      });
      final booksSnapshot = await firestore
          .collection(AppConstants.booksCollection)
          .where('isPublished', isEqualTo: true)
          .limit(50)
          .get();
      final bookIds = booksSnapshot.docs.map((doc) => doc.id).toList();

      if (bookIds.isEmpty) {
        setState(() {
          _status = '❌ Error: No books found. Please seed books first.';
          _isSeeding = false;
        });
        return;
      }

      // 1. Seed Library Items
      setState(() {
        _status = 'Seeding library items...';
        _progress = 10;
      });
      await _seedLibraryItems(firestore, userId, bookIds);

      // 2. Seed Collections
      setState(() {
        _status = 'Seeding collections...';
        _progress = 40;
      });
      await _seedCollections(firestore, userId, bookIds);

      // 3. Seed Challenges
      setState(() {
        _status = 'Seeding challenges...';
        _progress = 60;
      });
      await _seedChallenges(firestore, userId);

      // 4. Seed Notifications
      setState(() {
        _status = 'Seeding notifications...';
        _progress = 80;
      });
      await _seedNotifications(firestore, userId, bookIds);

      // 5. Seed Reading Stats
      setState(() {
        _status = 'Seeding reading stats...';
        _progress = 90;
      });
      await _seedReadingStats(firestore, userId);

      setState(() {
        _status = '✅ User data seeding completed successfully!';
        _progress = 100;
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data seeded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error seeding user data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Seed library items
  Future<void> _seedLibraryItems(
    FirebaseFirestore firestore,
    String userId,
    List<String> bookIds,
  ) async {
    // Check existing library items
    final existingSnapshot = await firestore
        .collection(AppConstants.libraryCollection)
        .doc(userId)
        .collection('books')
        .get();

    final existingBookIds = existingSnapshot.docs.map((doc) => doc.id).toSet();
    final availableBooks = bookIds.where((id) => !existingBookIds.contains(id)).toList();

    if (availableBooks.isEmpty) {
      return; // Already have library items
    }

    final numBooks = min(15, availableBooks.length); // Add 15 books
    final selectedBooks = availableBooks.take(numBooks).toList();

    for (int i = 0; i < selectedBooks.length; i++) {
      final bookId = selectedBooks[i];
      final statusIndex = i % 4;
      final status = [
        AppConstants.bookStatusReading,
        AppConstants.bookStatusCompleted,
        AppConstants.bookStatusWantToRead,
        AppConstants.bookStatusReading,
      ][statusIndex];

      final progress = status == AppConstants.bookStatusCompleted
          ? 1.0
          : status == AppConstants.bookStatusReading
              ? 0.1 + _random.nextDouble() * 0.7
              : 0.0;

      await firestore
          .collection(AppConstants.libraryCollection)
          .doc(userId)
          .collection('books')
          .doc(bookId)
          .set({
        'userId': userId,
        'bookId': bookId,
        'status': status,
        'progress': progress,
        'currentPage': (progress * 200).round(),
        'currentChapter': (progress * 10).round() + 1,
        'addedAt': FieldValue.serverTimestamp(),
        'lastReadAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Seed collections
  Future<void> _seedCollections(
    FirebaseFirestore firestore,
    String userId,
    List<String> bookIds,
  ) async {
    // Check existing collections
    final existingSnapshot = await firestore
        .collection(AppConstants.collectionsCollection)
        .where('userId', isEqualTo: userId)
        .get();

    if (existingSnapshot.docs.isNotEmpty) {
      return; // Already have collections
    }

    final collectionNames = [
      'My Favorites',
      'Must Read',
      'Technology Books',
      'Programming Guides',
      'Design Collection',
    ];

    for (int i = 0; i < 3; i++) {
      final numBooks = 3 + _random.nextInt(8); // 3-10 books per collection
      final collectionBooks = <String>[];
      for (int j = 0; j < numBooks; j++) {
        final bookId = bookIds[_random.nextInt(bookIds.length)];
        if (!collectionBooks.contains(bookId)) {
          collectionBooks.add(bookId);
        }
      }

      await firestore.collection(AppConstants.collectionsCollection).add({
        'userId': userId,
        'name': collectionNames[i],
        'description': 'A curated collection of books',
        'bookIds': collectionBooks,
        'isPublic': i == 0, // First collection is public
        'coverImageUrl': 'https://picsum.photos/400/600?random=${i + 3000}',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Seed challenges
  Future<void> _seedChallenges(
    FirebaseFirestore firestore,
    String userId,
  ) async {
    // Check existing challenges
    final existingSnapshot = await firestore
        .collection(AppConstants.challengesCollection)
        .where('userId', isEqualTo: userId)
        .get();

    if (existingSnapshot.docs.isNotEmpty) {
      return; // Already have challenges
    }

    final challenges = [
      {
        'title': 'Read 100 Pages This Month',
        'description': 'Challenge yourself to read 100 pages this month!',
        'type': 'pages',
        'targetValue': 100,
        'currentValue': 0,
      },
      {
        'title': 'Read 30 Minutes Daily',
        'description': 'Read for at least 30 minutes every day',
        'type': 'minutes',
        'targetValue': 30,
        'currentValue': 0,
      },
      {
        'title': 'Complete 5 Books This Year',
        'description': 'Finish reading 5 books this year',
        'type': 'books',
        'targetValue': 5,
        'currentValue': 0,
      },
    ];

    for (var challenge in challenges) {
      final startDate = DateTime.now();
      final endDate = startDate.add(const Duration(days: 30));

      await firestore.collection(AppConstants.challengesCollection).add({
        'userId': userId,
        'title': challenge['title'],
        'description': challenge['description'],
        'type': challenge['type'],
        'targetValue': challenge['targetValue'],
        'currentValue': challenge['currentValue'],
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'isCompleted': false,
        'completedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Seed notifications
  Future<void> _seedNotifications(
    FirebaseFirestore firestore,
    String userId,
    List<String> bookIds,
  ) async {
    // Check existing notifications
    final existingSnapshot = await firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingSnapshot.docs.isNotEmpty) {
      return; // Already have notifications
    }

    final notifications = [
      {
        'title': 'Welcome to FusionWave!',
        'body': 'Start your reading journey by exploring our collection of books.',
        'type': 'general',
      },
      {
        'title': 'New Book Available',
        'body': 'Check out the latest book in your favorite category!',
        'type': 'bookUpdate',
        'relatedId': bookIds.isNotEmpty ? bookIds[0] : null,
      },
      {
        'title': 'Reading Challenge Started',
        'body': 'Your reading challenge has started. Good luck!',
        'type': 'challenge',
      },
      {
        'title': 'Daily Reading Reminder',
        'body': 'Don\'t forget to read today to maintain your streak!',
        'type': 'reminder',
      },
    ];

    for (var notification in notifications) {
      await firestore.collection(AppConstants.notificationsCollection).add({
        'userId': userId,
        'title': notification['title'],
        'body': notification['body'],
        'type': notification['type'],
        'relatedId': notification['relatedId'],
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Seed reading stats
  Future<void> _seedReadingStats(
    FirebaseFirestore firestore,
    String userId,
  ) async {
    // Check existing stats
    final existingSnapshot = await firestore
        .collection(AppConstants.readingStatsCollection)
        .doc(userId)
        .get();

    if (existingSnapshot.exists) {
      return; // Already have stats
    }

    final dailyStats = <String, Map<String, dynamic>>{};

    // Generate daily stats for last 7 days
    for (int day = 0; day < 7; day++) {
      if (_random.nextBool()) {
        final date = DateTime.now().subtract(Duration(days: day));
        dailyStats[date.millisecondsSinceEpoch.toString()] = {
          'date': Timestamp.fromDate(date),
          'minutesRead': 15 + _random.nextInt(45),
          'pagesRead': 5 + _random.nextInt(20),
          'chaptersRead': _random.nextInt(2),
          'booksCompleted': 0,
        };
      }
    }

    await firestore.collection(AppConstants.readingStatsCollection).doc(userId).set({
      'userId': userId,
      'totalMinutesRead': dailyStats.values.fold(0, (total, stat) => total + (stat['minutesRead'] as int)),
      'totalPagesRead': dailyStats.values.fold(0, (total, stat) => total + (stat['pagesRead'] as int)),
      'totalChaptersRead': dailyStats.values.fold(0, (total, stat) => total + (stat['chaptersRead'] as int)),
      'totalBooksCompleted': 0,
      'currentStreak': _random.nextInt(7),
      'longestStreak': 7 + _random.nextInt(14),
      'dailyStats': dailyStats,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed User Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.data_usage,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Seed Your Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will add sample data to your profile including:\n'
              '• Library items (books you\'re reading)\n'
              '• Collections (organized book lists)\n'
              '• Challenges (reading goals)\n'
              '• Notifications\n'
              '• Reading statistics',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (_isSeeding) ...[
              LinearProgressIndicator(
                value: _progress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$_progress%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _seedUserData,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Seeding'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
