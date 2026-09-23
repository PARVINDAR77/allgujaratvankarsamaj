import '../../../../shared/models/advertisement_model.dart';
import '../datasources/advertisements_remote_data_source.dart';

class AdvertisementsRepository {
  final AdvertisementsRemoteDataSource _remote;

  AdvertisementsRepository(this._remote);

  Future<List<AdvertisementModel>> getActiveAdvertisements() async {
    final items = await _remote.getActiveAdvertisements();
    return items.map(AdvertisementModel.fromJson).toList();
  }
}
