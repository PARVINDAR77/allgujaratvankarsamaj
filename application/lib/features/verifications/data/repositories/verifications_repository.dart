import '../datasources/verifications_remote_data_source.dart';

class VerificationsRepository {
  final VerificationsRemoteDataSource _remote;

  VerificationsRepository(this._remote);

  /// Submits a verification request. Returns the created request map.
  Future<Map<String, dynamic>> submitVerification({
    required String documentType,
    required String documentUrl,
  }) async {
    return await _remote.submitVerification(
      documentType: documentType,
      documentUrl: documentUrl,
    );
  }
}
