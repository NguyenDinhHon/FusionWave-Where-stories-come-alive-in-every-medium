import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/challenge_repository.dart';
import '../../../../data/models/challenge_model.dart';

/// Challenge repository provider
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});

/// User challenges provider
final userChallengesProvider = StreamProvider<List<ChallengeModel>>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getUserChallengesStream();
});

/// Active challenges provider
final activeChallengesProvider = FutureProvider<List<ChallengeModel>>((ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getActiveChallenges();
});

/// Challenge controller provider
final challengeControllerProvider = Provider<ChallengeController>((ref) {
  return ChallengeController(ref.read(challengeRepositoryProvider));
});

class ChallengeController {
  final ChallengeRepository _repository;
  
  ChallengeController(this._repository);
  
  Future<ChallengeModel> createChallenge({
    required String title,
    required String description,
    required ChallengeType type,
    required int targetValue,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _repository.createChallenge(
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      startDate: startDate,
      endDate: endDate,
    );
  }
  
  Future<void> updateChallengeProgress({
    required String challengeId,
    required int value,
  }) async {
    await _repository.updateChallengeProgress(
      challengeId: challengeId,
      value: value,
    );
  }
  
  Future<void> deleteChallenge(String challengeId) async {
    await _repository.deleteChallenge(challengeId);
  }
}

