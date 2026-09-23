import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_failure.dart';
import '../data/datasources/verifications_remote_data_source.dart';
import '../data/repositories/verifications_repository.dart';

final verificationsRemoteDataSourceProvider =
    Provider<VerificationsRemoteDataSource>((ref) {
  return VerificationsRemoteDataSource(ref.watch(apiClientProvider));
});

final verificationsRepositoryProvider =
    Provider<VerificationsRepository>((ref) {
  return VerificationsRepository(
      ref.watch(verificationsRemoteDataSourceProvider));
});

// ─── State machine ─────────────────────────────────────────────────────────

enum VerificationSubmitStatus { initial, submitting, success, error }

class VerificationSubmitState {
  final VerificationSubmitStatus status;
  final String? errorMessage;

  const VerificationSubmitState({
    this.status = VerificationSubmitStatus.initial,
    this.errorMessage,
  });

  VerificationSubmitState copyWith({
    VerificationSubmitStatus? status,
    String? errorMessage,
  }) {
    return VerificationSubmitState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  bool get isInitial => status == VerificationSubmitStatus.initial;
  bool get isSubmitting => status == VerificationSubmitStatus.submitting;
  bool get isSuccess => status == VerificationSubmitStatus.success;
  bool get isError => status == VerificationSubmitStatus.error;
}

class VerificationSubmitNotifier
    extends StateNotifier<VerificationSubmitState> {
  final VerificationsRepository _repository;

  VerificationSubmitNotifier(this._repository)
      : super(const VerificationSubmitState());

  /// Submits the verification. UI can watch state transitions:
  ///   initial → submitting → success
  ///   initial → submitting → error
  Future<void> submit({
    required String documentType,
    required String documentUrl,
  }) async {
    if (state.isSubmitting) return; // guard double-tap

    state = state.copyWith(status: VerificationSubmitStatus.submitting);
    try {
      await _repository.submitVerification(
        documentType: documentType,
        documentUrl: documentUrl,
      );
      state = state.copyWith(status: VerificationSubmitStatus.success);
    } on ApiFailure catch (e) {
      state = state.copyWith(
        status: VerificationSubmitStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: VerificationSubmitStatus.error,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  void reset() {
    state = const VerificationSubmitState();
  }
}

final verificationSubmitProvider = StateNotifierProvider<
    VerificationSubmitNotifier, VerificationSubmitState>((ref) {
  return VerificationSubmitNotifier(ref.watch(verificationsRepositoryProvider));
});
