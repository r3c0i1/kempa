import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kempa/core/layout/app_bar_config.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final config = _getAppBarConfig(location);
    return Scaffold(
      appBar: AppBar(
        title: Text(config.title),
        centerTitle: config.centerTitle,
        actions: config.actions,
        actionsPadding: EdgeInsets.only(right: 16),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: _getSelectedIndex(context),
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Расписание',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/schedule')) return 0;
    if (location.startsWith('/profile')) return 1;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/schedule');
      case 1:
        context.go('/profile');
    }
  }

  AppBarConfig _getAppBarConfig(String location) {
    if (location.startsWith('/schedule')) {
      return const AppBarConfig(
        title: 'Расписание',
      );
    }

    if (location.startsWith('/profile')) {
      return AppBarConfig(
        title: 'Профиль',
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {
                context.push('/profile/settings');
              },
            ),
          ),
        ],
      );
    }

    return const AppBarConfig(title: '');
  }
}