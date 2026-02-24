import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kempa/core/di/injection_container.dart' as di;
import 'package:kempa/core/router/app_router.dart';
import 'package:kempa/core/theme/app_theme.dart';
import 'package:kempa/core/theme/theme_block.dart';
import 'package:kempa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kempa/features/auth/presentation/bloc/auth_event.dart';
import 'package:kempa/features/auth/presentation/pages/splash_screen.dart';
import 'package:kempa/features/schedule/presentation/bloc/schedule_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(KempaApp());
}

class KempaApp extends StatefulWidget {
  const KempaApp({super.key});

  @override
  State<KempaApp> createState() => _KempaAppState();
}

class _KempaAppState extends State<KempaApp> {
  late final AuthBloc _authBloc;
  late final ThemeBloc _themeBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl.get<AuthBloc>()..add(AuthCheckRequested());
    _themeBloc = di.sl.get<ThemeBloc>();
    _router = AppRouter(_authBloc, di.sl.get<SplashController>()).router;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _themeBloc),
        BlocProvider(create: (_) => di.sl.get<ScheduleBloc>())
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isSystem = themeState.mode == AppThemeMode.system;

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: '1{емГУ',
            theme: isSystem
                ? AppTheme.light
                : AppTheme.getTheme(themeState.mode),
            darkTheme: isSystem ? AppTheme.dark : null,
            themeMode: isSystem ? ThemeMode.system : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
