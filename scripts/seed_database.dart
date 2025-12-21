import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';
import '../lib/core/constants/app_constants.dart';

/// Script để seed sample data vào Firestore
/// Chạy: dart scripts/seed_database.dart
void main() async {
  print('🚀 Starting database seeding...');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    print('✅ Firebase initialized');
    
    // 1. Seed Users
    print('\n📝 Seeding users...');
    final users = await seedUsers(firestore);
    print('✅ Created ${users.length} users');
    
    // 2. Seed Books
    print('\n📚 Seeding books...');
    final books = await seedBooks(firestore, users);
    print('✅ Created ${books.length} books');
    
    // 3. Seed Chapters
    print('\n📖 Seeding chapters...');
    final chaptersCount = await seedChapters(firestore, books);
    print('✅ Created $chaptersCount chapters');
    
    // 4. Seed Library Items
    print('\n📚 Seeding library items...');
    await seedLibraryItems(firestore, users, books);
    print('✅ Created library items');
    
    // 5. Seed Comments
    print('\n💬 Seeding comments...');
    await seedComments(firestore, users, books);
    print('✅ Created comments');
    
    // 6. Seed Ratings
    print('\n⭐ Seeding ratings...');
    await seedRatings(firestore, users, books);
    print('✅ Created ratings');
    
    // 7. Seed Reading Stats
    print('\n📊 Seeding reading stats...');
    await seedReadingStats(firestore, users);
    print('✅ Created reading stats');
    
    // 8. Seed Follows
    print('\n👥 Seeding follows...');
    await seedFollows(firestore, users);
    print('✅ Created follows');
    
    print('\n🎉 Database seeding completed successfully!');
    exit(0);
  } catch (e, stackTrace) {
    print('❌ Error seeding database: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

// Sample Users Data
Future<List<String>> seedUsers(FirebaseFirestore firestore) async {
  final usersData = [
    {
      'email': 'john.doe@example.com',
      'displayName': 'John Doe',
      'role': AppConstants.roleUser,
      'isProfilePublic': true,
      'readingStreak': 15,
      'lastReadingDate': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'email': 'jane.smith@example.com',
      'displayName': 'Jane Smith',
      'role': AppConstants.roleUser,
      'isProfilePublic': true,
      'readingStreak': 30,
      'lastReadingDate': DateTime.now(),
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
      'lastReadingDate': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'email': 'bob.reader@example.com',
      'displayName': 'Bob Reader',
      'role': AppConstants.roleUser,
      'isProfilePublic': true,
      'readingStreak': 12,
      'lastReadingDate': DateTime.now(),
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

// Sample Books Data
Future<List<String>> seedBooks(FirebaseFirestore firestore, List<String> userIds) async {
  final booksData = [
    {
      'title': 'The Art of Flutter Development',
      'subtitle': 'A Comprehensive Guide',
      'description': 'Master Flutter development with this comprehensive guide covering everything from basics to advanced topics. Learn to build beautiful, performant mobile applications.',
      'authors': ['John Flutter', 'Jane Dart'],
      'categories': ['Technology', 'Programming', 'Mobile Development'],
      'tags': ['flutter', 'dart', 'mobile', 'app development'],
      'totalPages': 450,
      'totalChapters': 15,
      'language': 'en',
      'averageRating': 4.5,
      'totalRatings': 120,
      'totalReads': 850,
      'isPublished': true,
      'editorId': userIds[2], // Editor user
      'estimatedReadingTimeMinutes': 600,
      'coverImageUrl': 'https://picsum.photos/400/600?random=1',
    },
    {
      'title': 'Mystery of the Lost Code',
      'subtitle': 'A Developer\'s Adventure',
      'description': 'Join our hero as they navigate through mysterious bugs, cryptic error messages, and the ultimate quest to find the missing semicolon.',
      'authors': ['Code Master'],
      'categories': ['Fiction', 'Adventure', 'Technology'],
      'tags': ['fiction', 'adventure', 'coding', 'mystery'],
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
      'description': 'Learn the principles of clean architecture and how to build maintainable, scalable software systems. Perfect for developers of all levels.',
      'authors': ['Robert Clean', 'Martin Architecture'],
      'categories': ['Technology', 'Software Engineering'],
      'tags': ['architecture', 'clean code', 'software engineering', 'best practices'],
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
      'description': 'Dive deep into the world of artificial intelligence and machine learning. Understand how AI is shaping our future.',
      'authors': ['AI Expert', 'ML Master'],
      'categories': ['Technology', 'Science', 'AI'],
      'tags': ['ai', 'machine learning', 'technology', 'future'],
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
      'description': 'Complete guide to modern web development. Learn HTML, CSS, JavaScript, React, and more. Build real-world projects.',
      'authors': ['Web Guru'],
      'categories': ['Technology', 'Web Development'],
      'tags': ['web', 'javascript', 'react', 'html', 'css'],
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
      'description': 'Master data structures and algorithms with this comprehensive guide. Perfect for coding interviews and competitive programming.',
      'authors': ['Algorithm Expert'],
      'categories': ['Technology', 'Computer Science'],
      'tags': ['algorithms', 'data structures', 'programming', 'interviews'],
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
      'description': 'Learn how to build and launch your first startup. From idea to product, marketing to scaling. Real stories from successful founders.',
      'authors': ['Startup Founder'],
      'categories': ['Business', 'Entrepreneurship'],
      'tags': ['startup', 'business', 'entrepreneurship', 'product'],
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
      'description': 'Understand design patterns with simple explanations and real-world examples. Make your code more maintainable and elegant.',
      'authors': ['Pattern Master'],
      'categories': ['Technology', 'Software Design'],
      'tags': ['design patterns', 'software design', 'best practices'],
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

// Sample Chapters Data
Future<int> seedChapters(FirebaseFirestore firestore, List<String> bookIds) async {
  int totalChapters = 0;
  
  for (var bookId in bookIds) {
    // Create 5-10 chapters per book
    final numChapters = 5 + (bookIds.indexOf(bookId) % 6);
    
    for (int i = 1; i <= numChapters; i++) {
      final chapterRef = firestore.collection(AppConstants.chaptersCollection).doc();
      await chapterRef.set({
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
      totalChapters++;
    }
  }
  
  return totalChapters;
}

String _generateChapterContent(int chapterNumber) {
  return '''
# Chapter $chapterNumber

This is the content of chapter $chapterNumber. In this chapter, we explore various concepts and ideas that are essential to understanding the broader context of the book.

## Introduction

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

## Main Content

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

## Key Points

1. First important point about chapter $chapterNumber
2. Second key concept to remember
3. Third essential idea for understanding
4. Fourth crucial element

## Conclusion

In conclusion, chapter $chapterNumber provides valuable insights into the topic at hand. The concepts discussed here will be important for understanding the subsequent chapters.

Remember to take notes and reflect on what you've learned in this chapter.
''';
}

// Sample Library Items
Future<void> seedLibraryItems(
  FirebaseFirestore firestore,
  List<String> userIds,
  List<String> bookIds,
) async {
  // User 0 has 3 books: reading, completed, want_to_read
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
    'readingTime': 120, // minutes
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
      .doc(userIds[0])
      .collection('books')
      .doc(bookIds[2])
      .set({
    'bookId': bookIds[2],
    'status': AppConstants.bookStatusWantToRead,
    'progress': 0.0,
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  // User 1 has 2 books
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
  
  await firestore
      .collection(AppConstants.libraryCollection)
      .doc(userIds[1])
      .collection('books')
      .doc(bookIds[4])
      .set({
    'bookId': bookIds[4],
    'status': AppConstants.bookStatusCompleted,
    'progress': 1.0,
    'lastReadAt': FieldValue.serverTimestamp(),
    'readingTime': 750,
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  // User 3 has 1 book
  await firestore
      .collection(AppConstants.libraryCollection)
      .doc(userIds[3])
      .collection('books')
      .doc(bookIds[5])
      .set({
    'bookId': bookIds[5],
    'status': AppConstants.bookStatusReading,
    'progress': 0.25,
    'lastReadAt': FieldValue.serverTimestamp(),
    'readingTime': 225,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

// Sample Comments
Future<void> seedComments(
  FirebaseFirestore firestore,
  List<String> userIds,
  List<String> bookIds,
) async {
  final comments = [
    {'bookId': bookIds[0], 'userId': userIds[0], 'content': 'Great book! Very informative and well-written.'},
    {'bookId': bookIds[0], 'userId': userIds[1], 'content': 'I learned a lot from this. Highly recommended!'},
    {'bookId': bookIds[1], 'userId': userIds[0], 'content': 'Interesting story, kept me engaged throughout.'},
    {'bookId': bookIds[2], 'userId': userIds[1], 'content': 'Best architecture book I\'ve read. Clear explanations.'},
    {'bookId': bookIds[3], 'userId': userIds[3], 'content': 'Fascinating insights into AI and ML.'},
    {'bookId': bookIds[4], 'userId': userIds[4], 'content': 'Perfect for beginners and advanced developers alike.'},
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

// Sample Ratings
Future<void> seedRatings(
  FirebaseFirestore firestore,
  List<String> userIds,
  List<String> bookIds,
) async {
  final ratings = [
    {'bookId': bookIds[0], 'userId': userIds[0], 'rating': 5, 'review': 'Excellent book!'},
    {'bookId': bookIds[0], 'userId': userIds[1], 'rating': 4, 'review': 'Very good, but could be more detailed.'},
    {'bookId': bookIds[1], 'userId': userIds[0], 'rating': 4, 'review': 'Enjoyable read.'},
    {'bookId': bookIds[2], 'userId': userIds[1], 'rating': 5, 'review': 'Must-read for developers!'},
    {'bookId': bookIds[3], 'userId': userIds[3], 'rating': 4, 'review': 'Great introduction to AI.'},
    {'bookId': bookIds[4], 'userId': userIds[4], 'rating': 5, 'review': 'Comprehensive and well-structured.'},
    {'bookId': bookIds[5], 'userId': userIds[0], 'rating': 5, 'review': 'Perfect for interview preparation.'},
  ];
  
  for (var rating in ratings) {
    await firestore.collection(AppConstants.ratingsCollection).add({
      'bookId': rating['bookId'],
      'userId': rating['userId'],
      'rating': rating['rating'],
      'review': rating['review'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

// Sample Reading Stats
Future<void> seedReadingStats(
  FirebaseFirestore firestore,
  List<String> userIds,
) async {
  // User 0 stats
  await firestore
      .collection(AppConstants.readingStatsCollection)
      .doc(userIds[0])
      .set({
    'totalPagesRead': 1250,
    'totalChaptersRead': 45,
    'totalReadingTime': 1800, // minutes
    'currentStreak': 15,
    'longestStreak': 20,
    'booksCompleted': 8,
    'booksReading': 3,
    'lastReadingDate': FieldValue.serverTimestamp(),
    'dailyStats': {
      DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch: {
        'pagesRead': 25,
        'readingTime': 45,
      },
      DateTime.now().millisecondsSinceEpoch: {
        'pagesRead': 30,
        'readingTime': 50,
      },
    },
  });
  
  // User 1 stats
  await firestore
      .collection(AppConstants.readingStatsCollection)
      .doc(userIds[1])
      .set({
    'totalPagesRead': 2100,
    'totalChaptersRead': 78,
    'totalReadingTime': 3200,
    'currentStreak': 30,
    'longestStreak': 35,
    'booksCompleted': 15,
    'booksReading': 2,
    'lastReadingDate': FieldValue.serverTimestamp(),
    'dailyStats': {
      DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch: {
        'pagesRead': 40,
        'readingTime': 60,
      },
      DateTime.now().millisecondsSinceEpoch: {
        'pagesRead': 35,
        'readingTime': 55,
      },
    },
  });
  
  // User 3 stats
  await firestore
      .collection(AppConstants.readingStatsCollection)
      .doc(userIds[3])
      .set({
    'totalPagesRead': 850,
    'totalChaptersRead': 32,
    'totalReadingTime': 1200,
    'currentStreak': 7,
    'longestStreak': 12,
    'booksCompleted': 5,
    'booksReading': 1,
    'lastReadingDate': FieldValue.serverTimestamp(),
  });
}

// Sample Follows
Future<void> seedFollows(
  FirebaseFirestore firestore,
  List<String> userIds,
) async {
  // User 0 follows User 1
  await firestore.collection(AppConstants.followsCollection).add({
    'followerId': userIds[0],
    'followingId': userIds[1],
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  // User 1 follows User 0
  await firestore.collection(AppConstants.followsCollection).add({
    'followerId': userIds[1],
    'followingId': userIds[0],
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  // User 3 follows User 1
  await firestore.collection(AppConstants.followsCollection).add({
    'followerId': userIds[3],
    'followingId': userIds[1],
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  // User 4 follows User 0
  await firestore.collection(AppConstants.followsCollection).add({
    'followerId': userIds[4],
    'followingId': userIds[0],
    'createdAt': FieldValue.serverTimestamp(),
  });
}

