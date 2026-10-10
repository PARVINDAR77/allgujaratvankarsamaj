import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/profile_model.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/providers/chat_provider.dart';
import '../../profile/providers/profile_provider.dart';

class MatchItem {
  final String id;
  final String status;
  final DateTime? createdAt;
  final String? conversationId;
  final ProfileModel? profile;

  MatchItem({
    required this.id,
    required this.status,
    this.createdAt,
    this.conversationId,
    this.profile,
  });

  factory MatchItem.fromJson(Map<String, dynamic> json, {String profileKey = 'otherProfile'}) {
    ProfileModel? p;
    final pData = json[profileKey] ?? json['otherProfile'] ?? json['senderProfile'] ?? json['receiverProfile'];
    if (pData is Map<String, dynamic>) {
      try {
        p = ProfileModel.fromJson(pData);
      } catch (_) {}
    }

    DateTime? dt;
    if (json['createdAt'] != null) {
      dt = DateTime.tryParse(json['createdAt'].toString());
    }

    return MatchItem(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: dt,
      conversationId: json['conversationId']?.toString(),
      profile: p,
    );
  }
}

class RecommendedMatch {
  final ProfileModel profile;
  final int matchScore;
  final List<String> matchReasons;

  RecommendedMatch({
    required this.profile,
    required this.matchScore,
    required this.matchReasons,
  });
}

class MatchState {
  final bool isLoading;
  final String? errorMessage;
  final List<MatchItem> mutualInterests;
  final List<MatchItem> receivedInterests;
  final List<MatchItem> sentInterests;
  final List<RecommendedMatch> smartMatches;

  const MatchState({
    this.isLoading = false,
    this.errorMessage,
    this.mutualInterests = const [],
    this.receivedInterests = const [],
    this.sentInterests = const [],
    this.smartMatches = const [],
  });

  MatchState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MatchItem>? mutualInterests,
    List<MatchItem>? receivedInterests,
    List<MatchItem>? sentInterests,
    List<RecommendedMatch>? smartMatches,
  }) {
    return MatchState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      mutualInterests: mutualInterests ?? this.mutualInterests,
      receivedInterests: receivedInterests ?? this.receivedInterests,
      sentInterests: sentInterests ?? this.sentInterests,
      smartMatches: smartMatches ?? this.smartMatches,
    );
  }
}

class MatchNotifier extends StateNotifier<MatchState> {
  final ChatRepository _chatRepo;
  final Ref _ref;

  MatchNotifier(this._chatRepo, this._ref) : super(const MatchState(isLoading: true)) {
    loadAll();
  }

  Future<void> loadAll({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final results = await Future.wait([
        _chatRepo.getMutualInterests(),
        _chatRepo.getReceivedInterests(),
        _chatRepo.getSentInterests(),
      ]);

      final mutualRaw = results[0];
      final receivedRaw = results[1];
      final sentRaw = results[2];

      final mutualList = mutualRaw.map((m) => MatchItem.fromJson(m, profileKey: 'otherProfile')).toList();
      final receivedList = receivedRaw.map((m) => MatchItem.fromJson(m, profileKey: 'senderProfile')).toList();
      final sentList = sentRaw.map((m) => MatchItem.fromJson(m, profileKey: 'receiverProfile')).toList();

      final smartMatches = _calculateSmartMatches(mutualList, sentList);

      state = state.copyWith(
        isLoading: false,
        mutualInterests: mutualList,
        receivedInterests: receivedList,
        sentInterests: sentList,
        smartMatches: smartMatches,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'મેળ ડેટા લાવવામાં સમસ્યા આવી: $e',
      );
    }
  }

  List<RecommendedMatch> _calculateSmartMatches(
    List<MatchItem> mutualList,
    List<MatchItem> sentList,
  ) {
    final profileState = _ref.read(profileNotifierProvider);
    final allProfiles = profileState.profiles;
    final myProfile = _ref.read(myProfileProvider).valueOrNull;

    final connectedIds = <String>{
      ...mutualList.map((m) => m.profile?.id ?? '').where((id) => id.isNotEmpty),
      ...sentList.map((s) => s.profile?.id ?? '').where((id) => id.isNotEmpty),
      if (myProfile != null) myProfile.id,
    };

    final isUserMale = myProfile?.isMale ?? false;
    final isUserFemale = myProfile?.isFemale ?? false;

    final candidates = allProfiles.where((p) {
      if (connectedIds.contains(p.id)) return false;
      if (isUserMale) {
        return p.isFemale;
      } else if (isUserFemale) {
        return p.isMale;
      }
      return true;
    }).toList();

    final List<RecommendedMatch> recommended = [];

    for (final c in candidates) {
      int score = 70;
      final reasons = <String>[];

      if (c.isVerified == true) {
        score += 10;
        reasons.add('ચકાસાયેલ સભ્ય (Verified Member)');
      }

      if (myProfile != null) {
        if (c.district.isNotEmpty && c.district.toLowerCase() == myProfile.district.toLowerCase()) {
          score += 10;
          reasons.add('સમાન જિલ્લો (${c.district})');
        } else if (c.pargana.isNotEmpty && c.pargana.toLowerCase() == myProfile.pargana.toLowerCase()) {
          score += 8;
          reasons.add('પરગણા સુમેળ (${c.pargana})');
        }

        // Age compatibility
        final myAge = myProfile.age;
        final cAge = c.age;
        if (myAge != null && cAge != null) {
          final diff = (myAge - cAge).abs();
          if (diff <= 4) {
            score += 8;
            reasons.add('સુસંગત ઉંમર (Age Compatible)');
          }
        }
      }

      if (reasons.isEmpty) {
        reasons.add('સમાજ યોગ્ય પ્રોફાઇલ (Community Profile)');
      }

      final finalScore = score.clamp(72, 98);
      recommended.add(RecommendedMatch(
        profile: c,
        matchScore: finalScore,
        matchReasons: reasons,
      ));
    }

    // Sort highest score first
    recommended.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return recommended;
  }

  Future<bool> acceptRequest(String interestId) async {
    final res = await _chatRepo.acceptConnectionRequest(interestId);
    if (res['success'] == true) {
      await loadAll(silent: true);
      return true;
    }
    return false;
  }

  Future<bool> declineRequest(String interestId) async {
    final res = await _chatRepo.declineConnectionRequest(interestId);
    if (res['success'] == true) {
      await loadAll(silent: true);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> sendInterest(String targetProfileId) async {
    final res = await _chatRepo.sendConnectionRequest(targetProfileId);
    if (res['success'] == true) {
      await loadAll(silent: true);
    }
    return res;
  }
}

final matchProvider = StateNotifierProvider.autoDispose<MatchNotifier, MatchState>((ref) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return MatchNotifier(chatRepo, ref);
});
