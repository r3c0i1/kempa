import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kempa/core/theme/theme_block.dart';
import 'package:kempa/core/widgets/profile_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _versionTapCount = 0;
  bool _secretUnlocked = false;

  void _onVersionTap() {
    _versionTapCount++;

    if (_versionTapCount >= 10 && !_secretUnlocked) {
      setState(() {
        _secretUnlocked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Row(
            children: [
              Text('🎉', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Секретные темы разблокированы!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Теперь загляни в выбор темы 👀'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_versionTapCount >= 5 && !_secretUnlocked) {
      final remaining = 10 - _versionTapCount;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Text('Ещё $remaining...'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SectionTitle(title: 'Внешний вид'),
          InfoCard(
            children: [
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  final meta = ThemeMeta.all[state.mode]!;
                  return ActionTile(
                    icon: Icons.palette_outlined,
                    title: 'Тема',
                    subtitle: '${meta.emoji} ${meta.name}',
                    onTap: () => _showThemeDialog(context, state.mode),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 24),

          SectionTitle(title: 'О приложении'),
          InfoCard(
            children: [
              // 🎯 Пасхалка — нажми 10 раз
              ActionTile(
                icon: Icons.info_outlined,
                title: 'Версия',
                subtitle: '1.0.0',
                onTap: _onVersionTap,
                showChevron: false,
              ),
              ActionTile(
                icon: Icons.description_outlined,
                title: 'Лицензии',
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: '1{емГУ',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, AppThemeMode current) {
    showDialog(
      context: context,
      builder: (ctx) {
        final standardThemes = ThemeMeta.all.entries
            .where((e) => !e.value.isSecret)
            .toList();

        final secretThemes = ThemeMeta.all.entries
            .where((e) => e.value.isSecret)
            .toList();

        return AlertDialog(
          title: Text('Тема'),
          contentPadding: EdgeInsets.only(top: 16, bottom: 24),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Стандартные темы
                ...standardThemes.map((entry) => RadioListTile<AppThemeMode>(
                  title: Text('${entry.value.emoji} ${entry.value.name}'),
                  subtitle: Text(entry.value.description),
                  value: entry.key,
                  groupValue: current,
                  onChanged: (value) {
                    context.read<ThemeBloc>().add(ThemeChanged(value!));
                    Navigator.pop(ctx);
                  },
                )),

                // Секретные темы
                if (!_secretUnlocked) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '🔓 Секретные',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  ...secretThemes.map((entry) => RadioListTile<AppThemeMode>(
                    title: Text('${entry.value.emoji} ${entry.value.name}'),
                    subtitle: Text(entry.value.description),
                    value: entry.key,
                    groupValue: current,
                    onChanged: (value) {
                      context.read<ThemeBloc>().add(ThemeChanged(value!));
                      Navigator.pop(ctx);
                    },
                  )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}