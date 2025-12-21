import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';

/// Admin page để seed sample data vào Firestore
/// Truy cập: /admin/seed-data
class SeedDataPage extends StatefulWidget {
  const SeedDataPage({super.key});

  @override
  State<SeedDataPage> createState() => _SeedDataPageState();
}

class _SeedDataPageState extends State<SeedDataPage> {
  bool _isSeeding = false;
  String _status = 'Ready to seed';
  int _progress = 0;

  Future<void> _seedDatabase() async {
    setState(() {
      _isSeeding = true;
      _status = 'Initializing...';
      _progress = 0;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Seed Users
      setState(() {
        _status = 'Seeding users...';
        _progress = 10;
      });
      final users = await _seedUsers(firestore);

      // 2. Seed Books
      setState(() {
        _status = 'Seeding books...';
        _progress = 30;
      });
      final books = await _seedBooks(firestore, users);

      // 3. Seed Chapters
      setState(() {
        _status = 'Seeding chapters...';
        _progress = 50;
      });
      await _seedChapters(firestore, books);

      // 4. Seed Library Items
      setState(() {
        _status = 'Seeding library items...';
        _progress = 70;
      });
      await _seedLibraryItems(firestore, users, books);

      // 5. Seed Comments
      setState(() {
        _status = 'Seeding comments...';
        _progress = 80;
      });
      await _seedComments(firestore, users, books);

      // 6. Seed Ratings
      setState(() {
        _status = 'Seeding ratings...';
        _progress = 90;
      });
      await _seedRatings(firestore, users, books);

      // 7. Seed Reading Stats
      setState(() {
        _status = 'Seeding reading stats...';
        _progress = 95;
      });
      await _seedReadingStats(firestore, users);

      // 8. Seed Follows
      setState(() {
        _status = 'Seeding follows...';
        _progress = 98;
      });
      await _seedFollows(firestore, users);

      setState(() {
        _status = '✅ Database seeding completed successfully!';
        _progress = 100;
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database seeded successfully!'),
            backgroundColor: Colors.green,
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
            content: Text('Error seeding database: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<String>> _seedUsers(FirebaseFirestore firestore) async {
    final usersData = [
      {
        'email': 'john.doe@example.com',
        'displayName': 'John Doe',
        'role': AppConstants.roleUser,
        'isProfilePublic': true,
        'readingStreak': 15,
      },
      {
        'email': 'jane.smith@example.com',
        'displayName': 'Jane Smith',
        'role': AppConstants.roleUser,
        'isProfilePublic': true,
        'readingStreak': 30,
      },
      {
        'email': 'editor@fusionwave.com',
        'displayName': 'Editor User',
        'role': AppConstants.roleEditor,
        'isProfilePublic': true,
        'readingStreak': 5,
      },
      {
        'email': 'alice.wonder@example.com',
        'displayName': 'Alice Wonder',
        'role': AppConstants.roleUser,
        'isProfilePublic': true,
        'readingStreak': 7,
      },
      {
        'email': 'bob.reader@example.com',
        'displayName': 'Bob Reader',
        'role': AppConstants.roleUser,
        'isProfilePublic': true,
        'readingStreak': 12,
      },
    ];

    final userIds = <String>[];
    for (var userData in usersData) {
      final userRef = firestore.collection(AppConstants.usersCollection).doc();
      await userRef.set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      userIds.add(userRef.id);
    }
    return userIds;
  }

  Future<List<String>> _seedBooks(
    FirebaseFirestore firestore,
    List<String> userIds,
  ) async {
    final booksData = [
      {
        'title': 'The Art of Flutter Development',
        'subtitle': 'A Comprehensive Guide',
        'description':
            'Master Flutter development with this comprehensive guide covering everything from basics to advanced topics.',
        'authors': ['John Flutter', 'Jane Dart'],
        'categories': ['Technology', 'Programming'],
        'tags': ['flutter', 'dart', 'mobile'],
        'totalPages': 450,
        'totalChapters': 15,
        'language': 'en',
        'averageRating': 4.5,
        'totalRatings': 120,
        'totalReads': 850,
        'isPublished': true,
        'editorId': userIds[2],
        'estimatedReadingTimeMinutes': 600,
        'coverImageUrl': 'https://picsum.photos/400/600?random=1',
      },
      {
        'title': 'Mystery of the Lost Code',
        'subtitle': 'A Developer\'s Adventure',
        'description':
            'Join our hero as they navigate through mysterious bugs and cryptic error messages.',
        'authors': ['Code Master'],
        'categories': ['Fiction', 'Adventure'],
        'tags': ['fiction', 'adventure', 'coding'],
        'totalPages': 320,
        'totalChapters': 12,
        'language': 'en',
        'averageRating': 4.2,
        'totalRatings': 89,
        'totalReads': 650,
        'isPublished': true,
        'editorId': userIds[2],
        'estimatedReadingTimeMinutes': 480,
        'coverImageUrl': 'https://picsum.photos/400/600?random=2',
      },
      {
        'title': 'Clean Architecture Principles',
        'subtitle': 'Building Maintainable Software',
        'description':
            'Learn the principles of clean architecture and how to build maintainable software systems.',
        'authors': ['Robert Clean', 'Martin Architecture'],
        'categories': ['Technology', 'Software Engineering'],
        'tags': ['architecture', 'clean code'],
        'totalPages': 380,
        'totalChapters': 14,
        'language': 'en',
        'averageRating': 4.7,
        'totalRatings': 156,
        'totalReads': 1200,
        'isPublished': true,
        'editorId': userIds[2],
        'estimatedReadingTimeMinutes': 570,
        'coverImageUrl': 'https://picsum.photos/400/600?random=3',
      },
      {
        'title': 'The Future of AI',
        'subtitle': 'Exploring Machine Learning',
        'description':
            'Dive deep into the world of artificial intelligence and machine learning.',
        'authors': ['AI Expert', 'ML Master'],
        'categories': ['Technology', 'Science'],
        'tags': ['ai', 'machine learning'],
        'totalPages': 420,
        'totalChapters': 16,
        'language': 'en',
        'averageRating': 4.4,
        'totalRatings': 98,
        'totalReads': 780,
        'isPublished': true,
        'editorId': userIds[2],
        'estimatedReadingTimeMinutes': 630,
        'coverImageUrl': 'https://picsum.photos/400/600?random=4',
      },
      {
        'title': 'Web Development Mastery',
        'subtitle': 'From Zero to Hero',
        'description':
            'Complete guide to modern web development. Learn HTML, CSS, JavaScript, React, and more.',
        'authors': ['Web Guru'],
        'categories': ['Technology', 'Web Development'],
        'tags': ['web', 'javascript', 'react'],
        'totalPages': 500,
        'totalChapters': 18,
        'language': 'en',
        'averageRating': 4.6,
        'totalRatings': 134,
        'totalReads': 950,
        'isPublished': true,
        'editorId': userIds[2],
        'estimatedReadingTimeMinutes': 750,
        'coverImageUrl': 'https://picsum.photos/400/600?random=5',
      },
      {
        'title': 'Data Structures & Algorithms',
        'subtitle': 'The Complete Guide',
        'description':
            'Master data structures and algorithms with this comprehensive guide.',
        'authors': ['Algorithm Expert'],
        'categories': ['Technology', 'Computer Science'],
        'tags': ['algorithms', 'data structures'],
        'totalPages': 600,
        'totalChapters': 20,
        'language': 'en',
        'averageRating': 4.8,
        'totalRatings': 201,
        'totalReads': 1500,
        'isPublished': true,
        'editorId': userIds[2],
        'estimatedReadingTimeMinutes': 900,
        'coverImageUrl': 'https://picsum.photos/400/600?random=6',
      },
      {
        'title': 'The Startup Journey',
        'subtitle': 'Building Your First Product',
        'description':
            'Learn how to build and launch your first startup. From idea to product.',
        'authors': ['Startup Founder'],
        'categories': ['Business', 'Entrepreneurship'],
        'tags': ['startup', 'business'],
        'totalPages': 350,
        'totalChapters': 13,
        'language': 'en',
        'averageRating': 4.3,
        'totalRatings': 76,
        'totalReads': 520,
        'isPublished': true,
        'editorId': userIds[2],
        'estimatedReadingTimeMinutes': 525,
        'coverImageUrl': 'https://picsum.photos/400/600?random=7',
      },
      {
        'title': 'Design Patterns Explained',
        'subtitle': 'Simple Solutions to Common Problems',
        'description':
            'Understand design patterns with simple explanations and real-world examples.',
        'authors': ['Pattern Master'],
        'categories': ['Technology', 'Software Design'],
        'tags': ['design patterns'],
        'totalPages': 400,
        'totalChapters': 15,
        'language': 'en',
        'averageRating': 4.5,
        'totalRatings': 112,
        'totalReads': 890,
        'isPublished': true,
        'editorId': userIds[2],
        'estimatedReadingTimeMinutes': 600,
        'coverImageUrl': 'https://picsum.photos/400/600?random=8',
      },
    ];

    final bookIds = <String>[];
    for (var bookData in booksData) {
      final bookRef = firestore.collection(AppConstants.booksCollection).doc();
      await bookRef.set({
        ...bookData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      bookIds.add(bookRef.id);
    }
    return bookIds;
  }

  Future<void> _seedChapters(
    FirebaseFirestore firestore,
    List<String> bookIds,
  ) async {
    for (var bookId in bookIds) {
      final numChapters = 5 + (bookIds.indexOf(bookId) % 6);
      for (int i = 1; i <= numChapters; i++) {
        await firestore.collection(AppConstants.chaptersCollection).add({
          'bookId': bookId,
          'title': 'Chapter $i',
          'subtitle': 'Exploring Chapter $i',
          'content': _generateChapterContent(i),
          'chapterNumber': i,
          'pageNumber': (i - 1) * 30 + 1,
          'estimatedReadingTimeMinutes': 20 + (i % 10),
          'isPublished': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  String _generateChapterContent(int chapterNumber) {
    return '''
# Chapter $chapterNumber

This is the content of chapter $chapterNumber. In this chapter, we explore various concepts and ideas that are essential to understanding the broader context of the book.

## Introduction

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

## Main Content

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

## Key Points

1. First important point about chapter $chapterNumber
2. Second key concept to remember
3. Third essential idea for understanding

## Conclusion

In conclusion, chapter $chapterNumber provides valuable insights into the topic at hand.
''';
  }

  Future<void> _seedLibraryItems(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    await firestore
        .collection(AppConstants.libraryCollection)
        .doc(userIds[0])
        .collection('books')
        .doc(bookIds[0])
        .set({
      'bookId': bookIds[0],
      'status': AppConstants.bookStatusReading,
      'progress': 0.35,
      'lastReadAt': FieldValue.serverTimestamp(),
      'readingTime': 120,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await firestore
        .collection(AppConstants.libraryCollection)
        .doc(userIds[0])
        .collection('books')
        .doc(bookIds[1])
        .set({
      'bookId': bookIds[1],
      'status': AppConstants.bookStatusCompleted,
      'progress': 1.0,
      'lastReadAt': FieldValue.serverTimestamp(),
      'readingTime': 480,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await firestore
        .collection(AppConstants.libraryCollection)
        .doc(userIds[1])
        .collection('books')
        .doc(bookIds[3])
        .set({
      'bookId': bookIds[3],
      'status': AppConstants.bookStatusReading,
      'progress': 0.6,
      'lastReadAt': FieldValue.serverTimestamp(),
      'readingTime': 380,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _seedComments(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    final comments = [
      {
        'bookId': bookIds[0],
        'userId': userIds[0],
        'content': 'Great book! Very informative and well-written.'
      },
      {
        'bookId': bookIds[0],
        'userId': userIds[1],
        'content': 'I learned a lot from this. Highly recommended!'
      },
      {
        'bookId': bookIds[2],
        'userId': userIds[1],
        'content': 'Best architecture book I\'ve read.'
      },
    ];

    for (var comment in comments) {
      await firestore.collection(AppConstants.commentsCollection).add({
        'bookId': comment['bookId'],
        'userId': comment['userId'],
        'content': comment['content'],
        'likes': 0,
        'likedBy': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _seedRatings(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    final ratings = [
      {'bookId': bookIds[0], 'userId': userIds[0], 'rating': 5},
      {'bookId': bookIds[0], 'userId': userIds[1], 'rating': 4},
      {'bookId': bookIds[2], 'userId': userIds[1], 'rating': 5},
      {'bookId': bookIds[3], 'userId': userIds[3], 'rating': 4},
    ];

    for (var rating in ratings) {
      await firestore.collection(AppConstants.ratingsCollection).add({
        'bookId': rating['bookId'],
        'userId': rating['userId'],
        'rating': rating['rating'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _seedReadingStats(
    FirebaseFirestore firestore,
    List<String> userIds,
  ) async {
    await firestore
        .collection(AppConstants.readingStatsCollection)
        .doc(userIds[0])
        .set({
      'totalPagesRead': 1250,
      'totalChaptersRead': 45,
      'totalReadingTime': 1800,
      'currentStreak': 15,
      'booksCompleted': 8,
      'booksReading': 3,
      'lastReadingDate': FieldValue.serverTimestamp(),
    });

    await firestore
        .collection(AppConstants.readingStatsCollection)
        .doc(userIds[1])
        .set({
      'totalPagesRead': 2100,
      'totalChaptersRead': 78,
      'totalReadingTime': 3200,
      'currentStreak': 30,
      'booksCompleted': 15,
      'booksReading': 2,
      'lastReadingDate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _seedFollows(
    FirebaseFirestore firestore,
    List<String> userIds,
  ) async {
    await firestore.collection(AppConstants.followsCollection).add({
      'followerId': userIds[0],
      'followingId': userIds[1],
      'createdAt': FieldValue.serverTimestamp(),
    });

    await firestore.collection(AppConstants.followsCollection).add({
      'followerId': userIds[1],
      'followingId': userIds[0],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.storage,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Database Seeding',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text('$_progress%'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isSeeding ? null : _seedDatabase,
              icon: _isSeeding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isSeeding ? 'Seeding...' : 'Start Seeding'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will add sample data to your Firestore database.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

