import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

// Мета-данные тем
class ThemeMeta {
  final String name;
  final String emoji;
  final String description;
  final bool isSecret;

  const ThemeMeta({
    required this.name,
    required this.emoji,
    required this.description,
    this.isSecret = false,
  });

  static const Map<AppThemeMode, ThemeMeta> all = {
    AppThemeMode.system: ThemeMeta(
      name: 'Системная',
      emoji: '⚙️',
      description: 'Как в настройках устройства',
    ),
    AppThemeMode.light: ThemeMeta(
      name: 'Светлая',
      emoji: '☀️',
      description: 'Классическая светлая',
    ),
    AppThemeMode.dark: ThemeMeta(
      name: 'Тёмная',
      emoji: '🌙',
      description: 'Классическая тёмная',
    ),
  };
}

// Events
abstract class ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final AppThemeMode mode;
  ThemeChanged(this.mode);
}

class ThemeLoaded extends ThemeEvent {}

// State
class ThemeState {
  final AppThemeMode mode;
  const ThemeState(this.mode);
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final FlutterSecureStorage storage;

  ThemeBloc(this.storage) : super(ThemeState(AppThemeMode.system)) {
    on<ThemeLoaded>(_onLoaded);
    on<ThemeChanged>(_onChanged);
  }

  Future<void> _onLoaded(
    ThemeLoaded event,
    Emitter<ThemeState> emit,
  ) async {
    final saved = await storage.read(key: 'theme_mode');
    final mode = AppThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppThemeMode.system,
    );
    emit(ThemeState(mode));
  }

  Future<void> _onChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await storage.write(key: 'theme_mode', value: event.mode.name);
    emit(ThemeState(event.mode));
  }
}