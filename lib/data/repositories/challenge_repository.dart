import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/challenge_model.dart';
import '../../core/utils/logger.dart';

/// Challenge repository
class ChallengeRepository {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseFirestore get _firestore => _firebaseService.firestore;
  String? get _currentUserId => _firebaseService.currentUserId;
  
  // Get user's challenges
  Future<List<ChallengeModel>> getUserChallenges() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final snapshot = await _firestore
          .collection(AppConstants.challengesCollection)
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ChallengeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      AppLogger.error('Get user challenges error', error: e);
      rethrow;
    }
  }
  
  // Get active challenges
  Future<List<ChallengeModel>> getActiveChallenges() async {
    try {
      final challenges = await getUserChallenges();
      final now = DateTime.now();
      return challenges.where((challenge) {
        return !challenge.isCompleted &&
            now.isAfter(challenge.startDate) &&
            now.isBefore(challenge.endDate);
      }).toList();
    } catch (e) {
      AppLogger.error('Get active challenges error', error: e);
      rethrow;
    }
  }
  
  // Create challenge
  Future<ChallengeModel> createChallenge({
    required String title,
    required String description,
    required ChallengeType type,
    required int targetValue,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final now = DateTime.now();
      final challenge = ChallengeModel(
        id: '', // Will be set by Firestore
        userId: _currentUserId!,
        title: title,
        description: description,
        type: type,
        targetValue: targetValue,
        startDate: startDate,
        endDate: endDate,
        createdAt: now,
        updatedAt: now,
      );
      
      final docRef = await _firestore
          .collection(AppConstants.challengesCollection)
          .add(challenge.toFirestore());
      
      return challenge.copyWith(id: docRef.id);
    } catch (e) {
      AppLogger.error('Create challenge error', error: e);
      rethrow;
    }
  }
  
  // Update challenge progress
  Future<void> updateChallengeProgress({
    required String challengeId,
    required int value,
  }) async {
    try {
      final challenge = await getChallengeById(challengeId);
      if (challenge == null) return;
      
      final newValue = challenge.currentValue + value;
      final isCompleted = newValue >= challenge.targetValue;
      
      await _firestore
          .collection(AppConstants.challengesCollection)
          .doc(challengeId)
          .update({
        'currentValue': newValue,
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      AppLogger.info('Challenge progress updated: $challengeId');
    } catch (e) {
      AppLogger.error('Update challenge progress error', error: e);
      rethrow;
    }
  }
  
  // Get challenge by ID
  Future<ChallengeModel?> getChallengeById(String challengeId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.challengesCollection)
          .doc(challengeId)
          .get();
      
      if (!doc.exists) return null;
      
      return ChallengeModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Get challenge by ID error', error: e);
      rethrow;
    }
  }
  
  // Delete challenge
  Future<void> deleteChallenge(String challengeId) async {
    try {
      await _firestore
          .collection(AppConstants.challengesCollection)
          .doc(challengeId)
          .delete();
      
      AppLogger.info('Challenge deleted: $challengeId');
    } catch (e) {
      AppLogger.error('Delete challenge error', error: e);
      rethrow;
    }
  }
  
  // Get challenges stream
  Stream<List<ChallengeModel>> getUserChallengesStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(AppConstants.challengesCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChallengeModel.fromFirestore(doc))
            .toList());
  }
}

