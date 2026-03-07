import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kempa/core/widgets/profile_widgets.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthentificatedState) {
            return Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Аватар и имя
              ProfileHeader(user: user),
              SizedBox(height: 24),

              // Информация
              SectionTitle(title: 'Информация'),
              InfoCard(
                children: [
                  InfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: user.email,
                  ),
                  InfoTile(
                    icon: Icons.school_outlined,
                    title: 'Роль',
                    subtitle: user.role == UserRole.student
                        ? 'Студент'
                        : 'Преподаватель',
                  ),
                  if (user.organization != null)
                    InfoTile(
                      icon: Icons.business_outlined,
                      title: 'Организация',
                      subtitle: user.organization!,
                    ),
                ],
              ),
              SizedBox(height: 24),

              // Выход
              InfoCard(
                children: [
                  ActionTile(
                    icon: Icons.logout,
                    title: 'Выйти',
                    isDestructive: true,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Выйти из аккаунта?'),
        content: Text('Вам нужно будет войти снова'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogoutEvent());
            },
            child: Text('Выйти'),
          ),
        ],
      ),
    );
  }
}