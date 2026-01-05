import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/blocs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await initDependencies();

  runApp(const HeightMapApp());
}

class HeightMapApp extends StatelessWidget {
  const HeightMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HeightBloc>(create: (_) => getIt<HeightBloc>()),
        BlocProvider<LocationBloc>(create: (_) => getIt<LocationBloc>()),
        BlocProvider<MapBloc>(create: (_) => getIt<MapBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Height Map',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
