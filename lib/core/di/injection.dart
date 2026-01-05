import 'package:get_it/get_it.dart';
import '../../data/datasources/datasources.dart';
import '../../data/repositories/repositories.dart';
import '../../presentation/blocs/blocs.dart';

/// Service locator for dependency injection
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // Data sources
  getIt.registerLazySingleton<BarometerDataSource>(() => BarometerDataSource());
  getIt.registerLazySingleton<LocationDataSource>(() => LocationDataSource());
  getIt.registerLazySingleton<ElevationApiDataSource>(
    () => ElevationApiDataSource(),
  );

  // Repositories
  getIt.registerLazySingleton<HeightRepository>(
    () => HeightRepository(
      barometerDataSource: getIt<BarometerDataSource>(),
      locationDataSource: getIt<LocationDataSource>(),
      elevationApiDataSource: getIt<ElevationApiDataSource>(),
    ),
  );
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepository(locationDataSource: getIt<LocationDataSource>()),
  );
  getIt.registerLazySingleton<ElevationRepository>(
    () => ElevationRepository(apiDataSource: getIt<ElevationApiDataSource>()),
  );

  // BLoCs - registered as factory so each widget gets its own instance
  // But for this app, we want singleton BLoCs for shared state
  getIt.registerLazySingleton<HeightBloc>(
    () => HeightBloc(
      heightRepository: getIt<HeightRepository>(),
      locationRepository: getIt<LocationRepository>(),
    ),
  );
  getIt.registerLazySingleton<LocationBloc>(
    () => LocationBloc(locationRepository: getIt<LocationRepository>()),
  );
  getIt.registerLazySingleton<MapBloc>(
    () => MapBloc(elevationRepository: getIt<ElevationRepository>()),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
