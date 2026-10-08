import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/profile_model.dart';

class LikedProfilesState {
  final bool isLoading;
  final List<ProfileModel> profiles;
  final Set<String> likedIds;
  final String? error;

  const LikedProfilesState({
    this.isLoading = false,
    this.profiles = const [],
    this.likedIds = const {},
    this.error,
  });

  LikedProfilesState copyWith({
    bool? isLoading,
    List<ProfileModel>? profiles,
    Set<String>? likedIds,
    String? error,
  }) {
    return LikedProfilesState(
      isLoading: isLoading ?? this.isLoading,
      profiles: profiles ?? this.profiles,
      likedIds: likedIds ?? this.likedIds,
      error: error,
    );
  }
}

class LikedProfilesNotifier extends StateNotifier<LikedProfilesState> {
  final Ref _ref;

  LikedProfilesNotifier(this._ref) : super(const LikedProfilesState()) {
    loadLikedIds();
  }

  Future<void> loadLikedIds() async {
    try {
      final dio = _ref.read(apiClientProvider);
      final response = await dio.get('/shortlists/ids');
      dynamic raw = response.data;
      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }
      if (raw is Map && raw.containsKey('data')) {
        raw = raw['data'];
      }
      if (raw is List) {
        final ids = raw.map((e) => e.toString()).toSet();
        state = state.copyWith(likedIds: ids);
      }
    } catch (e) {
      debugPrint('Failed to load liked profile IDs: $e');
    }
  }

  Future<void> loadLikedProfiles() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = _ref.read(apiClientProvider);
      final response = await dio.get('/shortlists');
      dynamic raw = response.data;
      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }
      if (raw is Map && raw.containsKey('data')) {
        raw = raw['data'];
      }
      if (raw is List) {
        final List<ProfileModel> list = [];
        final Set<String> ids = {};
        for (final item in raw) {
          try {
            if (item is Map<String, dynamic>) {
              final p = ProfileModel.fromJson(item);
              list.add(p);
              ids.add(p.id);
            }
          } catch (itemErr) {
            debugPrint('Error parsing liked profile item: $itemErr');
          }
        }
        state = state.copyWith(
          isLoading: false,
          profiles: list,
          likedIds: ids.isNotEmpty ? ids : state.likedIds,
        );
      } else {
        state = state.copyWith(isLoading: false, profiles: []);
      }
    } catch (e) {
      debugPrint('Failed to load liked profiles: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> toggleLike(ProfileModel profile, {BuildContext? context}) async {
    final profileId = profile.id;
    final isCurrentlyLiked = state.likedIds.contains(profileId);
    final nextState = !isCurrentlyLiked;

    // Optimistic state update
    final updatedIds = Set<String>.from(state.likedIds);
    final updatedProfiles = List<ProfileModel>.from(state.profiles);

    if (nextState) {
      updatedIds.add(profileId);
      if (!updatedProfiles.any((p) => p.id == profileId)) {
        updatedProfiles.insert(0, profile);
      }
    } else {
      updatedIds.remove(profileId);
      updatedProfiles.removeWhere((p) => p.id == profileId);
    }

    state = state.copyWith(
      likedIds: updatedIds,
      profiles: updatedProfiles,
    );

    // Show instant feedback SnackBar if context provided
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                nextState ? Icons.favorite : Icons.favorite_border,
                color: nextState ? Colors.redAccent : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nextState
                      ? '${profile.fullName} પસંદ કરેલ પ્રોફાઇલમાં ઉમેરાઈ ગયા (Added to Liked)'
                      : '${profile.fullName} પસંદ કરેલ લિસ્ટમાંથી દૂર કરવામાં આવ્યા (Removed from Liked)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: nextState ? const Color(0xFF1E3A8A) : Colors.grey.shade900,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    // Background API call
    try {
      final dio = _ref.read(apiClientProvider);
      await dio.post(
        '/shortlists/toggle',
        data: {'targetProfileId': profileId},
      );
      return nextState;
    } catch (e) {
      debugPrint('Failed to sync toggle like on backend: $e');
      // Revert optimistic update on failure
      final rollbackIds = Set<String>.from(state.likedIds);
      final rollbackProfiles = List<ProfileModel>.from(state.profiles);

      if (nextState) {
        rollbackIds.remove(profileId);
        rollbackProfiles.removeWhere((p) => p.id == profileId);
      } else {
        rollbackIds.add(profileId);
        rollbackProfiles.add(profile);
      }

      state = state.copyWith(
        likedIds: rollbackIds,
        profiles: rollbackProfiles,
      );

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('કનેક્શન એરર: ફેરફાર સાચવી શકાયો નથી (Connection error)'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return isCurrentlyLiked;
    }
  }
}

final likedProfilesProvider =
    StateNotifierProvider<LikedProfilesNotifier, LikedProfilesState>((ref) {
  return LikedProfilesNotifier(ref);
});

final isProfileLikedProvider = Provider.family<bool, String>((ref, profileId) {
  final state = ref.watch(likedProfilesProvider);
  return state.likedIds.contains(profileId);
});

final likedCountProvider = Provider<int>((ref) {
  final state = ref.watch(likedProfilesProvider);
  return state.likedIds.length;
});
