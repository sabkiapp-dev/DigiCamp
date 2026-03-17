import 'package:get_it/get_it.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

final locator = GetIt.instance;

void initializeDependency({required ApiClient client}) {
  locator.registerLazySingleton<ApiClient>(() => client);
}
