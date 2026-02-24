import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kempa/features/auth/domain/usecases/auth_update_usecase.dart';
import 'package:kempa/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:kempa/features/auth/domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final CheckAuthUsecase checkAuthUsecase;
  final LogoutUsecase logoutUsecase;
  final AuthUpdateUseCase authUpdateUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.checkAuthUsecase,
    required this.logoutUsecase,
    required this.authUpdateUseCase
  }) : super(AuthInitial()) {
    
    // Обработка входа
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase.execute(event.login, event.password);
        emit(AuthSuccess(user));
      } catch (e) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        emit(AuthFailure(errorMessage));
      }
    });

    on<AuthCheckRequested>((event, emit) async {
      emit(AuthChecking());
      try {
        final user = await checkAuthUsecase.execute();

        if (user == null) {
          emit(Unauthenticated());
          return;
        }

        try {
          await authUpdateUseCase.execute();
        } catch (e) {
          if (e is DioException && e.response?.statusCode == 401) {
            emit(Unauthenticated());
            return;
          }
        }
        emit(AuthSuccess(user));
      } catch (e) {
        emit(Unauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      await logoutUsecase.execute();
      emit(Unauthenticated());
    });

    on<AuthUpdateRequested>((event, emit) async {
      try {
        await authUpdateUseCase.execute();
      } catch (e) {
        emit(Unauthenticated());
      }
    },);
  }
}