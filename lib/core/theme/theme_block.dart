import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppThemeMode {
  system,
  light,
  dark,
  // Секретные
  helloKitty,
  hacker,
  vaporwave,
  sakura,
  pepe,
  ocean,
  halloween,
  doge,
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
    AppThemeMode.helloKitty: ThemeMeta(
      name: 'Hello Kitty',
      emoji: '🎀',
      description: 'Кавайная тема',
      isSecret: true,
    ),
    AppThemeMode.hacker: ThemeMeta(
      name: 'Hacker',
      emoji: '🤓',
      description: 'I\'m in',
      isSecret: true,
    ),
    AppThemeMode.vaporwave: ThemeMeta(
      name: 'Vaporwave',
      emoji: '👾',
      description: 'A E S T H E T I C',
      isSecret: true,
    ),
    AppThemeMode.sakura: ThemeMeta(
      name: 'Sakura',
      emoji: '🌸',
      description: 'Цветущая вишня',
      isSecret: true,
    ),
    AppThemeMode.pepe: ThemeMeta(
      name: 'Pepe',
      emoji: '🐸',
      description: 'Feels good man',
      isSecret: true,
    ),
    AppThemeMode.ocean: ThemeMeta(
      name: 'Ocean',
      emoji: '🌊',
      description: 'Глубины океана',
      isSecret: true,
    ),
    AppThemeMode.halloween: ThemeMeta(
      name: 'Halloween',
      emoji: '🎃',
      description: 'Spooky scary',
      isSecret: true,
    ),
    AppThemeMode.doge: ThemeMeta(
      name: 'Doge',
      emoji: '🐕',
      description: 'Such theme. Much wow.',
      isSecret: true,
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