import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../../features/auth/providers/auth_provider.dart';

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return const ApiConfig(environment: Environment.production);
});

final dioClientProvider = Provider<DioClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  final interceptor = ref.watch(authInterceptorProvider);
  return DioClient(config, authInterceptor: interceptor);
});
