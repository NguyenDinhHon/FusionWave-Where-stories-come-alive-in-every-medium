import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../../../core/constants/app_constants.dart';

/// Comprehensive seed data page với rất nhiều dữ liệu cho tất cả các bảng
class ComprehensiveSeedDataPage extends StatefulWidget {
  const ComprehensiveSeedDataPage({super.key});

  @override
  State<ComprehensiveSeedDataPage> createState() => _ComprehensiveSeedDataPageState();
}

class _ComprehensiveSeedDataPageState extends State<ComprehensiveSeedDataPage> {
  bool _isSeeding = false;
  String _status = 'Ready to seed';
  int _progress = 0;
  final Random _random = Random();

  Future<void> _seedDatabase() async {
    setState(() {
      _isSeeding = true;
      _status = 'Initializing...';
      _progress = 0;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Seed Users (30 users)
      setState(() {
        _status = 'Seeding users (30)...';
        _progress = 5;
      });
      final users = await _seedUsers(firestore);

      // 2. Seed Books (100 books)
      setState(() {
        _status = 'Seeding books (100)...';
        _progress = 15;
      });
      final books = await _seedBooks(firestore, users);

      // 3. Seed Chapters (10-20 chapters per book)
      setState(() {
        _status = 'Seeding chapters...';
        _progress = 30;
      });
      final chapters = await _seedChapters(firestore, books);

      // 4. Seed Library Items
      setState(() {
        _status = 'Seeding library items...';
        _progress = 45;
      });
      await _seedLibraryItems(firestore, users, books);

      // 5. Seed Bookmarks
      setState(() {
        _status = 'Seeding bookmarks...';
        _progress = 55;
      });
      await _seedBookmarks(firestore, users, books, chapters);

      // 6. Seed Notes
      setState(() {
        _status = 'Seeding notes...';
        _progress = 60;
      });
      await _seedNotes(firestore, users, books, chapters);

      // 7. Seed Comments
      setState(() {
        _status = 'Seeding comments...';
        _progress = 65;
      });
      await _seedComments(firestore, users, books);

      // 8. Seed Ratings
      setState(() {
        _status = 'Seeding ratings...';
        _progress = 70;
      });
      await _seedRatings(firestore, users, books);

      // 9. Seed Collections
      setState(() {
        _status = 'Seeding collections...';
        _progress = 75;
      });
      await _seedCollections(firestore, users, books);

      // 10. Seed Challenges
      setState(() {
        _status = 'Seeding challenges...';
        _progress = 80;
      });
      await _seedChallenges(firestore, users);

      // 11. Seed Reading Stats
      setState(() {
        _status = 'Seeding reading stats...';
        _progress = 85;
      });
      await _seedReadingStats(firestore, users);

      // 12. Seed Follows
      setState(() {
        _status = 'Seeding follows...';
        _progress = 90;
      });
      await _seedFollows(firestore, users);

      // 13. Seed Notifications
      setState(() {
        _status = 'Seeding notifications...';
        _progress = 95;
      });
      await _seedNotifications(firestore, users, books);

      setState(() {
        _status = '✅ Database seeding completed successfully!';
        _progress = 100;
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database seeded successfully with comprehensive data!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
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

  // Seed additional data (uses existing users and books)
  Future<void> _addMoreData() async {
    setState(() {
      _isSeeding = true;
      _status = 'Loading existing data...';
      _progress = 0;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // Get existing users
      setState(() {
        _status = 'Loading existing users...';
        _progress = 10;
      });
      final usersSnapshot = await firestore.collection(AppConstants.usersCollection).limit(100).get();
      final existingUsers = usersSnapshot.docs.map((doc) => doc.id).toList();
      
      if (existingUsers.isEmpty) {
        setState(() {
          _status = 'No existing users found. Please run full seed first.';
          _isSeeding = false;
        });
        return;
      }

      // Get existing books
      setState(() {
        _status = 'Loading existing books...';
        _progress = 20;
      });
      final booksSnapshot = await firestore.collection(AppConstants.booksCollection).limit(200).get();
      final existingBooks = booksSnapshot.docs.map((doc) => doc.id).toList();
      
      if (existingBooks.isEmpty) {
        setState(() {
          _status = 'No existing books found. Please run full seed first.';
          _isSeeding = false;
        });
        return;
      }

      // Get existing chapters
      setState(() {
        _status = 'Loading existing chapters...';
        _progress = 30;
      });
      final chaptersMap = <String, List<String>>{};
      for (var bookId in existingBooks.take(50)) {
        final chaptersSnapshot = await firestore
            .collection(AppConstants.chaptersCollection)
            .where('bookId', isEqualTo: bookId)
            .get();
        chaptersMap[bookId] = chaptersSnapshot.docs.map((doc) => doc.id).toList();
      }

      // Add more library items
      setState(() {
        _status = 'Adding library items...';
        _progress = 40;
      });
      await _addMoreLibraryItems(firestore, existingUsers, existingBooks);

      // Add more bookmarks
      setState(() {
        _status = 'Adding bookmarks...';
        _progress = 50;
      });
      await _addMoreBookmarks(firestore, existingUsers, existingBooks, chaptersMap);

      // Add more notes
      setState(() {
        _status = 'Adding notes...';
        _progress = 55;
      });
      await _addMoreNotes(firestore, existingUsers, existingBooks, chaptersMap);

      // Add more comments
      setState(() {
        _status = 'Adding comments...';
        _progress = 60;
      });
      await _addMoreComments(firestore, existingUsers, existingBooks);

      // Add more ratings
      setState(() {
        _status = 'Adding ratings...';
        _progress = 70;
      });
      await _addMoreRatings(firestore, existingUsers, existingBooks);

      // Add more collections
      setState(() {
        _status = 'Adding collections...';
        _progress = 80;
      });
      await _addMoreCollections(firestore, existingUsers, existingBooks);

      // Add more follows
      setState(() {
        _status = 'Adding follows...';
        _progress = 90;
      });
      await _addMoreFollows(firestore, existingUsers);

      setState(() {
        _status = '✅ Additional data added successfully!';
        _progress = 100;
        _isSeeding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Additional data added successfully!'),
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
            content: Text('Error adding data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addMoreLibraryItems(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final numBooks = _random.nextInt(5); // 0-4 more books per user
      
      for (int j = 0; j < numBooks; j++) {
        final bookId = bookIds[_random.nextInt(bookIds.length)];
        
        // Check if already exists
        final existing = await firestore
            .collection(AppConstants.libraryCollection)
            .doc(userId)
            .collection('books')
            .doc(bookId)
            .get();
        
        if (!existing.exists) {
          final statusIndex = _random.nextInt(4);
          final status = [
            AppConstants.bookStatusReading,
            AppConstants.bookStatusCompleted,
            AppConstants.bookStatusWantToRead,
            AppConstants.bookStatusDropped,
          ][statusIndex];
          
          await firestore
              .collection(AppConstants.libraryCollection)
              .doc(userId)
              .collection('books')
              .doc(bookId)
              .set({
            'bookId': bookId,
            'status': status,
            'progress': status == AppConstants.bookStatusCompleted ? 1.0 :
                       status == AppConstants.bookStatusWantToRead ? 0.0 :
                       status == AppConstants.bookStatusDropped ? _random.nextDouble() * 0.5 :
                       _random.nextDouble() * 0.9 + 0.1,
            'lastReadAt': FieldValue.serverTimestamp(),
            'readingTime': _random.nextInt(600),
            'currentChapter': status == AppConstants.bookStatusReading ? _random.nextInt(10) + 1 : null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  Future<void> _addMoreBookmarks(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
    Map<String, List<String>> chapters,
  ) async {
    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final numBookmarks = _random.nextInt(10); // 0-9 more bookmarks
      
      for (int j = 0; j < numBookmarks; j++) {
        final bookId = bookIds[_random.nextInt(bookIds.length)];
        final bookChapters = chapters[bookId] ?? [];
        if (bookChapters.isEmpty) continue;
        
        final chapterId = bookChapters[_random.nextInt(bookChapters.length)];
        
        await firestore.collection(AppConstants.bookmarksCollection).add({
          'userId': userId,
          'bookId': bookId,
          'chapterId': chapterId,
          'chapterNumber': _random.nextInt(20) + 1,
          'pageNumber': _random.nextInt(500) + 1,
          'note': _random.nextBool() ? 'Important bookmark' : null,
          'highlightedText': _random.nextBool() ? 'This is an important passage' : null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> _addMoreNotes(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
    Map<String, List<String>> chapters,
  ) async {
    final highlightColors = ['#FFFF00', '#00FF00', '#00FFFF', '#FF00FF', '#FFA500'];
    
    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final numNotes = _random.nextInt(8); // 0-7 more notes
      
      for (int j = 0; j < numNotes; j++) {
        final bookId = bookIds[_random.nextInt(bookIds.length)];
        final bookChapters = chapters[bookId] ?? [];
        if (bookChapters.isEmpty) continue;
        
        final chapterId = bookChapters[_random.nextInt(bookChapters.length)];
        
        await firestore.collection(AppConstants.notesCollection).add({
          'userId': userId,
          'bookId': bookId,
          'chapterId': chapterId,
          'chapterNumber': _random.nextInt(20) + 1,
          'highlightedText': 'This is an important passage that I want to remember.',
          'note': 'My thoughts: This is very insightful and worth revisiting.',
          'startPosition': _random.nextInt(1000),
          'endPosition': _random.nextInt(1000) + 1000,
          'color': highlightColors[_random.nextInt(highlightColors.length)],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> _addMoreComments(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    final comments = [
      'Great book! Very informative and well-written.',
      'I learned a lot from this. Highly recommended!',
      'Interesting perspective, enjoyed reading it.',
      'Best book I\'ve read on this topic.',
      'Clear explanations and practical examples.',
      'A must-read for anyone interested in this field.',
      'Well-structured and easy to follow.',
      'Excellent resource for beginners.',
      'Comprehensive coverage of the subject.',
      'Great insights and real-world applications.',
    ];

    for (int i = 0; i < bookIds.length; i++) {
      final bookId = bookIds[i];
      final numComments = _random.nextInt(10); // 0-9 more comments per book
      
      for (int j = 0; j < numComments; j++) {
        final userId = userIds[_random.nextInt(userIds.length)];
        await firestore.collection(AppConstants.commentsCollection).add({
          'bookId': bookId,
          'userId': userId,
          'content': comments[_random.nextInt(comments.length)],
          'likes': _random.nextInt(50),
          'likedBy': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> _addMoreRatings(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    for (int i = 0; i < bookIds.length; i++) {
      final bookId = bookIds[i];
      final numRatings = _random.nextInt(15); // 0-14 more ratings per book
      
      for (int j = 0; j < numRatings; j++) {
        final userId = userIds[_random.nextInt(userIds.length)];
        
        // Check if user already rated this book
        final existingRatings = await firestore
            .collection(AppConstants.ratingsCollection)
            .where('bookId', isEqualTo: bookId)
            .where('userId', isEqualTo: userId)
            .get();
        
        if (existingRatings.docs.isEmpty) {
          await firestore.collection(AppConstants.ratingsCollection).add({
            'bookId': bookId,
            'userId': userId,
            'rating': 1 + _random.nextInt(5), // 1-5 stars
            'review': _random.nextBool() ? 'Great book!' : null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  Future<void> _addMoreCollections(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    final collectionNames = [
      'My Favorites', 'Must Read', 'Technology Books', 'Programming Guides',
      'Design Collection', 'Business Books', 'Science Fiction', 'Non-Fiction',
      'Learning Resources', 'Reference Books', 'Inspiration', 'Classics'
    ];

    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final numCollections = _random.nextInt(3); // 0-2 more collections per user
      
      for (int j = 0; j < numCollections; j++) {
        final numBooks = 3 + _random.nextInt(8); // 3-10 books per collection
        final collectionBooks = <String>[];
        for (int k = 0; k < numBooks; k++) {
          collectionBooks.add(bookIds[_random.nextInt(bookIds.length)]);
        }
        
        await firestore.collection(AppConstants.collectionsCollection).add({
          'userId': userId,
          'name': collectionNames[_random.nextInt(collectionNames.length)],
          'description': 'A curated collection of books',
          'bookIds': collectionBooks,
          'isPublic': _random.nextBool(),
          'coverImageUrl': 'https://picsum.photos/400/600?random=${i * 10 + j + 3000}',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> _addMoreFollows(
    FirebaseFirestore firestore,
    List<String> userIds,
  ) async {
    for (int i = 0; i < userIds.length; i++) {
      final followerId = userIds[i];
      final numFollows = _random.nextInt(5); // 0-4 more follows per user
      
      for (int j = 0; j < numFollows; j++) {
        String followingId;
        do {
          followingId = userIds[_random.nextInt(userIds.length)];
        } while (followingId == followerId);
        
        // Check if already following
        final existingFollows = await firestore
            .collection(AppConstants.followsCollection)
            .where('followerId', isEqualTo: followerId)
            .where('followingId', isEqualTo: followingId)
            .get();
        
        if (existingFollows.docs.isEmpty) {
          await firestore.collection(AppConstants.followsCollection).add({
            'followerId': followerId,
            'followingId': followingId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  // Seed 30 users
  Future<List<String>> _seedUsers(FirebaseFirestore firestore) async {
    final firstNames = [
      'John', 'Jane', 'Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank',
      'Grace', 'Henry', 'Ivy', 'Jack', 'Kate', 'Liam', 'Mia', 'Noah',
      'Olivia', 'Paul', 'Quinn', 'Rachel', 'Sam', 'Tina', 'Uma', 'Victor',
      'Wendy', 'Xavier', 'Yara', 'Zoe', 'Alex', 'Taylor'
    ];
    final lastNames = [
      'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller',
      'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Wilson',
      'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee'
    ];

    final userIds = <String>[];
    for (int i = 0; i < 30; i++) {
      final firstName = firstNames[i % firstNames.length];
      final lastName = lastNames[i % lastNames.length];
      final email = '${firstName.toLowerCase()}.${lastName.toLowerCase()}${i > 0 ? i : ''}@example.com';
      
      final userRef = firestore.collection(AppConstants.usersCollection).doc();
      await userRef.set({
        'email': email,
        'displayName': '$firstName $lastName',
        'role': i == 0 ? AppConstants.roleAdmin : 
                i == 1 ? AppConstants.roleEditor : 
                AppConstants.roleUser,
        'isProfilePublic': _random.nextBool(),
        'readingStreak': _random.nextInt(50),
        'lastReadingDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      userIds.add(userRef.id);
    }
    return userIds;
  }

  // Seed 100 books
  Future<List<String>> _seedBooks(FirebaseFirestore firestore, List<String> userIds) async {
    final bookTitles = [
      'The Art of Flutter Development', 'Mystery of the Lost Code',
      'Clean Architecture Principles', 'The Future of AI',
      'Web Development Mastery', 'Data Structures & Algorithms',
      'The Startup Journey', 'Design Patterns Explained',
      'Machine Learning Fundamentals', 'Cloud Computing Essentials',
      'Mobile App Design', 'Database Systems', 'Network Security',
      'Software Testing', 'DevOps Handbook', 'Agile Methodology',
      'UI/UX Design', 'Game Development', 'Blockchain Basics',
      'Cybersecurity Guide', 'Python Programming', 'JavaScript Mastery',
      'React Native Development', 'Vue.js Essentials', 'Angular Framework',
      'Node.js Backend', 'Docker & Kubernetes', 'Microservices Architecture',
      'API Design', 'GraphQL Complete', 'RESTful Services',
      'Mobile Security', 'iOS Development', 'Android Development',
      'Swift Programming', 'Kotlin Essentials', 'Dart Language',
      'TypeScript Guide', 'CSS Mastery', 'HTML5 Complete',
      'Responsive Design', 'Progressive Web Apps', 'Serverless Architecture',
      'AWS Cloud', 'Azure Fundamentals', 'Google Cloud Platform',
      'Linux Administration', 'Shell Scripting', 'Git Version Control',
      'CI/CD Pipeline', 'Test Automation', 'Performance Optimization',
      'Code Review', 'Technical Writing', 'Open Source',
      'Startup Strategy', 'Product Management', 'Marketing Digital',
      'Content Creation', 'Social Media', 'E-commerce',
      'Business Analytics', 'Data Science', 'Big Data',
      'Artificial Intelligence', 'Deep Learning', 'Neural Networks',
      'Computer Vision', 'Natural Language Processing', 'Robotics',
      'IoT Development', 'Embedded Systems', 'Arduino Programming',
      'Raspberry Pi', 'Electronics Basics', '3D Printing',
      'Virtual Reality', 'Augmented Reality', 'Game Design',
      'Character Design', 'Storytelling', 'Creative Writing',
      'Photography', 'Video Editing', 'Music Production',
      'Graphic Design', 'Branding', 'Typography',
      'Color Theory', 'Animation', 'Illustration',
      'Web Animation', 'Motion Graphics', 'User Research',
      'Usability Testing', 'Information Architecture', 'Wireframing',
      'Prototyping', 'Design Systems', 'Accessibility',
    ];

    final categories = [
      'Technology', 'Programming', 'Mobile Development', 'Web Development',
      'Software Engineering', 'Computer Science', 'AI', 'Machine Learning',
      'Business', 'Entrepreneurship', 'Design', 'Creative',
      'Science', 'Mathematics', 'Engineering', 'Security'
    ];

    final authors = [
      'John Flutter', 'Jane Dart', 'Code Master', 'Robert Clean',
      'Martin Architecture', 'AI Expert', 'ML Master', 'Web Guru',
      'Algorithm Expert', 'Startup Founder', 'Pattern Master', 'Design Pro',
      'Security Expert', 'Cloud Architect', 'DevOps Guru', 'Test Master'
    ];

    final bookIds = <String>[];
    final editorId = userIds[1]; // Editor user

    for (int i = 0; i < 100; i++) {
      final title = bookTitles[i % bookTitles.length];
      final numAuthors = 1 + (i % 3);
      final bookAuthors = List.generate(numAuthors, (j) => authors[(i + j) % authors.length]);
      final numCategories = 1 + (i % 3);
      final bookCategories = List.generate(numCategories, (j) => categories[(i + j) % categories.length]);
      
      final bookRef = firestore.collection(AppConstants.booksCollection).doc();
      await bookRef.set({
        'title': title,
        'subtitle': 'A Comprehensive Guide',
        'description': _generateBookDescription(title),
        'authors': bookAuthors,
        'categories': bookCategories,
        'tags': _generateTags(title, bookCategories),
        'totalPages': 200 + _random.nextInt(600),
        'totalChapters': 10 + _random.nextInt(20),
        'language': 'en',
        'averageRating': 3.5 + _random.nextDouble() * 1.5,
        'totalRatings': _random.nextInt(500),
        'totalReads': _random.nextInt(2000),
        'isPublished': true,
        'editorId': editorId,
        'estimatedReadingTimeMinutes': 300 + _random.nextInt(900),
        'coverImageUrl': 'https://picsum.photos/400/600?random=${i + 1000}',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      bookIds.add(bookRef.id);
    }
    return bookIds;
  }

  String _generateBookDescription(String title) {
    return 'Discover the comprehensive guide to $title. This book covers everything you need to know, from fundamentals to advanced concepts. Perfect for beginners and experienced professionals alike.';
  }

  List<String> _generateTags(String title, List<String> categories) {
    final words = title.toLowerCase().split(' ');
    final tags = <String>[];
    tags.addAll(categories.map((c) => c.toLowerCase()));
    tags.addAll(words.where((w) => w.length > 3));
    return tags.take(5).toList();
  }

  // Seed chapters for all books
  Future<Map<String, List<String>>> _seedChapters(
    FirebaseFirestore firestore,
    List<String> bookIds,
  ) async {
    final allChapters = <String, List<String>>{};
    
    for (var bookId in bookIds) {
      final bookDoc = await firestore.collection(AppConstants.booksCollection).doc(bookId).get();
      final bookData = bookDoc.data()!;
      final totalChapters = bookData['totalChapters'] as int;
      
      final chapterIds = <String>[];
      for (int i = 1; i <= totalChapters; i++) {
        final chapterRef = firestore.collection(AppConstants.chaptersCollection).doc();
        await chapterRef.set({
          'bookId': bookId,
          'title': 'Chapter $i: ${_generateChapterTitle(i)}',
          'subtitle': 'Exploring Chapter $i',
          'content': _generateChapterContent(i),
          'chapterNumber': i,
          'pageNumber': (i - 1) * 30 + 1,
          'estimatedReadingTimeMinutes': 15 + _random.nextInt(30),
          'isPublished': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        chapterIds.add(chapterRef.id);
      }
      allChapters[bookId] = chapterIds;
    }
    
    return allChapters;
  }

  String _generateChapterTitle(int chapterNumber) {
    final titles = [
      'Introduction', 'Getting Started', 'Fundamentals', 'Advanced Concepts',
      'Best Practices', 'Case Studies', 'Real World Examples', 'Troubleshooting',
      'Optimization', 'Future Trends', 'Conclusion', 'Next Steps',
      'Deep Dive', 'Mastering', 'Exploring', 'Understanding',
      'Implementing', 'Designing', 'Building', 'Creating'
    ];
    return titles[chapterNumber % titles.length];
  }

  String _generateChapterContent(int chapterNumber) {
    return '''
# Chapter $chapterNumber: ${_generateChapterTitle(chapterNumber)}

## Introduction

This chapter explores the fundamental concepts and principles that form the foundation of our discussion. We will dive deep into the core ideas and examine how they apply in real-world scenarios.

## Main Content

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## Key Concepts

1. **First Important Concept**: This is a crucial idea that you need to understand thoroughly.
2. **Second Key Principle**: Another essential concept that builds upon the first.
3. **Third Fundamental Element**: A critical component that ties everything together.
4. **Fourth Practical Application**: How to apply these concepts in real situations.

## Examples and Case Studies

Here are some practical examples that illustrate the concepts discussed:

- Example 1: A real-world scenario demonstrating the application
- Example 2: Another case study showing different aspects
- Example 3: A complex example that combines multiple concepts

## Best Practices

When working with these concepts, keep in mind:

- Always consider the context
- Test your understanding with practical exercises
- Review the material regularly
- Seek help when needed

## Conclusion

In conclusion, chapter $chapterNumber provides valuable insights and practical knowledge. The concepts covered here are essential for understanding the broader context and will be referenced in subsequent chapters.

Remember to practice what you've learned and continue building upon these foundations.
''';
  }

  // Seed library items
  Future<void> _seedLibraryItems(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final numBooks = 3 + _random.nextInt(10); // 3-12 books per user
      
      for (int j = 0; j < numBooks; j++) {
        final bookId = bookIds[_random.nextInt(bookIds.length)];
        final statusIndex = _random.nextInt(4);
        final status = [
          AppConstants.bookStatusReading,
          AppConstants.bookStatusCompleted,
          AppConstants.bookStatusWantToRead,
          AppConstants.bookStatusDropped,
        ][statusIndex];
        
        await firestore
            .collection(AppConstants.libraryCollection)
            .doc(userId)
            .collection('books')
            .doc(bookId)
            .set({
          'bookId': bookId,
          'status': status,
          'progress': status == AppConstants.bookStatusCompleted ? 1.0 :
                     status == AppConstants.bookStatusWantToRead ? 0.0 :
                     status == AppConstants.bookStatusDropped ? _random.nextDouble() * 0.5 :
                     _random.nextDouble() * 0.9 + 0.1,
          'lastReadAt': FieldValue.serverTimestamp(),
          'readingTime': _random.nextInt(600),
          'currentChapter': status == AppConstants.bookStatusReading ? _random.nextInt(10) + 1 : null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Seed bookmarks
  Future<void> _seedBookmarks(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
    Map<String, List<String>> chapters,
  ) async {
    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final numBookmarks = _random.nextInt(20); // 0-19 bookmarks per user
      
      for (int j = 0; j < numBookmarks; j++) {
        final bookId = bookIds[_random.nextInt(bookIds.length)];
        final bookChapters = chapters[bookId] ?? [];
        if (bookChapters.isEmpty) continue;
        
        final chapterId = bookChapters[_random.nextInt(bookChapters.length)];
        
        await firestore.collection(AppConstants.bookmarksCollection).add({
          'userId': userId,
          'bookId': bookId,
          'chapterId': chapterId,
          'chapterNumber': _random.nextInt(20) + 1,
          'pageNumber': _random.nextInt(500) + 1,
          'note': _random.nextBool() ? 'Important bookmark' : null,
          'highlightedText': _random.nextBool() ? 'This is an important passage' : null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Seed notes
  Future<void> _seedNotes(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
    Map<String, List<String>> chapters,
  ) async {
    final highlightColors = ['#FFFF00', '#00FF00', '#00FFFF', '#FF00FF', '#FFA500'];
    
    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final numNotes = _random.nextInt(15); // 0-14 notes per user
      
      for (int j = 0; j < numNotes; j++) {
        final bookId = bookIds[_random.nextInt(bookIds.length)];
        final bookChapters = chapters[bookId] ?? [];
        if (bookChapters.isEmpty) continue;
        
        final chapterId = bookChapters[_random.nextInt(bookChapters.length)];
        
        await firestore.collection(AppConstants.notesCollection).add({
          'userId': userId,
          'bookId': bookId,
          'chapterId': chapterId,
          'chapterNumber': _random.nextInt(20) + 1,
          'highlightedText': 'This is an important passage that I want to remember.',
          'note': 'My thoughts: This is very insightful and worth revisiting.',
          'startPosition': _random.nextInt(1000),
          'endPosition': _random.nextInt(1000) + 1000,
          'color': highlightColors[_random.nextInt(highlightColors.length)],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Seed comments
  Future<void> _seedComments(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    final comments = [
      'Great book! Very informative and well-written.',
      'I learned a lot from this. Highly recommended!',
      'Interesting perspective, enjoyed reading it.',
      'Best book I\'ve read on this topic.',
      'Clear explanations and practical examples.',
      'A must-read for anyone interested in this field.',
      'Well-structured and easy to follow.',
      'Excellent resource for beginners.',
      'Comprehensive coverage of the subject.',
      'Great insights and real-world applications.',
    ];

    for (int i = 0; i < bookIds.length; i++) {
      final bookId = bookIds[i];
      final numComments = _random.nextInt(20); // 0-19 comments per book
      
      for (int j = 0; j < numComments; j++) {
        final userId = userIds[_random.nextInt(userIds.length)];
        await firestore.collection(AppConstants.commentsCollection).add({
          'bookId': bookId,
          'userId': userId,
          'content': comments[_random.nextInt(comments.length)],
          'likes': _random.nextInt(50),
          'likedBy': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Seed ratings
  Future<void> _seedRatings(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    for (int i = 0; i < bookIds.length; i++) {
      final bookId = bookIds[i];
      final numRatings = 5 + _random.nextInt(30); // 5-34 ratings per book
      
      final ratedUsers = <String>{};
      for (int j = 0; j < numRatings; j++) {
        String userId;
        do {
          userId = userIds[_random.nextInt(userIds.length)];
        } while (ratedUsers.contains(userId));
        ratedUsers.add(userId);
        
        await firestore.collection(AppConstants.ratingsCollection).add({
          'bookId': bookId,
          'userId': userId,
          'rating': 1 + _random.nextInt(5), // 1-5 stars
          'review': _random.nextBool() ? 'Great book!' : null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Seed collections
  Future<void> _seedCollections(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    final collectionNames = [
      'My Favorites', 'Must Read', 'Technology Books', 'Programming Guides',
      'Design Collection', 'Business Books', 'Science Fiction', 'Non-Fiction',
      'Learning Resources', 'Reference Books', 'Inspiration', 'Classics'
    ];

    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final numCollections = _random.nextInt(5); // 0-4 collections per user
      
      for (int j = 0; j < numCollections; j++) {
        final numBooks = 3 + _random.nextInt(10); // 3-12 books per collection
        final collectionBooks = <String>[];
        for (int k = 0; k < numBooks; k++) {
          collectionBooks.add(bookIds[_random.nextInt(bookIds.length)]);
        }
        
        await firestore.collection(AppConstants.collectionsCollection).add({
          'userId': userId,
          'name': collectionNames[_random.nextInt(collectionNames.length)],
          'description': 'A curated collection of books',
          'bookIds': collectionBooks,
          'isPublic': _random.nextBool(),
          'coverImageUrl': 'https://picsum.photos/400/600?random=${i * 10 + j + 2000}',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Seed challenges
  Future<void> _seedChallenges(
    FirebaseFirestore firestore,
    List<String> userIds,
  ) async {
    final challengeTypes = ['pages', 'chapters', 'books', 'minutes'];
    final challengeTitles = [
      'Read 100 Pages This Month',
      'Complete 5 Books This Year',
      'Read 30 Minutes Daily',
      'Finish 10 Chapters This Week',
      'Read Every Day for 30 Days',
    ];

    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final numChallenges = _random.nextInt(3); // 0-2 challenges per user
      
      for (int j = 0; j < numChallenges; j++) {
        final type = challengeTypes[_random.nextInt(challengeTypes.length)];
        final targetValue = type == 'pages' ? 100 + _random.nextInt(400) :
                           type == 'chapters' ? 5 + _random.nextInt(20) :
                           type == 'books' ? 1 + _random.nextInt(10) :
                           30 + _random.nextInt(120);
        
        final startDate = DateTime.now().subtract(Duration(days: _random.nextInt(30)));
        final endDate = startDate.add(Duration(days: 30 + _random.nextInt(60)));
        
        await firestore.collection(AppConstants.challengesCollection).add({
          'userId': userId,
          'title': challengeTitles[_random.nextInt(challengeTitles.length)],
          'description': 'Challenge yourself to read more!',
          'type': type,
          'targetValue': targetValue,
          'currentValue': _random.nextInt(targetValue),
          'startDate': Timestamp.fromDate(startDate),
          'endDate': Timestamp.fromDate(endDate),
          'isCompleted': _random.nextBool(),
          'completedAt': _random.nextBool() ? FieldValue.serverTimestamp() : null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Seed reading stats
  Future<void> _seedReadingStats(
    FirebaseFirestore firestore,
    List<String> userIds,
  ) async {
    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final dailyStats = <String, Map<String, dynamic>>{};
      
      // Generate daily stats for last 30 days
      for (int day = 0; day < 30; day++) {
        if (_random.nextBool()) { // 50% chance of reading on each day
          final date = DateTime.now().subtract(Duration(days: day));
          dailyStats[date.millisecondsSinceEpoch.toString()] = {
            'pagesRead': _random.nextInt(50),
            'readingTime': _random.nextInt(120),
          };
        }
      }
      
      await firestore
          .collection(AppConstants.readingStatsCollection)
          .doc(userId)
          .set({
        'totalPagesRead': _random.nextInt(5000),
        'totalChaptersRead': _random.nextInt(200),
        'totalReadingTime': _random.nextInt(10000),
        'currentStreak': _random.nextInt(50),
        'longestStreak': _random.nextInt(100),
        'booksCompleted': _random.nextInt(50),
        'booksReading': _random.nextInt(10),
        'lastReadingDate': FieldValue.serverTimestamp(),
        'dailyStats': dailyStats,
      });
    }
  }

  // Seed follows
  Future<void> _seedFollows(
    FirebaseFirestore firestore,
    List<String> userIds,
  ) async {
    for (int i = 0; i < userIds.length; i++) {
      final followerId = userIds[i];
      final numFollows = _random.nextInt(10); // 0-9 follows per user
      
      final followedUsers = <String>{};
      for (int j = 0; j < numFollows; j++) {
        String followingId;
        do {
          followingId = userIds[_random.nextInt(userIds.length)];
        } while (followingId == followerId || followedUsers.contains(followingId));
        followedUsers.add(followingId);
        
        await firestore.collection(AppConstants.followsCollection).add({
          'followerId': followerId,
          'followingId': followingId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Seed notifications
  Future<void> _seedNotifications(
    FirebaseFirestore firestore,
    List<String> userIds,
    List<String> bookIds,
  ) async {
    final notificationTypes = [
      'new_book', 'chapter_update', 'comment_reply', 'like',
      'follow', 'challenge_complete', 'reading_reminder'
    ];
    final notificationTitles = [
      'New Book Available',
      'Chapter Updated',
      'New Comment',
      'Someone Liked Your Comment',
      'New Follower',
      'Challenge Completed!',
      'Daily Reading Reminder',
    ];

    for (int i = 0; i < userIds.length; i++) {
      final userId = userIds[i];
      final numNotifications = _random.nextInt(20); // 0-19 notifications per user
      
      for (int j = 0; j < numNotifications; j++) {
        final type = notificationTypes[_random.nextInt(notificationTypes.length)];
        final title = notificationTitles[_random.nextInt(notificationTitles.length)];
        
        await firestore
            .collection(AppConstants.notificationsCollection)
            .doc(userId)
            .collection('notifications')
            .add({
          'type': type,
          'title': title,
          'message': 'You have a new notification',
          'bookId': type == 'new_book' || type == 'chapter_update' 
              ? bookIds[_random.nextInt(bookIds.length)] 
              : null,
          'isRead': _random.nextBool(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprehensive Seed Database'),
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
              'Comprehensive Database Seeding',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isSeeding ? null : _seedDatabase,
                  icon: _isSeeding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isSeeding ? 'Seeding...' : 'Start Comprehensive Seeding'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isSeeding ? null : _addMoreData,
                  icon: _isSeeding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(_isSeeding ? 'Adding...' : 'Add More Data'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'This will add comprehensive sample data:\n'
              '• 30 Users\n'
              '• 100 Books\n'
              '• 1000+ Chapters\n'
              '• Library Items\n'
              '• Bookmarks & Notes\n'
              '• Comments & Ratings\n'
              '• Collections & Challenges\n'
              '• Reading Stats\n'
              '• Follows & Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

